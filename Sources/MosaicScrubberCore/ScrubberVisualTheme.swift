import Foundation

/// Visual theme selection for MosaicScrubberKit's timeline and floating preview.
public enum ScrubberVisualTheme: String, Codable, Hashable, Sendable {
    /// Follows the surrounding SwiftUI color scheme.
    case automatic

    /// Dark, pro-video treatment with carbon surfaces and electric-blue active cues.
    case obsidianFlux

    /// Light, technical treatment with white glass surfaces and pro-blue active cues.
    case obsidianFluxLight
}
