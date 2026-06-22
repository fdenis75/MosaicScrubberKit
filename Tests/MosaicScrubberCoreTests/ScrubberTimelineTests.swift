import AVFoundation
import Testing
@testable import MosaicScrubberCore

@Suite("Scrubber timeline tests")
struct ScrubberTimelineTests {
    @Test("Timeline planner creates evenly spaced segments")
    func plannerCreatesSegments() {
        let timeline = ScrubberTimelinePlanner.makeTimeline(duration: 120, thumbnailCount: 4)

        #expect(timeline.duration == 120)
        #expect(timeline.segments.count == 4)
        #expect(timeline.segments[0].start.seconds == 0)
        #expect(timeline.segments[1].start.seconds == 30)
        #expect(timeline.segments[0].thumbnailTime.seconds == 15)
    }

    @Test("Timeline clamps normalized positions")
    func timelineClampsPositions() {
        let timeline = ScrubberTimelinePlanner.makeTimeline(duration: 100, thumbnailCount: 10)

        #expect(timeline.time(forNormalizedPosition: -1).seconds == 0)
        #expect(timeline.time(forNormalizedPosition: 2).seconds == 100)
        #expect(timeline.time(forNormalizedPosition: 0.25).seconds == 25)
    }

    @Test("Timecode formatter uses compact format below one hour")
    func timecodeFormatting() {
        #expect(TimecodeFormatter.string(from: 0) == "00:00")
        #expect(TimecodeFormatter.string(from: 65.9) == "01:05")
        #expect(TimecodeFormatter.string(from: 3_723.4) == "01:02:03")
    }
}
