import AVFoundation
import CoreGraphics
import Foundation
import Logging
import OSLog

public struct TimelineThumbnail: Identifiable, Sendable {
    public let id: Int
    public let time: CMTime
    public let image: CGImage

    public init(id: Int, time: CMTime, image: CGImage) {
        self.id = id
        self.time = time
        self.image = image
    }
}

public actor ThumbnailStripGenerator {
    private let logger = Logger(label: "com.mosaicScrubber.thumbnail-strip")
    private let signposter = OSSignposter(subsystem: "com.mosaicScrubber", category: "thumbnail-strip")

    public init() {}

    public func generateThumbnails(
        for source: ScrubberVideoSource,
        timeline: ScrubberTimeline,
        maximumSize: CGSize,
        accurate: Bool = false,
        progress: (@Sendable (Double) -> Void)? = nil
    ) async throws -> [TimelineThumbnail] {
        let state = signposter.beginInterval("Generate Thumbnails")
        defer { signposter.endInterval("Generate Thumbnails", state) }

        guard !timeline.segments.isEmpty else { return [] }

        let asset = AVURLAsset(url: source.url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = maximumSize
        if accurate {
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero
        } else {
            let tolerance = CMTime(seconds: 0.5, preferredTimescale: 600)
            generator.requestedTimeToleranceBefore = tolerance
            generator.requestedTimeToleranceAfter = tolerance
        }

        let times = timeline.segments.map(\.thumbnailTime)
        var thumbnails: [Int: TimelineThumbnail] = [:]
        var index = 0

        for await result in generator.images(for: times) {
            try Task.checkCancellation()
            let currentIndex = index
            index += 1

            switch result {
            case .success(_, let image, let actualTime):
                thumbnails[currentIndex] = TimelineThumbnail(
                    id: currentIndex,
                    time: actualTime,
                    image: image
                )
            case .failure(let requestedTime, let error):
                logger.warning("Thumbnail failed at \(requestedTime.seconds): \(error.localizedDescription)")
            }

            progress?(Double(index) / Double(times.count))
        }

        let ordered = (0..<times.count).compactMap { thumbnails[$0] }
        guard !ordered.isEmpty else {
            throw ScrubberError.thumbnailGenerationFailed("No thumbnails could be generated.")
        }
        return ordered
    }
}
