import MosaicScrubberCore
import MosaicScrubberMetal
import SwiftUI

struct FloatingPreviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isLivePulseVisible = false

    let renderer: MetalPreviewRenderer?
    let time: TimeInterval
    let currentTime: TimeInterval
    let resolvedPreviewSize: CGSize
    let anchorX: CGFloat
    let configuration: ScrubberConfiguration

    var body: some View {
        let theme = ScrubberResolvedTheme.resolve(configuration.visualTheme, colorScheme: colorScheme)

        VStack(spacing: 0) {
            previewSurface(theme: theme)
            anchor(theme: theme)
        }
        .shadow(color: theme.shadow, radius: theme.isDark ? 24 : 18, y: 14)
        .task {
            guard configuration.showsLiveIndicator else { return }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isLivePulseVisible = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Preview at \(TimecodeFormatter.string(from: time))")
    }

    private func previewSurface(theme: ScrubberResolvedTheme) -> some View {
        ZStack(alignment: .center) {
            Group {
                if let renderer {
                    MetalPreviewView(renderer: renderer)
                } else {
                    Rectangle()
                        .fill(.black)
                        .overlay {
                            Text("Preview unavailable")
                                .font(.caption)
                                .foregroundStyle(.white)
                        }
                }
            }
            .frame(width: resolvedPreviewSize.width, height: resolvedPreviewSize.height)
            .clipShape(.rect(cornerRadius: 8))

            LinearGradient(
                colors: [.black.opacity(theme.isDark ? 0.46 : 0.28), .clear],
                startPoint: .top,
                endPoint: .center
            )
            .clipShape(.rect(cornerRadius: 8))
            .allowsHitTesting(false)

            HStack(alignment: .top, spacing: 8) {
                if configuration.showsLiveIndicator {
                    liveIndicator(theme: theme)
                }

                Spacer(minLength: 8)

                if configuration.showsTimecode || configuration.showsTemporalDelta {
                    timecodeHUD(theme: theme)
                }
            }
            .frame(width: resolvedPreviewSize.width, height: resolvedPreviewSize.height)
            .clipShape(.rect(cornerRadius: 8))
            .padding(10)
        }
        .padding(4)
        .background(theme.previewChrome, in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(theme.previewStroke, lineWidth: 1)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(theme.accentGlow, lineWidth: theme.isDark ? 1.5 : 1)
                .blur(radius: 0.4)
        }
        .frame(width: resolvedPreviewSize.width, height: resolvedPreviewSize.height)
        .padding(4)
    }

    private func anchor(theme: ScrubberResolvedTheme) -> some View {
        ZStack(alignment: .topLeading) {
            anchorStem(theme: theme)
                .offset(x: clampedAnchorX - 1)

            anchorDot(theme: theme)
                .offset(x: clampedAnchorX - 4, y: 24)
        }
        .frame(width: previewChromeWidth, height: 36, alignment: .topLeading)
        .accessibilityHidden(true)
    }

    private func timecodeHUD(theme: ScrubberResolvedTheme) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            if configuration.showsTimecode {
                Text(TimecodeFormatter.string(from: time))
                    .font(.caption.monospacedDigit().weight(.semibold))
            }

            if configuration.showsTemporalDelta {
                Text(deltaText)
                    .font(.caption2.monospacedDigit().weight(.medium))
                    .foregroundStyle(theme.timecodeText.opacity(0.72))
            }
        }
        .foregroundStyle(theme.timecodeText)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(theme.timecodeBackground, in: .rect(cornerRadius: 8))
    }

    private func liveIndicator(theme: ScrubberResolvedTheme) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(theme.liveColor)
                .frame(width: 6, height: 6)
                .scaleEffect(isLivePulseVisible ? 1.35 : 0.85)
                .opacity(isLivePulseVisible ? 0.55 : 1)

            Text("LIVE")
                .font(.caption2.monospacedDigit().weight(.bold))
        }
        .foregroundStyle(theme.timecodeText)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(theme.timecodeBackground, in: .capsule)
    }

    private func anchorStem(theme: ScrubberResolvedTheme) -> some View {
        LinearGradient(
            colors: [theme.accent.opacity(theme.isDark ? 0.95 : 0.85), theme.accent.opacity(0)],
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(width: 2, height: 28)
        .accessibilityHidden(true)
    }

    private func anchorDot(theme: ScrubberResolvedTheme) -> some View {
        Circle()
            .fill(theme.accent)
            .frame(width: 8, height: 8)
            .overlay {
                Circle()
                    .stroke(theme.previewChrome, lineWidth: 3)
            }
            .shadow(color: theme.accentGlow, radius: 8)
            .accessibilityHidden(true)
    }

    private var deltaText: String {
        let delta = time - currentTime
        let sign = delta >= 0 ? "+" : "-"
        return "\(sign)\(TimecodeFormatter.string(from: abs(delta)))"
    }

    private var previewChromeWidth: CGFloat {
        resolvedPreviewSize.width + 8
    }

    private var clampedAnchorX: CGFloat {
        min(max(0, anchorX), previewChromeWidth)
    }
}
