# CLAUDE.md — Alfa by Boosted.ai

This file is read automatically by Claude Code. It defines project conventions, file references, and behaviour rules for this codebase.

---

## Documentation Navigation

| Document | Purpose |
|----------|---------|
| **[DESIGN-SYSTEM.md](./DESIGN-SYSTEM.md)** | Full design system reference (tokens, type scale, components, Figma mapping) |
| **[Base CLAUDE.md](../CLAUDE.md)** | General Claude Code settings & workflow |
| **[GSAP Best Practices](../GSAP-BEST-PRACTICES.md)** | Animation patterns (ScrollTrigger, SplitText, timelines) |

---

## Project files

| File | Purpose |
|------|---------|
| `boosted-alfa-deck.html` | Main pitch deck — single file, no build step |
| `DESIGN-SYSTEM.md` | Full design system reference (tokens, type scale, components, Figma mapping) |
| `CLAUDE.md` | This file — Claude Code project rules |

---

## Design system

**Always read `DESIGN-SYSTEM.md` before making any visual changes.**

Key rules:
- Use CSS variables — never hardcode colours or font names
- Accent words in headings: `<em>` + `color: var(--coral)` via CSS
- Labels and metadata: DM Mono, 9–10px, uppercase, `letter-spacing: .14em`
- Body copy: EB Garamond 300, 17px, `line-height: 1.75`, `color: var(--cream2)`
- Grid cells always need `≥ 20px` horizontal padding — never `padding: Npx 0`
- Borders are dividers — grids use `border-top + border-left` on container, `border-right + border-bottom` on cells. No `gap`.

---

## Themes

Three themes on `<html data-theme="dark|light|classic">`:
- **dark** — warm black, EB Garamond, coral accent (default)
- **light** — cream background, same type
- **classic** — pure black/white, Inter replaces all fonts, no italic

When adding new components, always add theme-aware overrides for all three.

---

## Animation rules

- Scroll reveals: add class `ln` — GSAP ScrollTrigger handles it automatically at `top 105%`
- Cover elements animate on load (no scroll needed) — excluded from ScrollTrigger
- Easing standard: `var(--ease-out)` = `cubic-bezier(0.16, 1, 0.3, 1)`
- Never use CSS `transition` for scroll-driven animations — use JS + `getBoundingClientRect`

For complex GSAP patterns, see [GSAP Best Practices](../GSAP-BEST-PRACTICES.md).

---

## Layout rules

- Page padding: `0 64px 0 120px` desktop, `0 20px` mobile (≤600px)
- The 120px left gutter clears the fixed `Alfa.` logo
- `html` and `body` both have `overflow-x: hidden` — do not add `overflow: visible` to top-level containers
- No `max-width` containers — everything is full-width fluid

---

## Content rules

- All description copy: **max 2 lines** (~120 characters)
- Tone: casual, direct, human — no jargon, no corporate language
- Section numbers (`§ 00`, `§ 01`…) are decorative — update manually if reordering

---

## Figma MCP usage

When building components in Figma from this system:

1. Import colour variables from `DESIGN-SYSTEM.md` → Figma Variables panel
2. Set up three variable modes: `dark`, `light`, `classic`
3. Font pairing: EB Garamond Display + DM Mono for labels
4. Grid components: use Auto Layout with **stroke** as divider (no gap)
5. The fixed logo (`Alfa.`) is a separate top-level frame, always visible
6. Represent merge circles as two Figma states: `apart` and `merged` for prototyping

---

## Do not

- Do not add new Google Font families — EB Garamond, DM Mono, or Inter only
- Do not use `margin: 0 auto` or `max-width` on `.page`
- Do not hardcode `#d4622a` — always use `var(--coral)`
- Do not use `overflow: visible` on `.merge-circles` or any top-level container
- Do not add zero horizontal padding on grid cells (`padding: Npx 0`)
