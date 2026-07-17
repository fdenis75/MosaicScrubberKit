# MosaicScrubberKit: Dual-Theme Implementation Guide (Light & Dark)

This document provides technical specifications for implementing the "Cinema Loupe" interaction model within the MosaicScrubberKit framework, now updated to support both Dark (Obsidian Flux) and Light (Obsidian Flux Light) themes.

---

## 1. Visual Standards & Theming

MosaicScrubberKit uses a adaptive design system to maintain high-fidelity aesthetics in both environments.

| Element | Obsidian Flux (Dark) | Obsidian Flux Light |
|---|---|---|
| **Primary Background** | Deep Obsidian (`#131313`) | Alabaster White (`#fcf9f8`) |
| **Surface Containers** | Carbon Surface (`#1C1C1E`) | Soft Gray (`#f6f3f2`) |
| **Primary Accent** | Electric Blue (`#2997ff`) | Pro Blue (`#007aff`) |
| **Text (Primary)** | Off-White (`#e5e2e1`) | Deep Space (`#131313`) |
| **Text (Secondary)** | Steel Gray (`#c0c7d5`) | Slate Gray (`#5c5c5c`) |
| **Glassmorphism** | `blur(20px)` / 10% White Border | `blur(20px)` / 15% Black Border (0.05 opacity) |
| **Shadows** | `0 10px 30px rgba(0,0,0,0.5)` | `0 10px 30px rgba(0,0,0,0.08)` |

### Typography
- **Hanken Grotesk**: Primary UI headings and labels.
- **JetBrains Mono**: Precision timecodes, deltas, and technical metadata.

---

## 2. The Cinema Loupe (Floating Preview)

The floating preview acts as a "live magnifying glass." Its visual weight must adjust based on the theme to maintain legibility.

### Physicality & Animations
- **Magnetic Lift**: On interaction (hover/drag), the preview must rise from the timeline.
    - **Initial State**: Scale `0.96`, Offset Y `12pt`, Opacity `0`.
    - **Active State**: Scale `1.0`, Offset Y `0`, Opacity `1.0`.
    - **Spring Config**: `response: 0.22`, `dampingFraction: 0.82`.
- **Anchor Stem**: 
    - **Dark**: Electric Blue to Transparent.
    - **Light**: Pro Blue to Transparent (with slightly higher opacity for visibility).

### Technical Overlay (Premium HUD)
- **Timecode Capsule**: A monospaced JetBrains Mono HUD. In Light Mode, use a dark-translucent capsule (`rgba(0,0,0,0.8)`) with white text to ensure the timecode always "pops" regardless of the video content.
- **Temporal Delta**: Shows the delta from current playback position.
- **Live Indicator**: A pulsing red dot with "LIVE" text.

---

## 3. Living Filmstrip (Timeline)

The thumbnail strip behaves as a responsive object.

- **Film Perforations**: 2pt radius dots above and below the strip.
    - **Dark**: White at 20% opacity.
    - **Light**: Black at 15% opacity.
- **Spotlight Effect**:
    - **Dark**: Non-hovered area `opacity: 0.6`.
    - **Light**: Non-hovered area `opacity: 0.75` (increased to maintain detail).
    - Hovered zone: `scale: 1.05`, `opacity: 1.0`.
- **Loading State**: Shimmer effect (Linear Gradient).
    - **Dark**: Transparent -> White/10% -> Transparent.
    - **Light**: Transparent -> Black/5% -> Transparent.

---

## 4. Iconic Playhead

- **Needle Geometry**: A 2px wide line capped with a 6px diameter circle at the top.
- **Snap Pulse**: On `seekEnded`, trigger a scale pulse (`1.0` -> `1.4` -> `1.0`) over `0.15s`.
- **Dual States**:
    - **Playback**: Solid White (Dark) / Solid Black (Light).
    - **Preview/Scrub**: Theme Accent Color (Blue).

---

## 5. Metal Performance & Accessibility

- **Velocity-Aware Blending**: Kernel logic remains identical across themes.
- **Accessibility Value**: "Video Position, [Time] of [Duration]."
- **Actions**: Increment/Decrement seeks by 10% or 10s.
- **Haptics**: Support `UIImpactFeedbackGenerator(style: .medium)` on frame-snapping.
