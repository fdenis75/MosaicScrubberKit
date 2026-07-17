import MosaicScrubberCore
import SwiftUI

struct ScrubberResolvedTheme {
    let isDark: Bool
    let accent: Color
    let accentGlow: Color
    let stripBackground: Color
    let placeholderBase: Color
    let placeholderHighlight: Color
    let primaryText: Color
    let secondaryText: Color
    let previewChrome: Color
    let previewStroke: Color
    let timecodeBackground: Color
    let timecodeText: Color
    let liveColor: Color
    let playhead: Color
    let perforation: Color
    let shadow: Color
    let nonHoveredThumbnailOpacity: Double

    static func resolve(_ theme: ScrubberVisualTheme, colorScheme: ColorScheme) -> ScrubberResolvedTheme {
        switch theme {
        case .automatic:
            return colorScheme == .dark ? .obsidianFlux : .obsidianFluxLight
        case .obsidianFlux:
            return .obsidianFlux
        case .obsidianFluxLight:
            return .obsidianFluxLight
        }
    }

    private static let obsidianFlux = ScrubberResolvedTheme(
        isDark: true,
        accent: Color(red: 41.0 / 255.0, green: 151.0 / 255.0, blue: 1.0),
        accentGlow: Color(red: 41.0 / 255.0, green: 151.0 / 255.0, blue: 1.0).opacity(0.40),
        stripBackground: Color(red: 28.0 / 255.0, green: 28.0 / 255.0, blue: 30.0 / 255.0),
        placeholderBase: Color.white.opacity(0.08),
        placeholderHighlight: Color.white.opacity(0.16),
        primaryText: Color(red: 229.0 / 255.0, green: 226.0 / 255.0, blue: 225.0 / 255.0),
        secondaryText: Color(red: 192.0 / 255.0, green: 199.0 / 255.0, blue: 213.0 / 255.0),
        previewChrome: Color(red: 14.0 / 255.0, green: 14.0 / 255.0, blue: 14.0 / 255.0).opacity(0.78),
        previewStroke: Color.white.opacity(0.10),
        timecodeBackground: Color.black.opacity(0.72),
        timecodeText: .white,
        liveColor: Color(red: 1.0, green: 69.0 / 255.0, blue: 58.0 / 255.0),
        playhead: .white,
        perforation: Color.white.opacity(0.20),
        shadow: Color.black.opacity(0.50),
        nonHoveredThumbnailOpacity: 0.60
    )

    private static let obsidianFluxLight = ScrubberResolvedTheme(
        isDark: false,
        accent: Color(red: 0.0, green: 122.0 / 255.0, blue: 1.0),
        accentGlow: Color(red: 0.0, green: 122.0 / 255.0, blue: 1.0).opacity(0.16),
        stripBackground: Color(red: 246.0 / 255.0, green: 243.0 / 255.0, blue: 242.0 / 255.0),
        placeholderBase: Color.black.opacity(0.04),
        placeholderHighlight: Color.black.opacity(0.09),
        primaryText: Color(red: 19.0 / 255.0, green: 19.0 / 255.0, blue: 19.0 / 255.0),
        secondaryText: Color(red: 92.0 / 255.0, green: 92.0 / 255.0, blue: 92.0 / 255.0),
        previewChrome: Color.white.opacity(0.72),
        previewStroke: Color.black.opacity(0.08),
        timecodeBackground: Color.black.opacity(0.80),
        timecodeText: .white,
        liveColor: Color(red: 186.0 / 255.0, green: 26.0 / 255.0, blue: 26.0 / 255.0),
        playhead: Color(red: 19.0 / 255.0, green: 19.0 / 255.0, blue: 19.0 / 255.0),
        perforation: Color.black.opacity(0.15),
        shadow: Color.black.opacity(0.08),
        nonHoveredThumbnailOpacity: 0.75
    )
}
