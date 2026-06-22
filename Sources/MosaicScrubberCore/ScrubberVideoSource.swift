import AVFoundation
import CoreGraphics
import Foundation

/// Describes a video asset that can be displayed with the scrubber.
public struct ScrubberVideoSource: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let url: URL
    public let duration: TimeInterval?
    public let naturalSize: CGSize?
    public let frameRate: Double?
    public let title: String

    public init(
        id: UUID = UUID(),
        url: URL,
        duration: TimeInterval? = nil,
        naturalSize: CGSize? = nil,
        frameRate: Double? = nil,
        title: String? = nil
    ) {
        self.id = id
        self.url = url
        self.duration = duration
        self.naturalSize = naturalSize
        self.frameRate = frameRate
        self.title = title ?? url.deletingPathExtension().lastPathComponent
    }

    /// Loads common metadata from the asset without requiring MosaicKit.
    public static func load(from url: URL, id: UUID = UUID()) async throws -> ScrubberVideoSource {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration).seconds
        let tracks = try await asset.loadTracks(withMediaType: .video)
        let track = tracks.first
        let naturalSize = try await track?.load(.naturalSize)
        let frameRate = try await track?.load(.nominalFrameRate)

        return ScrubberVideoSource(
            id: id,
            url: url,
            duration: duration.isFinite ? duration : nil,
            naturalSize: naturalSize,
            frameRate: frameRate.map(Double.init),
            title: url.deletingPathExtension().lastPathComponent
        )
    }
}
