# Core Rules

- Address me as `cndoit18` in every response

# Development Rules

- Use `Context7` MCP for library/API documentation, code generation, setup, and configuration
- Load `excalidraw` skill for architecture diagrams, system diagrams, and codebase visualization
- Check for Python virtual environments (venv) and activate them when present. Prefer `uv run` over `python`
- Use LSP Smart reading glasses for your code
- After writing or modifying code files, always run the `code-simplifier:code-simplifier` agent to optimize and format the code before considering the task complete

# Comments & Communication

- Explain "why" not "what" in comments
- Document non-obvious behavior and edge cases
- Include links to relevant documentation or issues
- Keep comments current with code changes

# Best Practices Section

> Before using any CLI tool, first read its documentation or help output to understand proper usage and avoid errors.

## Progressive Discovery

For all commands, execute in this priority order, stop probing immediately after obtaining information:

1. **Example Probing**: Execute `tldr [command]` (get most common examples).
2. **Standard Help**: Execute `[command] --help` or `[command] -h`.
3. **Default Fallback**: Directly execute `[command]`.
4. **Subcommand Drill-down**: Execute `[command] [subcommand] --help`.

## Discovery Constraints (Strict Constraints)

- **Zero Assumption**: Even for `git` or `tar`, must first execute probing to confirm flags supported by the local version.
  **Environment Priority**: If `tldr` conflicts with `--help`, use the local `--help` output as authoritative.
