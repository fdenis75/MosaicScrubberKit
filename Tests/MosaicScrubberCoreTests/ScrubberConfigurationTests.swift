import CoreGraphics
import Foundation
import Testing
@testable import MosaicScrubberCore

@Suite("Scrubber configuration tests")
struct ScrubberConfigurationTests {
    @Test("Configuration clamps invalid numeric values")
    func clampsInvalidValues() {
        let config = ScrubberConfiguration(
            thumbnailCount: 0,
            trackHeight: 10,
            previewSize: CGSize(width: 100, height: 50),
            maximumPreviewDuration: -1,
            seekTolerance: -1,
            hoverDebounce: -1,
            transitionDuration: -1,
            prefetchWindow: -2
        )

        #expect(config.thumbnailCount == 1)
        #expect(config.trackHeight == 44)
        #expect(config.maximumPreviewDuration == 0.1)
        #expect(config.seekTolerance == 0)
        #expect(config.prefetchWindow == 0)
    }

    @Test("Configuration round trips through Codable")
    func codableRoundTrip() throws {
        let config = ScrubberConfiguration.default
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(ScrubberConfiguration.self, from: data)

        #expect(decoded == config)
    }
}
