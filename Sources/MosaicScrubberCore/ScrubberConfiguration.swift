import CoreGraphics
import Foundation

/// User-tunable behavior and layout for an interactive video scrubber.
public struct ScrubberConfiguration: Codable, Hashable, Sendable {
    public var thumbnailCount: Int
    public var trackHeight: Double
    public var previewSize: CGSize
    public var maximumPreviewDuration: TimeInterval
    public var seekTolerance: TimeInterval
    public var hoverDebounce: TimeInterval
    public var transitionDuration: TimeInterval
    public var showsTimecode: Bool
    public var commitsSeekOnDragEnd: Bool
    public var prefetchWindow: Int
    public var cachePolicy: ScrubberCachePolicy

    public init(
        thumbnailCount: Int = 48,
        trackHeight: Double = 64,
        previewSize: CGSize = CGSize(width: 320, height: 180),
        maximumPreviewDuration: TimeInterval = 1.5,
        seekTolerance: TimeInterval = 0.12,
        hoverDebounce: TimeInterval = 0.05,
        transitionDuration: TimeInterval = 0.12,
        showsTimecode: Bool = true,
        commitsSeekOnDragEnd: Bool = true,
        prefetchWindow: Int = 3,
        cachePolicy: ScrubberCachePolicy = .memory(maxItems: 96)
    ) {
        self.thumbnailCount = max(1, thumbnailCount)
        self.trackHeight = max(44, trackHeight)
        self.previewSize = previewSize
        self.maximumPreviewDuration = max(0.1, maximumPreviewDuration)
        self.seekTolerance = max(0, seekTolerance)
        self.hoverDebounce = max(0, hoverDebounce)
        self.transitionDuration = max(0, transitionDuration)
        self.showsTimecode = showsTimecode
        self.commitsSeekOnDragEnd = commitsSeekOnDragEnd
        self.prefetchWindow = max(0, prefetchWindow)
        self.cachePolicy = cachePolicy
    }

    public static let `default` = ScrubberConfiguration()
}

/// Defines how generated thumbnails are retained.
public enum ScrubberCachePolicy: Codable, Hashable, Sendable {
    case none
    case memory(maxItems: Int)
}
