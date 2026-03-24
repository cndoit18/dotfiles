# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Type

This is a **chezmoi dotfiles repository** - it manages personal configuration files (dotfiles) across multiple machines using chezmoi.

## Directory Structure

```
home/                    # Source state (what gets deployed)
├── dot_claude/          # Claude Code configuration
├── dot_zshrc.tmpl       # Shell configuration
├── private_dot_config/  # Private config files
├── exact_dot_oh-my-zsh/ # Oh My Zsh configuration
└── .chezmoiscripts/     # Post-apply scripts
.claude/                 # Claude Code settings (project-level)
.gitmodules             # Git submodules for plugins
```

## Common Commands

- `chezmoi add <file>` - Add existing file to source state
- `chezmoi edit <file>` - Edit file in source state
- `chezmoi diff` - Show pending changes
- `chezmoi apply` - Apply pending changes
- `chezmoi apply -n` - Dry run
- `chezmoi source` - Open source directory

## File Naming Conventions

| Prefix | Meaning |
|--------|---------|
| `dot_` | Creates hidden file (e.g., `dot_zshrc` → `~/.zshrc`) |
| `exact_` | Exact path match |
| `private_` | Private file (not committed to repo) |
| `.tmpl` | Template file using Go text/template |

## Template Functions

- `onepasswordRead "op://..."` - Read from 1Password vault
- `env "VAR"` - Read environment variable
- `{{ .chezmoi.hostname }}` - Current hostname
- `{{ .chezmoi.os }}` - Operating system (darwin/linux)

## Git Submodules

This project uses git submodules for external plugins:
- `home/dot_claude/plugins/marketplaces/external_claude-plugins-official`
- `home/dot_claude/plugins/marketplaces/external_context7-marketplace`
- `home/dot_claude/plugins/marketplaces/external_agent-browser`

Run `git submodule update --init --recursive` after cloning to initialize submodules.

## Working with This Project

1. Edit files in the `home/` directory (source state)
2. Test changes with `chezmoi diff`
3. Apply with `chezmoi apply`
4. Commit changes to version control