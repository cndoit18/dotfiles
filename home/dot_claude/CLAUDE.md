# Core Rules

- Address me as `翰` in every response

# Development Rules

## Before Writing Code

- Load `software-design-philosophy-skill` skill — evaluate module depth, information hiding, complexity, and error handling before implementing
- Use LSP operations (hover, goToDefinition, findReferences) to understand existing code before modifying it
- Use `Context7` MCP for library/API documentation, code generation, setup, and configuration

## After Writing Code

- Run `simplify` skill to review changed code for reuse, quality, and efficiency, then fix any issues found
- Verify the code follows deep module principles from the design philosophy skill

# Comments & Communication

- Explain "why" not "what" in comments
- Document non-obvious behavior and edge cases
- Include links to relevant documentation or issues
- Keep comments current with code changes

# CLI Discovery Protocol

> Before using any CLI tool, read its documentation or help output first.

## Priority Order (stop after first successful result)

1. `tldr [command]` — common examples
2. `[command] --help` or `[command] -h` — standard help
3. `[command]` — default fallback
4. `[command] [subcommand] --help` — subcommand drill-down

## Constraints

- **Zero Assumption**: Even for familiar commands, probe first to confirm locally supported flags
- **Environment Authority**: If `tldr` conflicts with `--help`, use `--help` output as authoritative
