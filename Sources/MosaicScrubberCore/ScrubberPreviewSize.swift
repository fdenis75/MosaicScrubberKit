import CoreGraphics
import Foundation

/// Size intent for the floating preview.
public enum ScrubberPreviewSize: String, Codable, Hashable, Sendable {
    case small
    case medium
    case large

    public func resolvedDimensions(videoSize: CGSize?, availablePlayerSize: CGSize) -> CGSize {
        let aspectRatio = Self.aspectRatio(for: videoSize)
        let availableWidth = max(availablePlayerSize.width, 1)
        let maximumWidth = min(baseLongEdge, availableWidth * maximumWidthFraction)
        let minimumShortEdge = minShortEdge

        if aspectRatio >= 1 {
            var width = maximumWidth
            var height = width / aspectRatio
            if height < minimumShortEdge {
                height = minimumShortEdge
                width = min(maximumWidth, height * aspectRatio)
            }
            return CGSize(width: width.rounded(), height: height.rounded())
        }

        var height = min(baseLongEdge, availableWidth * maximumPortraitHeightFraction)
        var width = height * aspectRatio
        if width > maximumWidth {
            width = maximumWidth
            height = width / aspectRatio
        }
        return CGSize(width: width.rounded(), height: height.rounded())
    }

    static func nearest(to legacySize: CGSize) -> ScrubberPreviewSize {
        let longEdge = max(abs(legacySize.width), abs(legacySize.height))
        return allCases.min { first, second in
            abs(first.baseLongEdge - longEdge) < abs(second.baseLongEdge - longEdge)
        } ?? .medium
    }

    private var baseLongEdge: Double {
        switch self {
        case .small:
            return 200
        case .medium:
            return 300
        case .large:
            return 420
        }
    }

    private var maximumWidthFraction: Double {
        switch self {
        case .small:
            return 0.34
        case .medium:
            return 0.46
        case .large:
            return 0.58
        }
    }

    private var maximumPortraitHeightFraction: Double {
        switch self {
        case .small:
            return 0.42
        case .medium:
            return 0.56
        case .large:
            return 0.70
        }
    }

    private var minShortEdge: Double {
        switch self {
        case .small:
            return 76
        case .medium:
            return 96
        case .large:
            return 120
        }
    }

    private static func aspectRatio(for videoSize: CGSize?) -> Double {
        guard let videoSize else { return 16.0 / 9.0 }
        let width = abs(videoSize.width)
        let height = abs(videoSize.height)
        guard width > 0, height > 0 else { return 16.0 / 9.0 }
        return width / height
    }
}

extension ScrubberPreviewSize: CaseIterable {}
