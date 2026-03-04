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

## Design System

This repo contains general design principles and patterns (see DESIGN-SYSTEM.md).

Project-specific docs:
- **alexlakas-portfolio** — `~/alexlakas-portfolio/DESIGN.md`
- **figma-mcp-server** — `~/figma-mcp-server/` (see repo README)
