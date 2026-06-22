# Agent A: Package/API Architecture

Status: success. Read-only task completed; no files edited.

## Context Inspected

- MosaicKit `Package.swift`, README, generator protocols, Metal generator, preview coordinator/configuration, `VideoInput`, and `ThumbnailProcessor`.
- Architecture guidance from the Swift architecture skill.

## Key Findings

- MosaicKit is a single SPM library product/target with bundled Metal shaders.
- Actual platforms are macOS/iOS/macCatalyst v26.
- README confirms Metal-only architecture; CoreGraphics fallback and old wrapper/factory APIs were removed.
- Public MosaicKit APIs are generation/export oriented, not interactive UI oriented.
- `PreviewGeneratorCoordinator.generatePreviewComposition(...)` returns `AVPlayerItem`, but not a scrubber timeline.
- `ThumbnailProcessor` is public but shaped by mosaic layout and timestamp overlays, so it should not be the scrubber engine.

## Recommendation

Create sibling package `/Users/francois/Dev2026/Packages/MosaicScrubberKit`.

Dependency direction:

- MosaicKit must not depend on MosaicScrubberKit.
- MosaicScrubberKit main product should not require MosaicKit.
- An optional adapter target can depend on MosaicKit for `VideoInput` convenience.

Suggested public surface:

- `ScrubberVideoSource`
- `ScrubberConfiguration`
- `ScrubberEvent`
- `ScrubbingVideoPlayer`
- Optional MosaicKit adapter target with `ScrubberVideoSource.init(videoInput:)`.

## Risks

- Some MosaicKit DocC articles are stale. README and source are current truth.
- AVFoundation types require careful actor boundaries.
- Supporting lower OS versions in the main scrubber would conflict with MosaicKit v26 if the package depends on MosaicKit directly.
