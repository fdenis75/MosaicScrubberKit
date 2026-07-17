import AVKit
import MosaicScrubberCore
import MosaicScrubberMetal
import SwiftUI

public struct ScrubbingVideoPlayer: View {
    @State private var model: ScrubberViewModel
    @State private var hoveredTrackX: CGFloat?
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
                let resolvedPreviewSize = model.configuration.previewSize.resolvedDimensions(
                    videoSize: model.source.naturalSize,
                    availablePlayerSize: proxy.size
                )

                ZStack(alignment: .topLeading) {
                    ThumbnailTimelineView(
                        thumbnails: model.thumbnails,
                        currentTime: model.currentTime,
                        hoveredTime: model.hoveredTime,
                        timeline: model.timeline,
                        configuration: model.configuration,
                        onHover: { normalized, localX in
                            hoveredTrackX = localX
                            model.updateHover(normalized: normalized)
                            if let time = model.hoveredTime {
                                onEvent(.hoverChanged(time))
                            }
                        },
                        onHoverEnded: {
                            hoveredTrackX = nil
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
                        let previewWidth = floatingPreviewWidth(for: resolvedPreviewSize)
                        let sourceX = hoveredTrackX ?? timelineX(for: hoveredTime, trackWidth: proxy.size.width)
                        let previewX = previewOffset(
                            forTrackX: sourceX,
                            trackWidth: proxy.size.width,
                            previewWidth: previewWidth
                        )
                        let anchorX = previewAnchorX(
                            forTrackX: sourceX,
                            previewOffset: previewX,
                            previewWidth: previewWidth
                        )

                        preview(for: hoveredTime, resolvedPreviewSize: resolvedPreviewSize, anchorX: anchorX)
                            .offset(
                                x: previewX,
                                y: -floatingPreviewHeight(for: resolvedPreviewSize) - 10
                            )
                            .transition(
                                .asymmetric(
                                    insertion: .opacity
                                        .combined(with: .scale(scale: 0.96, anchor: .bottom))
                                        .combined(with: .offset(y: 12)),
                                    removal: .opacity
                                        .combined(with: .scale(scale: 0.98, anchor: .bottom))
                                )
                            )
                    }
                }
            }
            .frame(height: model.configuration.trackHeight)
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.82), value: model.isPreviewVisible)
        .task {
            model.load()
        }
        .onDisappear {
            model.tearDown()
        }
    }

    private func preview(for time: CMTime, resolvedPreviewSize: CGSize, anchorX: CGFloat) -> some View {
        FloatingPreviewView(
            renderer: model.renderer,
            time: time.seconds,
            currentTime: model.currentTime.seconds,
            resolvedPreviewSize: resolvedPreviewSize,
            anchorX: anchorX,
            configuration: model.configuration
        )
    }

    private func previewOffset(forTrackX trackX: CGFloat, trackWidth: CGFloat, previewWidth: CGFloat) -> CGFloat {
        let centered = trackX - (previewWidth / 2)
        return min(max(0, centered), max(0, trackWidth - previewWidth))
    }

    private func previewAnchorX(forTrackX trackX: CGFloat, previewOffset: CGFloat, previewWidth: CGFloat) -> CGFloat {
        min(max(0, trackX - previewOffset), previewWidth)
    }

    private func timelineX(for time: CMTime, trackWidth: CGFloat) -> CGFloat {
        let normalized = model.timeline.normalizedPosition(for: time)
        return CGFloat(normalized) * trackWidth
    }

    private func floatingPreviewWidth(for resolvedPreviewSize: CGSize) -> CGFloat {
        resolvedPreviewSize.width + 8
    }

    private func floatingPreviewHeight(for resolvedPreviewSize: CGSize) -> CGFloat {
        resolvedPreviewSize.height + 44
    }
}
