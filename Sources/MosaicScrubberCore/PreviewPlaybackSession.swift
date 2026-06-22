import AVFoundation
import Foundation
import Logging

@MainActor
public final class PreviewPlaybackSession {
    public let player: AVPlayer
    public private(set) var itemVideoOutput: AVPlayerItemVideoOutput?

    private let logger = Logger(label: "com.mosaicScrubber.preview-session")
    private var source: ScrubberVideoSource?
    private var stopTask: Task<Void, Never>?

    public init() {
        self.player = AVPlayer()
        self.player.isMuted = true
        self.player.actionAtItemEnd = .pause
    }

    deinit {
        stopTask?.cancel()
    }

    public func prepare(for source: ScrubberVideoSource) {
        if self.source == source, player.currentItem != nil { return }

        stopTask?.cancel()
        self.source = source

        let asset = AVURLAsset(url: source.url)
        let item = AVPlayerItem(asset: asset)
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ])
        item.add(output)
        player.replaceCurrentItem(with: item)
        player.isMuted = true
        itemVideoOutput = output
    }

    public func preview(
        at time: CMTime,
        tolerance: TimeInterval,
        maximumDuration: TimeInterval
    ) {
        guard player.currentItem != nil else { return }

        stopTask?.cancel()
        player.pause()
        player.currentItem?.cancelPendingSeeks()

        let cmTolerance = CMTime(seconds: tolerance, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: cmTolerance, toleranceAfter: cmTolerance) { [weak self] finished in
            guard let self, finished else { return }
            Task { @MainActor in
                self.player.play()
                self.scheduleStop(after: maximumDuration)
            }
        }
    }

    public func stop() {
        stopTask?.cancel()
        player.pause()
    }

    public func currentPixelBuffer() -> CVPixelBuffer? {
        guard let output = itemVideoOutput,
              let item = player.currentItem else {
            return nil
        }

        let itemTime = item.currentTime()
        guard output.hasNewPixelBuffer(forItemTime: itemTime) else { return nil }
        return output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil)
    }

    private func scheduleStop(after seconds: TimeInterval) {
        stopTask = Task { [weak self] in
            let nanoseconds = UInt64(max(0, seconds) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.player.pause()
            }
        }
    }
}
