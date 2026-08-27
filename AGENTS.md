# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Chezmoi Mental Model

This repository stores chezmoi source state, not literal `$HOME` paths. `.chezmoiroot` points to `home/`, so all managed dotfiles should be edited under `home/`.

Always reason in two steps:

1. source state path in this repository
2. rendered target state under `$HOME`

Use `chezmoi source-path <target>` and `chezmoi target-path <source>` when mapping between the two. Do not edit real `$HOME` targets directly or create target-home files at the repository root.

## Source State Naming

chezmoi encodes target behavior in source filenames. Preserve these attributes when moving or editing files:

- `dot_` maps to hidden target files
- `private_` sets restricted permissions
- `exact_` makes target directories exact, so unmanaged target files may be removed
- `noexact_` escapes an exact parent
- `.tmpl` files are Go templates evaluated by chezmoi

If a change touches an `exact_` directory, consider the deletion behavior before applying it.

## Templates and Secrets

Templates may use chezmoi data, `.chezmoi.*` variables, and `onepasswordRead`.

Do not replace `onepasswordRead` references with literal secrets. Template rendering depends on the 1Password CLI and configured account access.

For template changes, verify rendered output with chezmoi instead of guessing.

## Scripts and Apply Semantics

Files with the `run_` attribute are chezmoi scripts; script attributes such as `onchange`, `before`, and `after` can be combined in filenames. `run_onchange_` scripts run when their rendered content changes, and `run_after_` scripts run after target state updates.

In this repo, OS-specific scripts live under `.chezmoiscripts/darwin/` and `.chezmoiscripts/linux/`, with inclusion managed by `.chezmoiignore.tmpl`.

Changing data used inside script templates can trigger package/tool installation on the next apply.

## External Sources

`.chezmoiexternal.toml.tmpl` defines downloaded archives and external files. Prefer changing the external definition; do not treat manual edits to downloaded contents as persistent changes.

## Verification

Prefer chezmoi-aware verification:

```bash
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi execute-template < path/to/template.tmpl
```

Use `chezmoi apply` only when the rendered target state is understood.

## Claude Configuration

Claude Code configuration is managed as chezmoi source state under `home/`.

The global Claude instruction source is `home/dot_agents/AGENTS.md`, which maps to `~/.agents/AGENTS.md`; `home/dot_claude/symlink_CLAUDE.md` creates the target symlink to it.

Claude marketplace plugins are git submodules. Do not edit plugin code in-place; update submodules instead.

## Commits

Use Conventional Commits with scopes such as `claude`, `nvim`, `deps`, `go`, `git`, and `zsh`.
