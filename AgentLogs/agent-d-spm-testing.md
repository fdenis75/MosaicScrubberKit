# Agent D: SwiftPM + Testing Strategy

Status: success. Read-only task completed; no files edited.

## Context

- MosaicKit manifest uses Swift tools 6.2 and platforms macOS/iOS/macCatalyst v26.
- Existing tests use Swift Testing with `@Test`, `#expect`, async tests, temp directories, and environment-gated long suites.

## Package Layout

- `MosaicScrubberCore`: timeline math, mapping, configuration, cache policy, thumbnail generation.
- `MosaicScrubberMetal`: shader loading, texture bridge, renderer.
- `MosaicScrubberKit`: SwiftUI/AVKit public views.
- `MosaicScrubberMosaicKit`: optional adapter to MosaicKit.

## Tests

- Fast unit tests: defaults, Codable models, time mapping, request planning, cache policy.
- Async tests: fake frame provider/progress callbacks/cancellation where possible.
- AVFoundation integration tests should be gated by env var.
- Metal tests should be gated and small.
- SwiftUI gesture and visual smoothness require example host app or UI tests, not only SwiftPM tests.

## Commands

```bash
swift build
swift test --parallel
SCRUBBER_INTEGRATION_RUN=1 swift test --filter AVFoundationIntegrationTests
SCRUBBER_METAL_RUN=1 swift test --filter MosaicScrubberMetalTests
```
