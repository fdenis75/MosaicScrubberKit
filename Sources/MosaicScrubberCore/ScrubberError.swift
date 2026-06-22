import Foundation

public enum ScrubberError: LocalizedError, Sendable {
    case invalidDuration
    case noVideoTrack
    case thumbnailGenerationFailed(String)
    case metalUnavailable
    case rendererUnavailable(String)

    public var errorDescription: String? {
        switch self {
        case .invalidDuration:
            return "The video duration is invalid."
        case .noVideoTrack:
            return "The asset does not contain a video track."
        case .thumbnailGenerationFailed(let message):
            return "Thumbnail generation failed: \(message)"
        case .metalUnavailable:
            return "Metal is unavailable on this device."
        case .rendererUnavailable(let message):
            return "The preview renderer is unavailable: \(message)"
        }
    }
}
