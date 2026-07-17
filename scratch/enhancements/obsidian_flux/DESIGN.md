---
name: Obsidian Flux
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c0c7d5'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8a919e'
  outline-variant: '#404753'
  surface-tint: '#a3c9ff'
  primary: '#a3c9ff'
  on-primary: '#00315c'
  primary-container: '#2997ff'
  on-primary-container: '#002e57'
  inverse-primary: '#0060aa'
  secondary: '#73d1ff'
  on-secondary: '#003548'
  secondary-container: '#00b8f1'
  on-secondary-container: '#00455d'
  tertiary: '#ffb3b1'
  on-tertiary: '#680011'
  tertiary-container: '#ff5c62'
  on-tertiary-container: '#620010'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d3e3ff'
  primary-fixed-dim: '#a3c9ff'
  on-primary-fixed: '#001c39'
  on-primary-fixed-variant: '#004882'
  secondary-fixed: '#c1e8ff'
  secondary-fixed-dim: '#73d1ff'
  on-secondary-fixed: '#001e2b'
  on-secondary-fixed-variant: '#004d67'
  tertiary-fixed: '#ffdad8'
  tertiary-fixed-dim: '#ffb3b1'
  on-tertiary-fixed: '#410007'
  on-tertiary-fixed-variant: '#92001c'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
  deep-space-gray: '#121214'
  carbon-surface: '#1C1C1E'
  neon-blue-glow: rgba(41, 151, 255, 0.4)
  timecode-orange: '#FF9F0A'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-mono:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm-mono:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 1px
  margin-md: 16px
  margin-lg: 24px
  panel-padding: 12px
---

## Brand & Style

The design system is engineered for the high-performance professional video landscape. It evokes the feeling of a high-end production suite: dark, focused, and powerful. The aesthetic is "Metal-powered"—drawing inspiration from raw hardware performance and cinematic precision. 

The target audience consists of editors and colorists who require a UI that recedes to prioritize content while providing instant visual feedback through neon cues. The style is a hybrid of **Minimalism** and **Glassmorphism**, utilizing translucent layers to maintain context across complex timelines. Every interaction should feel fluid and friction-less, characterized by subtle glows and "live" UI elements that suggest a constant state of processing and readiness.

## Colors

The palette is anchored in **Deep Space Gray** and **Carbon**, creating a low-eye-strain environment essential for long editing sessions. 

- **Primary (Neon Blue):** Reserved for active states, playback indicators, and "live" signals.
- **Secondary (Cyan):** Used for selection highlights and secondary action buttons.
- **Tertiary (Crimson):** Exclusively for destructive actions, recording states, and critical errors.
- **Neutral:** A range of high-contrast grays that separate the workspace zones without introducing visual noise.

Surfaces use varying levels of opacity rather than solid fills to allow "peek-through" visibility of underlying tracks or waveforms.

## Typography

Typography is designed for maximum legibility against dark backgrounds. 

**Hanken Grotesk** provides a modern, neutral, and high-contrast sans-serif feel for the primary interface and headlines. Its sharp terminals feel "engineered" and precise.

**JetBrains Mono** is utilized for all technical readouts. This includes timecodes, frame rates, file paths, and metadata. The monospaced nature ensures that numbers do not "jump" or shift during high-speed playback or scrubbing, maintaining a stable visual anchor for the editor.

## Layout & Spacing

The layout follows a **Fixed Grid** philosophy for the main application shell, dividing the screen into functional "Panels" (Viewer, Timeline, Inspector, Browser). 

- **The 1px Gutter:** Panels are separated by a precise 1px "Carbon" border, simulating the tight tolerances of professional hardware.
- **The Spacing Rhythm:** A 4px base unit controls all internal padding. 
- **Responsive Behavior:** On desktop, panels are resizable with "snapping" points. On mobile, the layout reflows into a single-viewer stack with a collapsed timeline, prioritizing the viewport.

Margins are kept minimal to maximize the "canvas" area for video content.

## Elevation & Depth

This design system eschews traditional shadows in favor of **Tonal Layers** and **Glassmorphism**. 

Depth is achieved through:
1.  **Z-Axis Stacking:** The timeline is the lowest layer. Floating inspectors and modals sit above it using a `backdrop-filter: blur(20px)` and 70% opacity fill.
2.  **Subtle Glows:** Active elements (like the playhead) emit a soft Neon Blue outer glow rather than a drop shadow.
3.  **Inner Strokes:** Buttons and panels use a 0.5px interior white highlight on the top edge to simulate a "beveled" metal light-catch, enhancing the tactile feel.

## Shapes

The shape language is "Soft-Industrial." We use a conservative **0.25rem (4px)** radius for most UI components (buttons, input fields, panels). This provides a professional, "machined" look that is less aggressive than sharp corners but more serious than fully rounded UI. 

**Exception:** Playback controls and toggle switches may use a "Pill" shape to indicate high interactability and comfort.

## Components

### Buttons
- **Primary:** Neon Blue fill with white text. High-contrast. On hover, increase the intensity of the blue glow.
- **Ghost:** Carbon stroke (1px) with transparent center. Used for secondary timeline tools.

### Input Fields
- **Monospaced Inputs:** All numerical inputs (Scale, Position, Timecode) use JetBrains Mono. 
- **Scrubbable Fields:** Inputs should allow "click-and-drag" to change values, with the cursor changing to a horizontal resize icon.

### Chips & Tags
- Used for metadata tagging. Small, 11px JetBrains Mono text. Low-profile background to avoid distracting from the clip thumbnails.

### Cards (Clips)
- Clips in the browser feature a "Hover Scrub" behavior. The card itself has no border, only a subtle scale-up effect and a Neon Blue progress bar at the bottom when active.

### Progress & Status
- **Glow-lines:** For rendering or exporting, use a 2px Neon Blue line that pulses. 
- **Timeline Rulers:** Use 1px vertical ticks with label-sm-mono for frame counts.