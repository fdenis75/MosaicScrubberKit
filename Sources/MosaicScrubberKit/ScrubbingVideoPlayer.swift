import AVKit
import MosaicScrubberCore
import MosaicScrubberMetal
import SwiftUI

public struct ScrubbingVideoPlayer: View {
    @State private var model: ScrubberViewModel
    private let onEvent: @Sendable (ScrubberEvent) -> Void

    public init(
        source: ScrubberVideoSource,
        player: AVPlayer,
        configuration: ScrubberConfiguration = .default,
        onEvent: @escaping @Sendable (ScrubberEvent) -> Void = { _ in }
    ) {
        self._model = State(initialValue: ScrubberViewModel(
            source: source,
            player: player,
            configuration: configuration
        ))
        self.onEvent = onEvent
    }

    public var body: some View {
        VStack(spacing: 10) {
            VideoPlayer(player: model.player)
                .clipShape(.rect(cornerRadius: 8))

            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    ThumbnailTimelineView(
                        thumbnails: model.thumbnails,
                        currentTime: model.currentTime,
                        hoveredTime: model.hoveredTime,
                        timeline: model.timeline,
                        configuration: model.configuration,
                        onHover: { normalized in
                            model.updateHover(normalized: normalized)
                            if let time = model.hoveredTime {
                                onEvent(.hoverChanged(time))
                            }
                        },
                        onHoverEnded: {
                            model.endHover()
                            onEvent(.hoverEnded)
                        },
                        onSeek: { normalized in
                            let time = model.timeline.time(forNormalizedPosition: normalized)
                            model.seek(normalized: normalized)
                            onEvent(.seekEnded(time))
                        }
                    )

                    if model.isPreviewVisible, let hoveredTime = model.hoveredTime {
                        preview(for: hoveredTime)
                            .offset(
                                x: previewOffset(for: hoveredTime, trackWidth: proxy.size.width),
                                y: -model.configuration.previewSize.height - 34
                            )
                            .transition(.opacity)
                    }
                }
            }
            .frame(height: model.configuration.trackHeight)
        }
        .task {
            model.load()
        }
        .onDisappear {
            model.tearDown()
        }
    }

    private func preview(for time: CMTime) -> some View {
        FloatingPreviewView(
            renderer: model.renderer,
            time: time.seconds,
            configuration: model.configuration
        )
    }

    private func previewOffset(for time: CMTime, trackWidth: CGFloat) -> CGFloat {
        let previewWidth = model.configuration.previewSize.width
        let normalized = model.timeline.normalizedPosition(for: time)
        let centered = (CGFloat(normalized) * trackWidth) - (previewWidth / 2)
        return min(max(0, centered), max(0, trackWidth - previewWidth))
    }
}
