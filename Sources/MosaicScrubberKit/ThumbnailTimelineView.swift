import AVFoundation
import MosaicScrubberCore
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct ThumbnailTimelineView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var playheadPulse = false
    @State private var scrollPosition = ScrollPosition(x: 0)
    @State private var scrollOffset: CGFloat = 0
    @State private var viewportWidth: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    @State private var edgeScrollVelocity: CGFloat = 0
    @State private var lastPointerX: CGFloat?
    @State private var autoScrollTask: Task<Void, Never>?

    let thumbnails: [TimelineThumbnail]
    let currentTime: CMTime
    let hoveredTime: CMTime?
    let timeline: ScrubberTimeline
    let configuration: ScrubberConfiguration
    let onHover: (Double, CGFloat) -> Void
    let onHoverEnded: () -> Void
    let onSeek: (Double) -> Void

    public var body: some View {
        let theme = ScrubberResolvedTheme.resolve(configuration.visualTheme, colorScheme: colorScheme)

        GeometryReader { proxy in
            let viewportWidth = max(1, proxy.size.width)
            let contentWidth = timelineContentWidth(viewportWidth: viewportWidth)

            ScrollView(.horizontal) {
                ZStack(alignment: .leading) {
                    thumbnailStrip(contentWidth: contentWidth, theme: theme)
                    if configuration.showsFilmPerforations {
                        filmPerforations(width: contentWidth, theme: theme)
                    }
                    playhead(width: contentWidth, theme: theme)
                    if let hoveredTime {
                        hoverIndicator(time: hoveredTime, width: contentWidth, theme: theme)
                    }
                }
                .frame(width: contentWidth, height: configuration.trackHeight, alignment: .leading)
                .contentShape(.rect)
            }
            .scrollPosition($scrollPosition)
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.x
            } action: { _, newOffset in
                scrollOffset = clampedScrollOffset(newOffset)
                refreshHoverForCurrentPointer()
            }
            .overlay(alignment: .leading) {
                edgeFade(theme: theme)
            }
            .contentShape(.rect)
            .simultaneousGesture(dragGesture(viewportWidth: viewportWidth))
            #if os(macOS)
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    updatePointer(at: location.x, viewportWidth: viewportWidth)
                case .ended:
                    endPointer()
                }
            }
            #endif
            .onAppear {
                updateScrollMetrics(viewportWidth: viewportWidth, contentWidth: contentWidth)
            }
            .onChange(of: viewportWidth) { _, newWidth in
                updateScrollMetrics(viewportWidth: newWidth, contentWidth: contentWidth)
            }
            .onChange(of: contentWidth) { _, newWidth in
                updateScrollMetrics(viewportWidth: viewportWidth, contentWidth: newWidth)
            }
            .onChange(of: currentTime.seconds) { _, _ in
                scrollToCurrentTimeIfNeeded()
            }
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
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(theme.previewStroke, lineWidth: 1)
        }
        .onDisappear {
            stopAutoScroll()
        }
    }

    private func thumbnailStrip(contentWidth: CGFloat, theme: ScrubberResolvedTheme) -> some View {
        HStack(spacing: 1) {
            if thumbnails.isEmpty {
                placeholderStrip(theme: theme)
            } else {
                ForEach(thumbnails) { thumbnail in
                    thumbnailView(thumbnail, theme: theme)
                }
            }
        }
        .frame(width: contentWidth, height: configuration.trackHeight, alignment: .leading)
        .background(theme.stripBackground)
    }

    private func thumbnailView(_ thumbnail: TimelineThumbnail, theme: ScrubberResolvedTheme) -> some View {
        let highlighted = isHighlighted(thumbnail)
        return Image(cgImage: thumbnail.image)
            .resizable()
            .scaledToFill()
            .frame(width: thumbnailWidth, height: configuration.trackHeight)
            .opacity(configuration.usesHoverSpotlight && hoveredTime != nil && !highlighted ? theme.nonHoveredThumbnailOpacity : 1)
            .scaleEffect(highlighted ? 1.05 : 1)
            .overlay {
                if highlighted {
                    Rectangle()
                        .stroke(theme.accent, lineWidth: 2)
                        .shadow(color: theme.accentGlow, radius: 6)
                }
            }
            .clipped()
            .animation(.easeOut(duration: 0.12), value: highlighted)
            .accessibilityHidden(true)
    }

    private func placeholderStrip(theme: ScrubberResolvedTheme) -> some View {
        ForEach(0..<max(1, configuration.thumbnailCount), id: \.self) { index in
            Rectangle()
                .fill(index.isMultiple(of: 2) ? theme.placeholderHighlight : theme.placeholderBase)
                .overlay {
                    shimmer(theme: theme)
                }
                .frame(width: thumbnailWidth, height: configuration.trackHeight)
                .accessibilityHidden(true)
        }
    }

    private func playhead(width: CGFloat, theme: ScrubberResolvedTheme) -> some View {
        let x = width * timeline.normalizedPosition(for: currentTime)
        return VStack(spacing: 0) {
            Circle()
                .fill(hoveredTime == nil ? theme.playhead : theme.accent)
                .frame(width: 6, height: 6)
                .scaleEffect(playheadPulse ? 1.4 : 1)
                .shadow(color: hoveredTime == nil ? .clear : theme.accentGlow, radius: 6)

            Rectangle()
                .fill(hoveredTime == nil ? theme.playhead : theme.accent)
                .frame(width: 2, height: max(0, configuration.trackHeight - 6))
                .shadow(color: hoveredTime == nil ? .clear : theme.accentGlow, radius: 6)
        }
            .offset(x: clampedIndicatorOffset(x, width: width, indicatorWidth: 6))
            .accessibilityHidden(true)
    }

    private func hoverIndicator(time: CMTime, width: CGFloat, theme: ScrubberResolvedTheme) -> some View {
        let x = width * timeline.normalizedPosition(for: time)
        return Rectangle()
            .fill(theme.accent.opacity(0.92))
            .frame(width: 2, height: configuration.trackHeight)
            .shadow(color: theme.accentGlow, radius: 8)
            .offset(x: clampedIndicatorOffset(x, width: width, indicatorWidth: 2))
            .accessibilityHidden(true)
    }

    private func filmPerforations(width: CGFloat, theme: ScrubberResolvedTheme) -> some View {
        let count = max(2, Int(width / 18))
        return VStack {
            perforationRow(count: count, theme: theme)
            Spacer(minLength: 0)
            perforationRow(count: count, theme: theme)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func perforationRow(count: Int, theme: ScrubberResolvedTheme) -> some View {
        HStack {
            ForEach(0..<count, id: \.self) { _ in
                Circle()
                    .fill(theme.perforation)
                    .frame(width: 4, height: 4)
                Spacer(minLength: 0)
            }
        }
    }

    private func shimmer(theme: ScrubberResolvedTheme) -> some View {
        LinearGradient(
            colors: [.clear, theme.perforation.opacity(theme.isDark ? 0.40 : 0.30), .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.45)
        .blendMode(theme.isDark ? .screen : .multiply)
    }

    private func edgeFade(theme: ScrubberResolvedTheme) -> some View {
        HStack(spacing: 0) {
            LinearGradient(
                colors: [theme.stripBackground.opacity(scrollOffset > 1 ? 0.85 : 0), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 32)

            Spacer(minLength: 0)

            LinearGradient(
                colors: [.clear, theme.stripBackground.opacity(scrollOffset < maxScrollOffset - 1 ? 0.85 : 0)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 32)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func dragGesture(viewportWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                updatePointer(at: value.location.x, viewportWidth: viewportWidth)
            }
            .onEnded { value in
                let value = normalized(locationX: value.location.x)
                if configuration.commitsSeekOnDragEnd {
                    onSeek(value)
                    triggerSeekFeedback()
                }
                endPointer()
            }
    }

    private func updateScrollMetrics(viewportWidth: CGFloat, contentWidth: CGFloat) {
        self.viewportWidth = viewportWidth
        self.contentWidth = contentWidth
        let clampedOffset = clampedScrollOffset(scrollOffset)
        if clampedOffset != scrollOffset {
            scrollOffset = clampedOffset
            scrollPosition.scrollTo(x: clampedOffset)
        }
        scrollToCurrentTimeIfNeeded()
    }

    private func updatePointer(at locationX: CGFloat, viewportWidth: CGFloat) {
        let clampedX = min(max(0, locationX), viewportWidth)
        lastPointerX = clampedX
        edgeScrollVelocity = edgeVelocity(for: clampedX, viewportWidth: viewportWidth)
        onHover(normalized(locationX: clampedX), clampedX)

        if edgeScrollVelocity == 0 {
            stopAutoScroll()
        } else {
            startAutoScrollIfNeeded()
        }
    }

    private func endPointer() {
        lastPointerX = nil
        edgeScrollVelocity = 0
        stopAutoScroll()
        onHoverEnded()
    }

    private func refreshHoverForCurrentPointer() {
        guard let lastPointerX else { return }
        onHover(normalized(locationX: lastPointerX), lastPointerX)
    }

    private func normalized(locationX: CGFloat) -> Double {
        guard contentWidth > 0 else { return 0 }
        let contentX = min(max(0, scrollOffset + locationX), contentWidth)
        return min(max(Double(contentX / contentWidth), 0), 1)
    }

    private func edgeVelocity(for locationX: CGFloat, viewportWidth: CGFloat) -> CGFloat {
        guard maxScrollOffset > 0 else { return 0 }

        let edgeWidth = min(160, max(64, viewportWidth * 0.18))
        let maximumSpeed = max(420, viewportWidth * 1.35)

        if locationX < edgeWidth {
            let progress = min(max((edgeWidth - locationX) / edgeWidth, 0), 1)
            return -maximumSpeed * pow(progress, 1.55)
        }

        if locationX > viewportWidth - edgeWidth {
            let progress = min(max((locationX - (viewportWidth - edgeWidth)) / edgeWidth, 0), 1)
            return maximumSpeed * pow(progress, 1.55)
        }

        return 0
    }

    private func startAutoScrollIfNeeded() {
        guard autoScrollTask == nil else { return }

        autoScrollTask = Task { @MainActor in
            var lastTick = Date()
            while !Task.isCancelled {
                let now = Date()
                let delta = now.timeIntervalSince(lastTick)
                lastTick = now

                if edgeScrollVelocity == 0 {
                    break
                }

                let nextOffset = clampedScrollOffset(scrollOffset + edgeScrollVelocity * delta)
                if nextOffset != scrollOffset {
                    scrollOffset = nextOffset
                    scrollPosition.scrollTo(x: nextOffset)
                    refreshHoverForCurrentPointer()
                }

                if nextOffset == 0 || nextOffset == maxScrollOffset {
                    edgeScrollVelocity = 0
                    break
                }

                try? await Task.sleep(for: .milliseconds(16))
            }
            autoScrollTask = nil
        }
    }

    private func stopAutoScroll() {
        autoScrollTask?.cancel()
        autoScrollTask = nil
    }

    private func scrollToCurrentTimeIfNeeded() {
        guard lastPointerX == nil, maxScrollOffset > 0, viewportWidth > 0, contentWidth > 0 else { return }

        let playheadX = contentWidth * timeline.normalizedPosition(for: currentTime)
        let inset = min(96, viewportWidth * 0.20)
        let visibleStart = scrollOffset + inset
        let visibleEnd = scrollOffset + viewportWidth - inset

        guard playheadX < visibleStart || playheadX > visibleEnd else { return }

        scrollToOffset(playheadX - viewportWidth / 2)
    }

    private func scrollToOffset(_ offset: CGFloat) {
        let nextOffset = clampedScrollOffset(offset)
        guard nextOffset != scrollOffset else { return }
        scrollOffset = nextOffset
        withAnimation(.snappy(duration: 0.24)) {
            scrollPosition.scrollTo(x: nextOffset)
        }
    }

    private func timelineContentWidth(viewportWidth: CGFloat) -> CGFloat {
        let itemCount = max(1, thumbnails.isEmpty ? configuration.thumbnailCount : thumbnails.count)
        let spacing = CGFloat(max(0, itemCount - 1))
        let width = CGFloat(itemCount) * thumbnailWidth + spacing
        return max(viewportWidth, width)
    }

    private var thumbnailWidth: CGFloat {
        max(96, configuration.trackHeight * 16.0 / 9.0)
    }

    private var maxScrollOffset: CGFloat {
        max(0, contentWidth - viewportWidth)
    }

    private func clampedScrollOffset(_ offset: CGFloat) -> CGFloat {
        min(max(0, offset), maxScrollOffset)
    }

    private func isHighlighted(_ thumbnail: TimelineThumbnail) -> Bool {
        guard configuration.usesHoverSpotlight, let hoveredTime else { return false }
        return timeline.segment(containing: hoveredTime)?.id == thumbnail.id
    }

    private func clampedIndicatorOffset(_ x: CGFloat, width: CGFloat, indicatorWidth: CGFloat) -> CGFloat {
        min(max(0, x - indicatorWidth / 2), max(0, width - indicatorWidth))
    }

    private func triggerSeekFeedback() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif

        Task { @MainActor in
            withAnimation(.easeOut(duration: 0.075)) {
                playheadPulse = true
            }
            try? await Task.sleep(for: .milliseconds(75))
            withAnimation(.easeIn(duration: 0.075)) {
                playheadPulse = false
            }
        }
    }

    private var accessibilityValue: String {
        "\(TimecodeFormatter.string(from: currentTime.seconds)) of \(TimecodeFormatter.string(from: timeline.duration))"
    }
}
