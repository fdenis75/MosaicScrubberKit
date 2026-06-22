# Agent C: SwiftUI Interaction + UX

Status: success. Read-only task completed; no files edited.

## Findings

- `VideoPlayer` is appropriate for the main player.
- Current MosaicKit preview composition returns `AVPlayerItem`, but not segment timing metadata.
- Existing thumbnail helpers are evenly-spaced and not tied to preview composition segments.

## State Model

- Parent owns `AVPlayer` and source identity.
- A `@MainActor @Observable` model should own stable state such as duration, current time, thumbnails, loading, and errors.
- High-frequency pointer and drag coordinates should not be broad observable state.
- The preview renderer should receive high-frequency updates imperatively.

## Input Handling

- macOS/iPad pointer: continuous hover maps x-position to time.
- iPhone: no hover; show preview during long press or drag.
- Drag should commit seek on end by default; live seeking should be throttled.
- For source playback, `time = normalized * duration`.
- For future preview-composition playback, map composition time through public segment metadata.

## Accessibility

- Expose scrubber as an adjustable control.
- Provide labels and values such as current time and duration.
- Add custom actions: previous thumbnail, next thumbnail, preview from here, seek here.
- Support keyboard arrows, space, and escape.
- Respect Reduce Motion.
- Keep hit regions at least 44 x 44 pt.

## Performance Guidance

- Do not store raw hover coordinates in `@Observable` properties read by the view tree.
- Do not put scrub position in Environment.
- Cache thumbnails outside view bodies.
- Use fixed tile sizes and stable IDs.
- Use periodic player observation at UI cadence, not frame cadence.
