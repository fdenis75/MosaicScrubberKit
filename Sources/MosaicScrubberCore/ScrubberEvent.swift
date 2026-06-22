import AVFoundation
import Foundation

public enum ScrubberEvent: Sendable {
    case hoverBegan(CMTime)
    case hoverChanged(CMTime)
    case hoverEnded
    case seekBegan(CMTime)
    case seekChanged(CMTime)
    case seekEnded(CMTime)
    case failed(String)
}
