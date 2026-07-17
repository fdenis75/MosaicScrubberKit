# MosaicScrubberKit

Interactive SwiftUI video scrubbing for Apple platforms.

MosaicScrubberKit provides a thumbnail timeline below an `AVPlayer` and a Metal-backed floating preview that can play a short muted preview window from the current hover or drag position. High-density timelines scroll horizontally, with edge autoscroll while hovering or dragging near the strip boundaries.

The default visual treatment follows the surrounding SwiftUI color scheme with the Obsidian Flux design system: a carbon, pro-video dark theme and a bright, technical light theme. Both include a living filmstrip, themed playhead, animated cinema loupe, anchor stem, live chip, and monospaced timecode HUD.

## Design

- `MosaicScrubberCore`: timeline math, configuration, cache policy, and AVFoundation thumbnail extraction.
- `MosaicScrubberMetal`: `MTKView` rendering and `CVPixelBuffer` to Metal texture bridging.
- `MosaicScrubberKit`: SwiftUI/AVKit component surface.
- `MosaicScrubberMosaicKit`: optional adapter from MosaicKit `VideoInput`.

The main scrubber does not require MosaicKit. The adapter target keeps MosaicKit as a one-way optional integration.

## Basic Usage

```swift
import AVFoundation
import MosaicScrubberKit
import SwiftUI

struct PlayerScreen: View {
    let source: ScrubberVideoSource
    @State private var player: AVPlayer

    init(url: URL) {
        self.source = ScrubberVideoSource(url: url)
        self._player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        ScrubbingVideoPlayer(source: source, player: player)
    }
}
```

## Visual Configuration

```swift
let configuration = ScrubberConfiguration(
    thumbnailCount: 56,
    trackHeight: 72,
    previewSize: .large,
    visualTheme: .automatic
)

ScrubbingVideoPlayer(
    source: source,
    player: player,
    configuration: configuration
)
```

Use `.obsidianFlux` to force the dark pro-video theme, `.obsidianFluxLight` to force the light technical theme, or `.automatic` to follow SwiftUI's color scheme.

`previewSize` is an adaptive preset: `.small`, `.medium`, or `.large`. MosaicScrubberKit resolves the actual floating preview dimensions from the selected preset, the current player width, and the source video's natural aspect ratio, so vertical and ultrawide videos keep a matching preview shape.

## Verification

```bash
swift build
swift test --parallel
```
