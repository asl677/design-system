# Design System

A comprehensive design system and best practices guide for use across Pencil, Git, Figma, v0, and other tools.

## Files

- **CLAUDE.md** — General Claude Code best practices for UI, animation, and design patterns
- **DESIGN-SYSTEM.md** — Design tokens, color systems, typography, and component guidelines

## Usage

Use these files as context when designing in Pencil, Figma, v0, or collaborating in Claude chats.

---

## Statusline Setup

Claude Code statusline showing branch, model, balance, spend, and service status.

### Quick Setup

```bash
bash setup-statusline.sh
```

Then edit `~/.claude/statusline-command.sh` and update lines 7-8:
```bash
MONTHLY_BUDGET=150.00     # your monthly budget
ACCOUNT_BALANCE=24.91     # your current balance
```

### Files

- **statusline-command.sh** — the statusline script
- **monthly-spend.json** — tracks monthly spending (auto-reset on 1st)
- **ytd-spend.json** — year-to-date spending totals
- **setup-statusline.sh** — one-command installer

### What it shows

```
 main | Claude Haiku 3.5 | $38.20 left | $1.80/$40 | $189.90 ytd | Systems Online
```

Fields (left to right):
- Git branch (cyan)
- Claude model (yellow)
- Balance remaining (green/yellow/red)
- Monthly spend vs budget (green/yellow/red)
- Year-to-date spend (green/yellow/red)
- Anthropic service status (green/red)
