import CoreGraphics
import Foundation

/// User-tunable behavior and layout for an interactive video scrubber.
public struct ScrubberConfiguration: Codable, Hashable, Sendable {
    public var thumbnailCount: Int
    public var trackHeight: Double
    public var previewSize: ScrubberPreviewSize
    public var maximumPreviewDuration: TimeInterval
    public var seekTolerance: TimeInterval
    public var hoverDebounce: TimeInterval
    public var transitionDuration: TimeInterval
    public var showsTimecode: Bool
    public var showsTemporalDelta: Bool
    public var showsLiveIndicator: Bool
    public var showsFilmPerforations: Bool
    public var usesHoverSpotlight: Bool
    public var visualTheme: ScrubberVisualTheme
    public var commitsSeekOnDragEnd: Bool
    public var prefetchWindow: Int
    public var cachePolicy: ScrubberCachePolicy

    public init(
        thumbnailCount: Int = 48,
        trackHeight: Double = 64,
        previewSize: ScrubberPreviewSize = .medium,
        maximumPreviewDuration: TimeInterval = 1.5,
        seekTolerance: TimeInterval = 0.12,
        hoverDebounce: TimeInterval = 0.05,
        transitionDuration: TimeInterval = 0.12,
        showsTimecode: Bool = true,
        showsTemporalDelta: Bool = true,
        showsLiveIndicator: Bool = true,
        showsFilmPerforations: Bool = true,
        usesHoverSpotlight: Bool = true,
        visualTheme: ScrubberVisualTheme = .automatic,
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
        self.showsTemporalDelta = showsTemporalDelta
        self.showsLiveIndicator = showsLiveIndicator
        self.showsFilmPerforations = showsFilmPerforations
        self.usesHoverSpotlight = usesHoverSpotlight
        self.visualTheme = visualTheme
        self.commitsSeekOnDragEnd = commitsSeekOnDragEnd
        self.prefetchWindow = max(0, prefetchWindow)
        self.cachePolicy = cachePolicy
    }

    @available(*, deprecated, message: "Use previewSize: ScrubberPreviewSize (.small, .medium, .large). Fixed dimensions are mapped to the nearest adaptive preset.")
    public init(
        thumbnailCount: Int = 48,
        trackHeight: Double = 64,
        previewSize: CGSize,
        maximumPreviewDuration: TimeInterval = 1.5,
        seekTolerance: TimeInterval = 0.12,
        hoverDebounce: TimeInterval = 0.05,
        transitionDuration: TimeInterval = 0.12,
        showsTimecode: Bool = true,
        showsTemporalDelta: Bool = true,
        showsLiveIndicator: Bool = true,
        showsFilmPerforations: Bool = true,
        usesHoverSpotlight: Bool = true,
        visualTheme: ScrubberVisualTheme = .automatic,
        commitsSeekOnDragEnd: Bool = true,
        prefetchWindow: Int = 3,
        cachePolicy: ScrubberCachePolicy = .memory(maxItems: 96)
    ) {
        self.init(
            thumbnailCount: thumbnailCount,
            trackHeight: trackHeight,
            previewSize: ScrubberPreviewSize.nearest(to: previewSize),
            maximumPreviewDuration: maximumPreviewDuration,
            seekTolerance: seekTolerance,
            hoverDebounce: hoverDebounce,
            transitionDuration: transitionDuration,
            showsTimecode: showsTimecode,
            showsTemporalDelta: showsTemporalDelta,
            showsLiveIndicator: showsLiveIndicator,
            showsFilmPerforations: showsFilmPerforations,
            usesHoverSpotlight: usesHoverSpotlight,
            visualTheme: visualTheme,
            commitsSeekOnDragEnd: commitsSeekOnDragEnd,
            prefetchWindow: prefetchWindow,
            cachePolicy: cachePolicy
        )
    }

    public static let `default` = ScrubberConfiguration()

    fileprivate enum CodingKeys: String, CodingKey {
        case thumbnailCount
        case trackHeight
        case previewSize
        case maximumPreviewDuration
        case seekTolerance
        case hoverDebounce
        case transitionDuration
        case showsTimecode
        case showsTemporalDelta
        case showsLiveIndicator
        case showsFilmPerforations
        case usesHoverSpotlight
        case visualTheme
        case commitsSeekOnDragEnd
        case prefetchWindow
        case cachePolicy
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            thumbnailCount: try container.decodeIfPresent(Int.self, forKey: .thumbnailCount) ?? Self.default.thumbnailCount,
            trackHeight: try container.decodeIfPresent(Double.self, forKey: .trackHeight) ?? Self.default.trackHeight,
            previewSize: try container.decodePreviewSize(forKey: .previewSize) ?? Self.default.previewSize,
            maximumPreviewDuration: try container.decodeIfPresent(TimeInterval.self, forKey: .maximumPreviewDuration) ?? Self.default.maximumPreviewDuration,
            seekTolerance: try container.decodeIfPresent(TimeInterval.self, forKey: .seekTolerance) ?? Self.default.seekTolerance,
            hoverDebounce: try container.decodeIfPresent(TimeInterval.self, forKey: .hoverDebounce) ?? Self.default.hoverDebounce,
            transitionDuration: try container.decodeIfPresent(TimeInterval.self, forKey: .transitionDuration) ?? Self.default.transitionDuration,
            showsTimecode: try container.decodeIfPresent(Bool.self, forKey: .showsTimecode) ?? Self.default.showsTimecode,
            showsTemporalDelta: try container.decodeIfPresent(Bool.self, forKey: .showsTemporalDelta) ?? Self.default.showsTemporalDelta,
            showsLiveIndicator: try container.decodeIfPresent(Bool.self, forKey: .showsLiveIndicator) ?? Self.default.showsLiveIndicator,
            showsFilmPerforations: try container.decodeIfPresent(Bool.self, forKey: .showsFilmPerforations) ?? Self.default.showsFilmPerforations,
            usesHoverSpotlight: try container.decodeIfPresent(Bool.self, forKey: .usesHoverSpotlight) ?? Self.default.usesHoverSpotlight,
            visualTheme: try container.decodeIfPresent(ScrubberVisualTheme.self, forKey: .visualTheme) ?? Self.default.visualTheme,
            commitsSeekOnDragEnd: try container.decodeIfPresent(Bool.self, forKey: .commitsSeekOnDragEnd) ?? Self.default.commitsSeekOnDragEnd,
            prefetchWindow: try container.decodeIfPresent(Int.self, forKey: .prefetchWindow) ?? Self.default.prefetchWindow,
            cachePolicy: try container.decodeIfPresent(ScrubberCachePolicy.self, forKey: .cachePolicy) ?? Self.default.cachePolicy
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(thumbnailCount, forKey: .thumbnailCount)
        try container.encode(trackHeight, forKey: .trackHeight)
        try container.encode(previewSize, forKey: .previewSize)
        try container.encode(maximumPreviewDuration, forKey: .maximumPreviewDuration)
        try container.encode(seekTolerance, forKey: .seekTolerance)
        try container.encode(hoverDebounce, forKey: .hoverDebounce)
        try container.encode(transitionDuration, forKey: .transitionDuration)
        try container.encode(showsTimecode, forKey: .showsTimecode)
        try container.encode(showsTemporalDelta, forKey: .showsTemporalDelta)
        try container.encode(showsLiveIndicator, forKey: .showsLiveIndicator)
        try container.encode(showsFilmPerforations, forKey: .showsFilmPerforations)
        try container.encode(usesHoverSpotlight, forKey: .usesHoverSpotlight)
        try container.encode(visualTheme, forKey: .visualTheme)
        try container.encode(commitsSeekOnDragEnd, forKey: .commitsSeekOnDragEnd)
        try container.encode(prefetchWindow, forKey: .prefetchWindow)
        try container.encode(cachePolicy, forKey: .cachePolicy)
    }
}

private extension KeyedDecodingContainer where Key == ScrubberConfiguration.CodingKeys {
    func decodePreviewSize(forKey key: Key) throws -> ScrubberPreviewSize? {
        if let preset = try? decodeIfPresent(ScrubberPreviewSize.self, forKey: key) {
            return preset
        }
        if let legacySize = try? decodeIfPresent(CGSize.self, forKey: key) {
            return ScrubberPreviewSize.nearest(to: legacySize)
        }
        return nil
    }
}

/// Defines how generated thumbnails are retained.
public enum ScrubberCachePolicy: Codable, Hashable, Sendable {
    case none
    case memory(maxItems: Int)
}
