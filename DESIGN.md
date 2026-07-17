# MosaicScrubberKit Design

MosaicScrubberKit is a SwiftUI video scrubbing component for Apple-platform apps. It is designed to be embedded below a video player and provide the interaction people expect from modern media apps: a thumbnail timeline, hover or drag preview, visible playback position, and a short Metal-rendered floating preview from the selected moment.

The package is not a full video player shell. It owns the scrubber experience around an app-provided `AVPlayer`, so the host app remains responsible for screen layout, playback controls, routing, subtitles, audio, persistence, and file access.

## What It Displays

`ScrubbingVideoPlayer` is the primary app-facing SwiftUI view. It displays:

- The app-provided `AVPlayer` using SwiftUI `VideoPlayer`.
- A horizontal thumbnail timeline below the player.
- A current-time playhead drawn over the thumbnail strip.
- A hover or drag position indicator.
- A floating "cinema loupe" preview above the timeline while the user hovers or drags.
- An optional monospaced timecode HUD attached to the floating preview.
- Optional temporal delta and live-preview indicator chips.
- Optional film perforations and hover spotlighting in the thumbnail strip.

The main layout is a vertical stack:

```text
VideoPlayer
Thumbnail timeline
Floating preview appears above the hovered timeline position
```

The package keeps the media content visually primary. The timeline is compact, clipped to an 8-point corner radius, and uses generated video thumbnails once available. Before thumbnails load, it shows a themed placeholder strip sized to the configured thumbnail count. High-density timelines keep a stable per-thumbnail width and become horizontally scrollable rather than compressing all frames into the visible width.

## Interaction Model

The scrubber supports two related interactions:

- Hover preview on macOS: moving over the thumbnail strip updates the preview moment without committing playback position.
- Drag scrubbing: dragging across the strip updates the preview moment and can seek the main player when the drag ends.
- Edge autoscroll: when the pointer is held near the left or right side of an overflowing timeline, the strip scrolls in that direction. Scroll speed ramps up as the pointer moves closer to the edge.

When previewing, MosaicScrubberKit uses a separate muted `AVPlayer` inside `PreviewPlaybackSession`. The preview player seeks to the requested moment, plays for up to `maximumPreviewDuration`, and exposes video frames through `AVPlayerItemVideoOutput`.

Metal renders those frames in the floating preview. As the user moves between moments, `MetalPreviewRenderer` keeps the previous frame and blends into the next frame over `transitionDuration`, which avoids abrupt visual jumps during scrubbing.

The cinema loupe appears with a short magnetic-lift transition: scale, vertical offset, and opacity animate with a spring. A themed anchor stem connects the loupe to the hovered timeline position.

## Configuration

Apps configure behavior through `ScrubberConfiguration`.

| Option | Purpose | Default |
|---|---|---|
| `thumbnailCount` | Number of timeline segments and generated thumbnails. Higher values show more visual detail and use more extraction/cache work. | `48` |
| `trackHeight` | Height of the thumbnail strip. Values below 44 points are clamped. | `64` |
| `previewSize` | Adaptive floating preview preset: `.small`, `.medium`, or `.large`. The resolved dimensions preserve source-video aspect ratio and fit the available player width. | `.medium` |
| `maximumPreviewDuration` | Maximum time the floating preview plays after each hover or drag update. | `1.5` seconds |
| `seekTolerance` | AVFoundation seek tolerance for preview and main-player seeking. Lower values can feel more precise but may cost more. | `0.12` seconds |
| `hoverDebounce` | Intended debounce interval for hover-driven preview updates. | `0.05` seconds |
| `transitionDuration` | Metal blend duration when transitioning between preview frames. | `0.12` seconds |
| `showsTimecode` | Shows or hides the floating preview timecode label. | `true` |
| `showsTemporalDelta` | Shows or hides the delta between current playback time and preview time. | `true` |
| `showsLiveIndicator` | Shows or hides the live preview indicator chip. | `true` |
| `showsFilmPerforations` | Shows or hides the filmstrip perforation dots. | `true` |
| `usesHoverSpotlight` | Dims non-hovered thumbnails and emphasizes the hovered segment. | `true` |
| `visualTheme` | Selects `.automatic`, `.obsidianFlux`, or `.obsidianFluxLight`. | `.automatic` |
| `commitsSeekOnDragEnd` | Seeks the main player to the drag endpoint when the drag ends. | `true` |
| `prefetchWindow` | Intended surrounding thumbnail/preview prefetch window. | `3` |
| `cachePolicy` | Thumbnail retention policy. Use `.memory(maxItems:)` or `.none`. | `.memory(maxItems: 96)` |

Typical app tuning:

- Use more thumbnails for wide desktop media browsers.
- Use high thumbnail counts for review workflows; the timeline scrolls horizontally instead of shrinking thumbnails below inspection size.
- Use a taller track for review/editing tools where frame detail matters.
- Use `.large` for desktop inspection workflows.
- Use `.small` and fewer thumbnails for compact windows.
- Lower `transitionDuration` for snappier movement; raise it slightly for a softer preview feel.
- Disable `showsTimecode` when the host app already displays precise time elsewhere.
- Disable `showsTemporalDelta` or `showsLiveIndicator` when the host app needs a quieter preview HUD.
- Force `.obsidianFlux` for dark edit suites, `.obsidianFluxLight` for bright review tools, or keep `.automatic` for normal app integration.

## Visual Themes

`ScrubberVisualTheme` has three modes:

- `.automatic`: resolves from the surrounding SwiftUI `colorScheme`.
- `.obsidianFlux`: dark carbon surfaces, electric-blue active states, off-white text, low-eye-strain preview chrome.
- `.obsidianFluxLight`: white glass surfaces, pro-blue active states, dark text, light technical hairlines.

The theme affects the timeline background, placeholder shimmer, playhead color, hover indicator, film perforations, preview chrome, preview border, timecode HUD, live indicator, anchor stem, shadow, and non-hovered thumbnail opacity.

## Data Model

`ScrubberVideoSource` describes the video shown by the scrubber:

- `url`
- `duration`
- `naturalSize`
- `frameRate`
- `title`

Apps can construct it directly when metadata is already known, or call:

```swift
let source = try await ScrubberVideoSource.load(from: url)
```

That loader uses AVFoundation to read common metadata without requiring MosaicKit.

For apps that already use MosaicKit, the optional `MosaicScrubberMosaicKit` target adds:

```swift
ScrubberVideoSource(videoInput: VideoInput)
```

The core scrubber does not require MosaicKit. This keeps the primary UI package usable in any SwiftUI/AVKit app.

## App Integration

A minimal integration looks like this:

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

For file-based apps, keep security-scoped access alive for as long as the `AVPlayer`, thumbnail generator, and preview session may read the video URL. The demo app under `Examples/MosaicScrubberDemo` shows this pattern with a small `VideoSession` object.

## Events

`ScrubbingVideoPlayer` accepts an optional event closure:

```swift
ScrubbingVideoPlayer(source: source, player: player) { event in
    // analytics, external state sync, debug logging, etc.
}
```

The public event type supports hover, seek, and failure cases:

- `hoverBegan(CMTime)`
- `hoverChanged(CMTime)`
- `hoverEnded`
- `seekBegan(CMTime)`
- `seekChanged(CMTime)`
- `seekEnded(CMTime)`
- `failed(String)`

The current view implementation reports hover changes, hover end, and seek end. The broader event enum leaves room for richer interaction reporting without changing the public event type.

## Accessibility

The timeline is exposed as a single adjustable accessibility element labeled "Video position". Its value reports the current time and total duration. Increment and decrement accessibility actions seek by 10 seconds.

The thumbnail images and visual indicators are hidden from accessibility because they duplicate the adjustable timeline state. The floating preview reports its timecode as an accessibility label.

Host apps should still provide accessible playback controls around the scrubber, such as play/pause, skip, volume, captions, and fullscreen controls where appropriate.

## Visual Guidance For Host Apps

MosaicScrubberKit works best when used as part of a media-first surface:

- Give the video player most of the vertical space.
- Keep the scrubber directly below the video so pointer travel is short.
- Avoid placing controls between the video and scrubber unless they are essential transport controls.
- Use system backgrounds and semantic colors around the component.
- In media-heavy apps, a dark surrounding appearance can help the video and thumbnails remain the focus.
- Size the scrubber from available container space, not device assumptions.

The component itself has stable internal dimensions from `trackHeight` and adaptive preview presets. In responsive app layouts, change `previewSize` intentionally when the container becomes narrow rather than letting surrounding layout compress the scrubber unpredictably.

For non-standard video aspect ratios, the floating preview preserves the source shape:

- Landscape video resolves to a landscape loupe.
- Vertical video resolves to a tall, narrow loupe.
- Ultrawide video resolves to a wider, shorter loupe while enforcing a readable minimum short edge.

The selected preset controls the intended visual weight, while available player width prevents the loupe from becoming too large for the current container.

## Performance Model

The package separates work across three layers:

- `MosaicScrubberCore` handles timeline math, thumbnail extraction, configuration, and cache policy.
- `MosaicScrubberMetal` handles pixel-buffer-to-Metal texture bridging and preview rendering.
- `MosaicScrubberKit` provides the SwiftUI/AVKit view layer.

Thumbnail extraction is asynchronous. The timeline appears immediately with placeholders, then swaps to generated thumbnails. Preview playback uses a muted secondary player so the main player can remain at its current position while the user inspects another moment.

Metal is used for the floating preview because it can render decoded pixel buffers with smooth frame-to-frame transitions and aspect-fit scaling without going through a legacy Core Graphics preview path.

## Current Boundaries

MosaicScrubberKit intentionally does not provide:

- Full transport controls.
- Video library browsing.
- Persistent playback history.
- Editing timelines or clip trimming.
- Audio preview during hover.
- Custom thumbnail styling hooks beyond the configuration values.

Those belong in the host app. The package focuses on the reusable scrubbing surface that can sit inside many different media experiences.
