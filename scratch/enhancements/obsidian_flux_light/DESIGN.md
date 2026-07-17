---
name: Obsidian Flux Light
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0edec'
  surface-container-high: '#ebe7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#414755'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#717786'
  outline-variant: '#c1c6d7'
  surface-tint: '#005bc1'
  primary: '#0058bc'
  on-primary: '#ffffff'
  primary-container: '#0070eb'
  on-primary-container: '#fefcff'
  inverse-primary: '#adc6ff'
  secondary: '#0060aa'
  on-secondary: '#ffffff'
  secondary-container: '#2696fe'
  on-secondary-container: '#002d55'
  tertiary: '#9e3d00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c64f00'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004493'
  secondary-fixed: '#d3e3ff'
  secondary-fixed-dim: '#a3c9ff'
  on-secondary-fixed: '#001c39'
  on-secondary-fixed-variant: '#004882'
  tertiary-fixed: '#ffdbcc'
  tertiary-fixed-dim: '#ffb595'
  on-tertiary-fixed: '#351000'
  on-tertiary-fixed-variant: '#7c2e00'
  background: '#fcf9f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
typography:
  headline-xl:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.2'
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  code-sm:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: '1.5'
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1'
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
  container-max: 1440px
---

## Brand & Style
The design system evolves into a high-clarity, professional environment that maintains its "Pro" technical DNA while embracing an airy, high-contrast aesthetic. It targets developers, data scientists, and power users who require a focused workspace that feels precise yet lightweight. 

The style is **Modern Technical Minimalism** with **Light Glassmorphism**. It leverages pure white foundations and subtle translucency to create a sense of infinite space. The emotional response is one of surgical precision, intellectual clarity, and structural rigor.

## Colors
The palette is anchored by a pure `#FFFFFF` background to maximize brightness and focus. 

- **Primary & Secondary:** We use a calibrated Electric Blue range. While `#2997FF` is the brand accent, interactive elements like primary buttons use `#007AFF` to ensure AA accessibility against white surfaces.
- **Neutrals:** Text and iconography utilize deep grays and near-blacks (`#121212`) to maintain the "Obsidian" weight without the literal dark background.
- **Surfaces:** We use white-based glassmorphism with a high blur (20px+) and a very thin, low-opacity neutral border to define technical boundaries without adding visual bulk.

## Typography
The typography strategy pairs the contemporary precision of **Hanken Grotesk** for interface and reading with the technical rigor of **JetBrains Mono** for data and metadata.

- **Headlines:** Use tight tracking and heavy weights to create a "Pro" editorial feel.
- **Body:** Set with generous line heights to maintain the "airy" quality of the light mode.
- **Monospace:** Reserved for IDs, code snippets, and status labels, reinforcing the developer-centric nature of the system.
- **Hierarchy:** Contrast is achieved through weight and size rather than color shifts, keeping the UI looking crisp and intentional.

## Layout & Spacing
The layout follows a **Fixed-Fluid Hybrid** model. Content is contained within a 1440px max-width container, centered on the screen, while background glass effects may bleed to the edges.

- **Grid:** A 12-column grid is standard for desktop, collapsing to 4 columns on mobile.
- **Rhythm:** A strict 4px baseline grid ensures technical alignment. Components are padded in multiples of 8px (16, 24, 32) to create a structured, professional cadence.
- **Margins:** Large outer margins on desktop (48px) emphasize the "airy" brand pillar, making the content feel curated rather than cluttered.

## Elevation & Depth
Depth is created through **Glassmorphism** and **Tonal Layering** rather than traditional drop shadows.

- **Base Layer:** Pure `#FFFFFF`.
- **Mid Layer (Surface):** Semi-transparent white (`rgba(255, 255, 255, 0.7)`) with `backdrop-filter: blur(24px)`. This is used for sidebars, floating panels, and headers.
- **Outer Stroke:** Every surface layer must have a 1px solid border of `rgba(0, 0, 0, 0.08)`. This "Technical Hairline" replaces the need for shadows.
- **Active State:** When an element is raised (e.g., a dragged card), use a very subtle, highly diffused blue-tinted shadow (`rgba(0, 122, 255, 0.05)`) to signal focus without breaking the light aesthetic.

## Shapes
To maintain the professional "Pro" feel, the shape language is disciplined and geometric. 

- **Standard Radius:** 0.25rem (4px) for small components like checkboxes and input fields.
- **Large Radius:** 0.5rem (8px) for cards and modals.
- **Technical Accents:** Use 45-degree clipped corners (chamfers) sparingly on decorative elements or specific "Status" chips to reinforce the "Flux" technical theme.

## Components
- **Buttons:** Primary buttons are solid `#007AFF` with white text. Secondary buttons use a "Ghost" style: transparent background with the 1px technical hairline border and Electric Blue text.
- **Input Fields:** Backgrounds are white with the 1px hairline border. On focus, the border transitions to Electric Blue with a 2px outer "glow" of 10% opacity blue.
- **Chips:** Use JetBrains Mono for text. Backgrounds should be a very pale gray (`#F5F5F7`) with no border, or a subtle blue tint for active states.
- **Cards:** Glassmorphic backgrounds with a 1px border. Ensure content inside has sufficient padding (min 24px) to breathe.
- **Data Tables:** Minimalist. No vertical lines. Horizontal lines should be the 1px hairline border. Header cells use `label-caps` typography.
- **Scrollbars:** Custom thin (4px) scrollbars in light gray, ensuring they don't distract from the content.