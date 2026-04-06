# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

This is a **chezmoi dotfiles repository**. The `.chezmoiroot` file redirects the source state to `home/` — all managed dotfiles live under `home/`, not the repo root. Everything inside `home/` maps to `~/`.

## File Naming Conventions

| Prefix/Suffix | Meaning |
|---------------|---------|
| `dot_` | Hidden file (`dot_zshrc` → `~/.zshrc`) |
| `exact_` | Directory managed exactly (extra files removed on apply) |
| `private_` | File with restricted permissions |
| `.tmpl` | Go `text/template` file, evaluated at apply time |
| `noexact_*` | Escape hatch — prevents `exact_` parent from deleting this entry |

Prefixes combine: `private_dot_config/` → `~/.config/` with restricted permissions.

## Template System

Templates (`.tmpl` files) use Go `text/template` with chezmoi extensions:

- `onepasswordRead "op://vault/item/field"` — read secrets from 1Password (all secrets use this)
- `{{ .chezmoi.os }}` — `darwin` or `linux`
- `{{ .chezmoi.hostname }}` — machine hostname
- Software versions in `.chezmoidata.toml` (Go, Python, Node.js) — referenced as `{{ .go }}`, `{{ .python }}`, etc.

**1Password CLI is required** — template evaluation fails without it since all secrets (GitHub token, AI tokens, Context7 token) are pulled via `onepasswordRead`.

## OS-Conditional Scripts

Scripts under `.chezmoiscripts/darwin/` and `.chezmoiscripts/linux/` run only on the matching OS (controlled by `.chezmoiignore.tmpl`). Cross-platform scripts live directly in `.chezmoiscripts/`.

## Git Submodules

Four submodules under `home/dot_claude/plugins/marketplaces/`:

```
git submodule update --init --recursive   # Required after cloning
```

## Key Paths

- `home/.chezmoidata.toml` — software version pins
- `home/.chezmoi.toml.tmpl` — chezmoi config (hooks, data, 1Password refs)
- `home/.chezmoiexternal.toml.tmpl` — external dependencies (fonts, oh-my-zsh, zsh plugins)
- `home/.chezmoiignore.tmpl` — OS-conditional ignore rules
- `home/.chezmoiscripts/` — install scripts triggered on version changes
- `home/dot_claude/` — Claude Code config (skills, plugins, settings)
- `home/private_dot_config/` — app configs (nvim, lazygit, wezterm, starship)

## Gotchas

- **gvm fork**: Install scripts use `cndoit18/gvm` (personal fork), not upstream gvm
- **Submodule-based plugins**: Claude marketplace plugins are git submodules — update them with `git submodule update --remote` rather than editing in-place
- **Large .venv in skills**: `scientific-schematics` and `prompt-engineering-patterns` skills contain full Python venvs in source state

## Commits

Conventional commits with scopes: `type(scope): description`

Common scopes: `claude`, `nvim`, `deps`, `go`, `git`, `zsh`
