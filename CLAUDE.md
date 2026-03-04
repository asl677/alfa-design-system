# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Approval & Permission Settings

**Mode: AUTO-APPROVE** — Run all actions without permission prompts
- Proceed autonomously with destructive operations (force push, reset --hard, git clean, etc.)
- Deploy to production without confirmation
- Modify config files and infrastructure without asking
- Exceptions: Still avoid obviously harmful actions (malware, security vulnerabilities)
- Date set: 2026-03-01

## Claude Code Plugin Marketplaces

Installed marketplaces for extending Claude Code capabilities:

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin marketplace add ananddtyagi/cc-marketplace
/plugin marketplace add anthropics/claude-code-plugins
```

Use `/plugin install <name>@<marketplace>` to install plugins from these sources.

## Main Project: figma-mcp-server

The primary codebase here is `~/figma-mcp-server/` — a TypeScript MCP (Model Context Protocol) server that lets Claude interact with Figma designs via two modes: readonly (REST API) and write (WebSocket plugin bridge).

### Commands (run from `~/figma-mcp-server/`)

```bash
npm run build          # Compile TypeScript to build/
npm start              # Run compiled server
npm run dev            # Run via ts-node (no compile step)
npm test               # Run all tests with coverage
npm run test:unit      # Run only unit tests
npm run test:integration  # Run integration tests
npm run lint           # Lint src/**/*.ts
npm run clean          # Remove build/
```

### Required Environment Variables

- `FIGMA_ACCESS_TOKEN` — Figma personal access token (required; server will not start without it)
- `FIGMA_PLUGIN_PORT` — WebSocket port for plugin communication (default: `8766`)
- `DEBUG=true` — Enable verbose logging

### Architecture

The server operates in two modes managed by `ModeManager`:

**Readonly mode** (`src/readonly/`): Uses the Figma REST API to extract design info from a file URL. `DesignManager` orchestrates calls; `ApiClient` handles HTTP; `StyleExtractor` parses colors/text/effects.

**Write mode** (`src/write/`): Communicates with the Figma desktop plugin over WebSocket. `PluginBridge` manages the WS connection; `DesignCreator` sends creation/update commands; `ComponentUtils` handles component-specific operations. Write mode must be explicitly activated (default is readonly).

**MCP layer** (`src/mcp/`): Wraps both modes behind the MCP protocol over stdio. `server.ts` connects to the MCP SDK transport; `tools.ts` declares available tools (different sets for readonly vs write mode); `handlers.ts` routes tool calls to the appropriate mode.

**Entry point** (`src/index.ts`): Wires all components together; `src/mcp/server.ts` contains an equivalent wiring used in tests.

**Config** (`src/core/config.ts`): Reads env vars at startup; throws if `FIGMA_ACCESS_TOKEN` is missing.

### Testing Notes

- Jest is configured with `ts-jest` + ESM (`extensionsToTreatAsEsm: ['.ts']`)
- Module path aliases map `.js` imports to their `.ts` sources at test time
- Coverage thresholds: 20% branches, 30% functions/lines/statements
- Integration tests require a running plugin connection; use `--detectOpenHandles` flag (already in `test:integration` script)

### Figma Plugin (`plugin/`)

The companion Figma plugin (`plugin/code.js`, `plugin/ui.html`) must be loaded in the Figma desktop app to enable write mode. It connects back to the server via WebSocket on `FIGMA_PLUGIN_PORT`.

---

## Secondary Project: alexlakas-portfolio

Path: `~/alexlakas-portfolio/` — Next.js 15, TypeScript, Tailwind CSS, GSAP 3, Lenis 1.1.20.
Deployed: https://vercel.com/asl677s-projects/alexlakas-portfolio
Webflow reference: https://hello-alex-portfolio.webflow.io
Webflow CSS ref file: `~/Downloads/hello-alex-portfolio.webflow.shared.34ba2b1e2.min.css`

### Commands (run from `~/alexlakas-portfolio/`)
```bash
npm run dev    # local dev server (may use port 3002 if 3000 taken)
npm run build  # production build (verify before deploying)
```

### Font System
- **Primary font**: `'Ppneuemontreal Book'` — PP Neue Montreal Book, normal weight, 0.05rem letter-spacing
- **Source**: Webflow CDN `@font-face`: `https://cdn.prod.website-files.com/63bce9e077c37c0d1b6de8f6/66fca63395527313c6d5eaa2_PPNeueMontreal-Book.otf`
- **Body CSS**: `font-family: 'Ppneuemontreal Book', 'Ppneuemontreal', sans-serif; letter-spacing: 0.05rem`
- **Inconsolata**: imported via `next/font/google` for bio text + marquee only
- **NO Space Grotesk** — removed entirely
- **`.base`**: inherits body font — NO `font-family` override on `.base`

### Key Architecture Rules

**Door animation** (Life button) — use `transformPerspective` on `.upper-wrap`:
- NEVER animate the CSS `perspective` property on `.body-wrapper` via GSAP — it corrupts the element
- `.body-wrapper` has NO `perspective` CSS — all 3D managed by GSAP transformPerspective on `.upper-wrap`
- Open: `{ transformPerspective: 80, rotationY: 0.4, duration: 0.8, ease: "power3.out" }`
- Close: `{ transformPerspective: 1200, rotationY: 0, duration: 0.8, ease: "power3.out" }` (same timing)
- Initial: `gsap.set(".upper-wrap", { transformPerspective: 1200 })` in revealAll
- 80px perspective is extreme — even 0.4° rotation creates dramatic door-swing visual

**Marquee** — inside `.upper-wrap`, not viewport-fixed:
- CSS: `position: absolute; top: 0; left: 0; right: 0` (not `position: fixed`)
- Lives inside `.upper-wrap` so it rotates with the door and scrolls away with the page
- Placed in JSX inside `.upper-wrap` div (before NavLeft and Slider)

**Cursor**: `cursor: default` on `*, *::before, *::after` — no hand pointers anywhere on the site

**Red strip**: `.link-strip` starts at `transform: translateX(-110%)`, CSS hover goes to `0%`.
On load GSAP sweeps `xPercent: -110 → 110` staggered, then `clearProps` restores CSS hover.

**Slider loop** (GSAP): `gsap.to(track, { x: -halfWidth, ease: "none", repeat: -1 })`. Duration ~50s (user preference). Measure `halfWidth = scrollWidth / 2` on `window.load`.

**Lenis**: Pinned `1.1.20`. Always cleanup: `gsap.ticker.remove(onTick); lenis.destroy()`

### Components
- `src/app/page.tsx` — orchestrator: `revealAll()` on Loader complete, `handleLifeClick()` for door
- `src/app/globals.css` — all CSS including @font-face PP Neue Montreal, link-strip, pill, marquee
- `src/app/layout.tsx` — only imports Inconsolata from Google Fonts; PP Neue Montreal via @font-face in CSS
- `src/components/NavLeft.tsx` — fixed left nav, 3 columns (name/projects/skills)
- `src/components/NavRight.tsx` — "Let's Go" top-right + "Life" pill bottom-right
- `src/components/MarqueeTop.tsx` — top marquee, CSS 5s animation, inside upper-wrap
- `src/components/Slider.tsx` — GSAP seamless loop, 15 images doubled to 30
- `src/components/BioSheet.tsx` — full-screen bio overlay, text staggers in/out with GSAP
- `src/components/Press.tsx` — black section below upper-wrap
- `src/components/LenisInit.tsx` — smooth scroll, pinned lenis 1.1.20
