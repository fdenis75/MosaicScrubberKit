import MosaicScrubberCore
import MosaicScrubberMetal
import SwiftUI

struct FloatingPreviewView: View {
    let renderer: MetalPreviewRenderer?
    let time: TimeInterval
    let configuration: ScrubberConfiguration

    var body: some View {
        VStack(spacing: 6) {
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
            .frame(width: configuration.previewSize.width, height: configuration.previewSize.height)
            .clipShape(.rect(cornerRadius: 8))

            if configuration.showsTimecode {
                Text(TimecodeFormatter.string(from: time))
                    .font(.caption.monospacedDigit())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.thinMaterial, in: .capsule)
            }
        }
        .shadow(radius: 16)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Preview at \(TimecodeFormatter.string(from: time))")
    }
}
