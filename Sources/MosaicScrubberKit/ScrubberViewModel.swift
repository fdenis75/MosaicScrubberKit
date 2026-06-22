import AVFoundation
import CoreGraphics
import Foundation
import Logging
import MosaicScrubberCore
import MosaicScrubberMetal
import Observation

@MainActor
@Observable
public final class ScrubberViewModel {
    public private(set) var timeline: ScrubberTimeline
    public private(set) var thumbnails: [TimelineThumbnail] = []
    public private(set) var isLoadingThumbnails = false
    public private(set) var errorMessage: String?
    public private(set) var currentTime: CMTime = .zero
    public private(set) var hoveredTime: CMTime?
    public private(set) var isPreviewVisible = false

    @ObservationIgnored public let previewSession = PreviewPlaybackSession()
    @ObservationIgnored public let renderer: MetalPreviewRenderer?
    @ObservationIgnored private let thumbnailGenerator = ThumbnailStripGenerator()
    @ObservationIgnored private var thumbnailTask: Task<Void, Never>?
    @ObservationIgnored private var previewPumpTask: Task<Void, Never>?
    @ObservationIgnored private var timeObserver: Any?
    @ObservationIgnored private var latestPreviewRequest: CMTime?
    @ObservationIgnored private let logger = Logger(label: "com.mosaicScrubber.view-model")

    public let source: ScrubberVideoSource
    public let configuration: ScrubberConfiguration
    public let player: AVPlayer

    public init(
        source: ScrubberVideoSource,
        player: AVPlayer,
        configuration: ScrubberConfiguration = .default
    ) {
        self.source = source
        self.player = player
        self.configuration = configuration
        self.timeline = ScrubberTimelinePlanner.makeTimeline(
            duration: source.duration ?? 0,
            thumbnailCount: configuration.thumbnailCount
        )
        self.renderer = try? MetalPreviewRenderer(transitionDuration: configuration.transitionDuration)
        observePlayer()
    }

    deinit {
        thumbnailTask?.cancel()
        previewPumpTask?.cancel()
    }

    public func load() {
        previewSession.prepare(for: source)
        if let duration = source.duration, duration > 0 {
            timeline = ScrubberTimelinePlanner.makeTimeline(
                duration: duration,
                thumbnailCount: configuration.thumbnailCount
            )
            loadThumbnails()
            return
        }

        thumbnailTask?.cancel()
        thumbnailTask = Task { [weak self] in
            guard let self else { return }
            do {
                let loaded = try await ScrubberVideoSource.load(from: source.url, id: source.id)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.timeline = ScrubberTimelinePlanner.makeTimeline(
                        duration: loaded.duration ?? 0,
                        thumbnailCount: self.configuration.thumbnailCount
                    )
                    self.loadThumbnails()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    public func updateHover(normalized: Double) {
        let time = timeline.time(forNormalizedPosition: normalized)
        hoveredTime = time
        isPreviewVisible = true
        latestPreviewRequest = time
        previewSession.preview(
            at: time,
            tolerance: configuration.seekTolerance,
            maximumDuration: configuration.maximumPreviewDuration
        )
        startPreviewPumpIfNeeded()
    }

    public func endHover() {
        hoveredTime = nil
        isPreviewVisible = false
        latestPreviewRequest = nil
        previewPumpTask?.cancel()
        previewPumpTask = nil
        previewSession.stop()
    }

    public func tearDown() {
        endHover()
        thumbnailTask?.cancel()
        thumbnailTask = nil
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    public func seek(normalized: Double) {
        let time = timeline.time(forNormalizedPosition: normalized)
        let tolerance = CMTime(seconds: configuration.seekTolerance, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: tolerance, toleranceAfter: tolerance)
    }

    public func step(by seconds: TimeInterval) {
        let next = max(0, min(timeline.duration, currentTime.seconds + seconds))
        player.seek(to: CMTime(seconds: next, preferredTimescale: 600))
    }

    private func loadThumbnails() {
        thumbnailTask?.cancel()
        isLoadingThumbnails = true
        errorMessage = nil
        let maximumSize = CGSize(
            width: configuration.trackHeight * 16.0 / 9.0,
            height: configuration.trackHeight
        )

        thumbnailTask = Task { [weak self] in
            guard let self else { return }
            do {
                let generated = try await thumbnailGenerator.generateThumbnails(
                    for: source,
                    timeline: timeline,
                    maximumSize: maximumSize
                )
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.thumbnails = generated
                    self.isLoadingThumbnails = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoadingThumbnails = false
                }
            }
        }
    }

    private func startPreviewPumpIfNeeded() {
        guard previewPumpTask == nil else { return }
        previewPumpTask = Task { [weak self] in
            while !Task.isCancelled {
                await MainActor.run {
                    if let pixelBuffer = self?.previewSession.currentPixelBuffer() {
                        self?.renderer?.update(pixelBuffer: pixelBuffer)
                    }
                }
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }

    private func observePlayer() {
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time
            }
        }
    }
}
