# MosaicScrubberKit

Interactive SwiftUI video scrubbing for Apple platforms.

MosaicScrubberKit provides a thumbnail timeline below an `AVPlayer` and a Metal-backed floating preview that can play a short muted preview window from the current hover or drag position.

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

## Verification

```bash
swift build
swift test --parallel
```
