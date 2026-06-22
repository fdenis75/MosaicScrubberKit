import AVFoundation
import MosaicScrubberCore
import SwiftUI

public struct ThumbnailTimelineView: View {
    let thumbnails: [TimelineThumbnail]
    let currentTime: CMTime
    let hoveredTime: CMTime?
    let timeline: ScrubberTimeline
    let configuration: ScrubberConfiguration
    let onHover: (Double) -> Void
    let onHoverEnded: () -> Void
    let onSeek: (Double) -> Void

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                thumbnailStrip
                playhead(width: proxy.size.width)
                if let hoveredTime {
                    hoverIndicator(time: hoveredTime, width: proxy.size.width)
                }
            }
            .contentShape(.rect)
            .gesture(dragGesture(width: proxy.size.width))
            #if os(macOS)
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    onHover(normalized(location.x, width: proxy.size.width))
                case .ended:
                    onHoverEnded()
                }
            }
            #endif
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Video position")
            .accessibilityValue(accessibilityValue)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    onSeek(timeline.normalizedPosition(for: currentTime + CMTime(seconds: 10, preferredTimescale: 600)))
                case .decrement:
                    onSeek(timeline.normalizedPosition(for: currentTime - CMTime(seconds: 10, preferredTimescale: 600)))
                @unknown default:
                    break
                }
            }
        }
        .frame(height: configuration.trackHeight)
        .clipShape(.rect(cornerRadius: 8))
    }

    private var thumbnailStrip: some View {
        HStack(spacing: 1) {
            if thumbnails.isEmpty {
                placeholderStrip
            } else {
                ForEach(thumbnails) { thumbnail in
                    Image(cgImage: thumbnail.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: configuration.trackHeight)
                        .clipped()
                        .accessibilityHidden(true)
                }
            }
        }
        .background(.secondary.opacity(0.18))
    }

    private var placeholderStrip: some View {
        ForEach(0..<max(1, configuration.thumbnailCount), id: \.self) { index in
            Rectangle()
                .fill(Color.secondary.opacity(index.isMultiple(of: 2) ? 0.22 : 0.14))
                .frame(maxWidth: .infinity)
                .frame(height: configuration.trackHeight)
                .accessibilityHidden(true)
        }
    }

    private func playhead(width: CGFloat) -> some View {
        Rectangle()
            .fill(.primary)
            .frame(width: 2, height: configuration.trackHeight)
            .offset(x: width * timeline.normalizedPosition(for: currentTime))
            .accessibilityHidden(true)
    }

    private func hoverIndicator(time: CMTime, width: CGFloat) -> some View {
        Rectangle()
            .fill(.white.opacity(0.85))
            .frame(width: 2, height: configuration.trackHeight)
            .offset(x: width * timeline.normalizedPosition(for: time))
            .accessibilityHidden(true)
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                onHover(normalized(value.location.x, width: width))
            }
            .onEnded { value in
                let value = normalized(value.location.x, width: width)
                if configuration.commitsSeekOnDragEnd {
                    onSeek(value)
                }
                onHoverEnded()
            }
    }

    private func normalized(_ x: CGFloat, width: CGFloat) -> Double {
        guard width > 0 else { return 0 }
        return min(max(Double(x / width), 0), 1)
    }

    private var accessibilityValue: String {
        "\(TimecodeFormatter.string(from: currentTime.seconds)) of \(TimecodeFormatter.string(from: timeline.duration))"
    }
}
