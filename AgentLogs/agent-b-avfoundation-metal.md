# Agent B: AVFoundation + Metal Preview Pipeline

Status: success. Read-only task completed; no files edited.

## APIs Considered

- `AVAssetImageGenerator` for static thumbnail strip generation.
- `AVPlayerItemVideoOutput` for decoded frame pull from a preview player item.
- `copyPixelBuffer(forItemTime:itemTimeForDisplay:)` and `hasNewPixelBuffer(forItemTime:)`.
- `MTKView` / `MTKViewDelegate` for the floating Metal preview surface.
- `CVMetalTextureCacheCreateTextureFromImage` and `CVMetalTextureGetTexture`.

## Recommended Data Flow

1. Main SwiftUI view uses `VideoPlayer`.
2. Thumbnail strip uses `AVAssetImageGenerator` with preferred track transform and bounded `maximumSize`.
3. Hover maps strip x-position to `CMTime`.
4. A separate muted preview `AVPlayer` seeks to hover time and plays for up to 1.5 seconds.
5. Attach `AVPlayerItemVideoOutput` to the preview item, not the main item.
6. `MTKView` pulls pixel buffers, bridges them to Metal textures, and draws a textured quad.
7. Keep old and new textures for crossfades during seek transitions.

## Threading and Cancellation

- Keep SwiftUI and `AVPlayer` control on `@MainActor`.
- Put thumbnail work behind an actor or cancellable task.
- Cancel thumbnail work and pause preview player on disappear or asset change.
- Coalesce hover updates; do not create a new player per hover.

## Metal Lifetime Notes

- Do not return only `MTLTexture` from a temporary `CVMetalTexture`.
- Retain `CVPixelBuffer`, `CVMetalTexture`, and `MTLTexture` in a frame object.
- Keep current/previous frames alive until command buffer completion.
- Request BGRA pixel buffers for a simple first version.
- Avoid `getBytes` or `CGImage` creation in the hover render loop.

## Risks

- Seek latency depends on codec/GOP/storage.
- Exact seeks can be expensive; tolerant seeking should be configurable.
- HDR, wide color, rotation, and YCbCr need explicit handling beyond the first pass.
