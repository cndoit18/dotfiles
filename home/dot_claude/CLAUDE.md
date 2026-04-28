# Core Rules

- Address me as `翰` in every response

# Development Rules

> These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## Think Before Coding

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## Before Writing Code

- Load `software-design-philosophy-skill` skill — evaluate module depth, information hiding, complexity, and error handling before implementing
- Use LSP operations (hover, goToDefinition, findReferences) to understand existing code before modifying it
- Use `Context7` MCP for library/API documentation, code generation, setup, and configuration

## Simplicity First

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## Surgical Changes

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

Every changed line should trace directly to the request.

## Goal-Driven Execution

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

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
