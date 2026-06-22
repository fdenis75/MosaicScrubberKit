import AVFoundation
import CoreGraphics
import Foundation

public struct ScrubberTimeline: Sendable, Hashable {
    public let duration: TimeInterval
    public let segments: [ScrubberTimelineSegment]

    public init(duration: TimeInterval, segments: [ScrubberTimelineSegment]) {
        self.duration = max(0, duration)
        self.segments = segments
    }

    public func time(forNormalizedPosition normalized: Double) -> CMTime {
        let clamped = min(max(normalized, 0), 1)
        return CMTime(seconds: duration * clamped, preferredTimescale: 600)
    }

    public func normalizedPosition(for time: CMTime) -> Double {
        guard duration > 0 else { return 0 }
        return min(max(time.seconds / duration, 0), 1)
    }

    public func segment(containing time: CMTime) -> ScrubberTimelineSegment? {
        let seconds = time.seconds
        return segments.first { segment in
            seconds >= segment.start.seconds && seconds < segment.end.seconds
        } ?? segments.last
    }
}

public struct ScrubberTimelineSegment: Identifiable, Sendable, Hashable {
    public let id: Int
    public let start: CMTime
    public let duration: CMTime
    public let thumbnailTime: CMTime

    public var end: CMTime {
        start + duration
    }

    public init(id: Int, start: CMTime, duration: CMTime, thumbnailTime: CMTime) {
        self.id = id
        self.start = start
        self.duration = duration
        self.thumbnailTime = thumbnailTime
    }
}

public enum ScrubberTimelinePlanner {
    public static func makeTimeline(duration: TimeInterval, thumbnailCount: Int) -> ScrubberTimeline {
        let cleanDuration = max(0, duration)
        let count = max(1, thumbnailCount)
        let segmentDuration = count > 0 ? cleanDuration / Double(count) : cleanDuration
        let segments = (0..<count).map { index in
            let start = Double(index) * segmentDuration
            let midpoint = min(start + (segmentDuration * 0.5), cleanDuration)
            return ScrubberTimelineSegment(
                id: index,
                start: CMTime(seconds: start, preferredTimescale: 600),
                duration: CMTime(seconds: segmentDuration, preferredTimescale: 600),
                thumbnailTime: CMTime(seconds: midpoint, preferredTimescale: 600)
            )
        }
        return ScrubberTimeline(duration: cleanDuration, segments: segments)
    }
}
