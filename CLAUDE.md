# CLAUDE.md — Alfa Design System

Alfa Design System — Claude Code guidance for design work with this system.

## Documentation Navigation

| Document | Purpose |
|----------|---------|
| **[DESIGN-SYSTEM.md](./DESIGN-SYSTEM.md)** | Color tokens, typography, spacing, animation guidelines |
| **[Base CLAUDE.md](../CLAUDE.md)** | General Claude Code settings & workflow |
| **[GSAP Best Practices](../GSAP-BEST-PRACTICES.md)** | Animation patterns (ScrollTrigger, SplitText, timelines) |

## Repository

- **GitHub**: https://github.com/asl677/alfa-design-system
- **Purpose**: General-purpose design system and best practices for UI, animation, and design patterns
- **Usage**: Reference for Pencil, Figma, v0, and Claude chat contexts

## Design System File

- **DESIGN-SYSTEM.md** — Design tokens, color systems, typography, component guidelines

Use this file as context when:
- Designing new UI components
- Creating design briefs for Claude
- Establishing design consistency across projects
- Reviewing or auditing existing designs

## How to Use with Claude

### In Claude Chat
Paste the DESIGN-SYSTEM.md content into your prompt:
```
Use this design system as reference:

[paste DESIGN-SYSTEM.md here]

Design [feature] following these principles...
```

### In Design Tools
- Reference color palette and spacing rules in Pencil, Figma, v0
- Link to this repo for team context
- Share specific sections with designers

## Design System Principles

This system covers:
- **Color tokens** — Consistent palette across projects
- **Typography** — Font selection and hierarchy
- **Spacing & Layout** — Grid and component sizing
- **Animation** — Motion patterns and timing (see [GSAP Best Practices](../GSAP-BEST-PRACTICES.md) for implementation)
- **Components** — Reusable UI patterns

## General Claude Code Settings

For general Claude Code best practices, settings, and statusline setup, see:
- **~/CLAUDE.md** — Base configuration (applies to all projects)
