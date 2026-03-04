# Design System

A comprehensive design system and best practices guide for use across Pencil, Git, Figma, v0, and other tools.

## Files

- **CLAUDE.md** — General Claude Code best practices for UI, animation, and design patterns
- **DESIGN-SYSTEM.md** — Design tokens, color systems, typography, and component guidelines

## Usage

Use these files as context when designing in Pencil, Figma, v0, or collaborating in Claude chats.

---

## Claude Code Statusline

Real-time dynamic statusline showing git, model, tokens, session time, files, and MCPs.

### Quick Setup

```bash
bash setup-statusline.sh
```

### What it shows

```
a3f92b1 | Claude Haiku 3.5 | $0.0041 | 00:23 | 3 changed | mcp:pencil
```

Fields (left to right):
- Last commit ID (7-char hash) — dim
- Claude model name — yellow
- Token cost of last command — green/red
- Session elapsed time — cyan
- Files changed in git — red/green
- Connected MCPs — blue

### Dynamic Updates

- **Commit hash** — updates when you switch directories
- **Model** — from current Claude Code session
- **Token cost** — computed from API response
- **Session time** — tracked automatically
- **Files changed** — git diff vs HEAD
- **MCPs** — from settings.json configuration

### Files

- **statusline-command.sh** — the statusline script
- **session-starts.json** — session timing data
- **setup-statusline.sh** — one-command installer
