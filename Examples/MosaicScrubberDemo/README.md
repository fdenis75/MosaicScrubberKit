# MosaicScrubberDemo

A macOS SwiftUI app that demonstrates `MosaicScrubberKit` with a local video file.

The right-hand settings panel lets you adjust the scrubber configuration while the app is running:

- Timeline density and track height
- High-density horizontal thumbnail scrolling
- Adaptive floating preview size
- Preview duration, Metal transition timing, hover debounce, and seek tolerance
- Visual theme, timecode, temporal delta, live indicator, film perforations, and hover spotlight
- Cache policy, cache size, and prefetch window

## Open

```bash
open Examples/MosaicScrubberDemo/MosaicScrubberDemo.xcodeproj
```

The project references the package at `../..`, so edits to `MosaicScrubberKit` are picked up by the demo app.
