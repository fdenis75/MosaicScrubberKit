import AVFoundation
import Testing
@testable import MosaicScrubberKit
import MosaicScrubberCore

@Suite("ScrubbingVideoPlayer API tests")
@MainActor
struct ScrubbingVideoPlayerTests {
    @Test("View can be initialized with source and player")
    func initializes() {
        let url = URL(fileURLWithPath: "/tmp/sample.mp4")
        let source = ScrubberVideoSource(url: url, duration: 60)
        let player = AVPlayer()
        _ = ScrubbingVideoPlayer(source: source, player: player)
        #expect(source.duration == 60)
    }
}
