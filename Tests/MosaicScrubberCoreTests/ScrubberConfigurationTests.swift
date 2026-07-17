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
            previewSize: .small,
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
        #expect(config.hoverDebounce == 0)
        #expect(config.transitionDuration == 0)
        #expect(config.prefetchWindow == 0)
    }

    @Test("Configuration round trips through Codable")
    func codableRoundTrip() throws {
        let config = ScrubberConfiguration.default
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(ScrubberConfiguration.self, from: data)

        #expect(decoded == config)
    }

    @Test("Configuration decodes defaults for newer visual options")
    func decodesLegacyConfigurationDefaults() throws {
        let data = Data("""
        {
          "thumbnailCount": 24,
          "trackHeight": 72,
          "maximumPreviewDuration": 1.0,
          "seekTolerance": 0.2,
          "hoverDebounce": 0.04,
          "transitionDuration": 0.1,
          "showsTimecode": true,
          "commitsSeekOnDragEnd": true,
          "prefetchWindow": 2,
          "cachePolicy": { "memory": { "maxItems": 12 } }
        }
        """.utf8)

        let decoded = try JSONDecoder().decode(ScrubberConfiguration.self, from: data)

        #expect(decoded.thumbnailCount == 24)
        #expect(decoded.visualTheme == .automatic)
        #expect(decoded.showsTemporalDelta)
        #expect(decoded.showsLiveIndicator)
        #expect(decoded.showsFilmPerforations)
        #expect(decoded.usesHoverSpotlight)
    }

    @Test("Visual theme round trips through Codable")
    func visualThemeRoundTrip() throws {
        let config = ScrubberConfiguration(visualTheme: .obsidianFluxLight)
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(ScrubberConfiguration.self, from: data)

        #expect(decoded.visualTheme == .obsidianFluxLight)
    }

    @Test("Preview preset adapts to vertical video aspect ratio")
    func previewPresetAdaptsToVerticalVideo() {
        let dimensions = ScrubberPreviewSize.medium.resolvedDimensions(
            videoSize: CGSize(width: 1080, height: 1920),
            availablePlayerSize: CGSize(width: 900, height: 500)
        )

        #expect(dimensions.height > dimensions.width)
        #expect(dimensions.height <= 300)
    }

    @Test("Preview preset adapts to ultrawide video aspect ratio")
    func previewPresetAdaptsToUltrawideVideo() {
        let dimensions = ScrubberPreviewSize.large.resolvedDimensions(
            videoSize: CGSize(width: 3840, height: 1080),
            availablePlayerSize: CGSize(width: 500, height: 300)
        )

        #expect(dimensions.width > dimensions.height)
        #expect(dimensions.width <= 290)
        #expect(dimensions.height >= 80)
    }

    @Test("Legacy fixed preview size maps to nearest preset")
    func legacyFixedPreviewSizeMapsToPreset() throws {
        let data = Data("""
        {
          "thumbnailCount": 24,
          "trackHeight": 72,
          "previewSize": [420, 236],
          "maximumPreviewDuration": 1.0,
          "seekTolerance": 0.2,
          "hoverDebounce": 0.04,
          "transitionDuration": 0.1,
          "showsTimecode": true,
          "commitsSeekOnDragEnd": true,
          "prefetchWindow": 2,
          "cachePolicy": { "memory": { "maxItems": 12 } }
        }
        """.utf8)

        let decoded = try JSONDecoder().decode(ScrubberConfiguration.self, from: data)

        #expect(decoded.previewSize == .large)
    }
}
