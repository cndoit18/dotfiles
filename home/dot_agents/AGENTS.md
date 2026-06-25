# Core Rules

- Address me as `翰` in every response

# Default Operating Mode

- Make the smallest safe change that satisfies the request.
- Prefer a direct fix, direct answer, or direct verification over broad exploration.
- For simple edits, merge conflicts, version bumps, Dockerfile/shell fixes, config updates, and verification tasks: do not redesign, broaden scope, launch agents, or run broad reviews unless explicitly asked.
- Run the focused validation needed to prove the requested outcome; when it passes, summarize the evidence and stop.
- If the user asks whether something can be fixed without code changes, present no-code/config options before proposing code edits.

# Work Rules

- One feature at a time
- Verify end-to-end before starting the next: not just "tests pass" or "code compiles", but the feature works as intended when exercised from input to output
- Don't refactor B "while you're at it" when implementing A
- Do not continue into adjacent cleanup, unrelated reviews, or speculative improvements after the requested task is complete.

# Development Rules

> These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## Think Before Coding

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- Before non-trivial edits, give a 5-line execution contract: exact goal, files likely touched, non-goals, validation command, and stop condition.
- If the likely source path, environment, or acceptable fix type is unclear, ask one targeted question before running broad diagnostics or editing.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## Evidence-First Debugging

- Start debugging read-only unless the user explicitly approves mutation.
- Identify the target environment, instance/request/user ID, API or command, and exact symptom before investigating.
- Gather focused evidence from logs, config, runtime state, database rows, or tests with output capped by default; expand only when the missing context is necessary to prove or disprove the hypothesis.
- Separate evidence from hypothesis. State confidence and what fact would disprove the current hypothesis.

## Before Writing Code

- Load `software-design-philosophy-skill` skill — evaluate module depth, information hiding, complexity, and error handling before implementing
- Use LSP operations (hover, goToDefinition, findReferences) to understand existing code before modifying it
- Use `Context7` MCP for library/API documentation, code generation, setup, and configuration
- Do not use agents for narrow tasks unless the user asks or the task genuinely requires broad parallel research.

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

## Verification / Definition of Done

- After editing, run the narrowest validator that can prove the requested outcome and report the command.
- Validate JSON/templates with `python -m json.tool`, `jq`, or rendered-template validation.
- Validate shell with `bash -n`.
- Validate Python with targeted `pytest` or `python -m py_compile`.
- Validate Go with `go test` for touched packages.
- Validate config manifests with their repo-specific render/validate command.
- For UI or user-facing behavior, exercise the feature from input to output before claiming success.
- When verification passes and the requested task is complete, stop instead of expanding into new work.

## Stage-End Code Review (Mandatory)

- After completing a stage — defined as: one verifiable goal finished (see Goal-Driven Execution), or one feature done end-to-end, or before declaring the overall task complete — invoke the `code-review` skill with `--effort low` against the current diff. NOT after every individual edit.
- Run the stage's validator first (see Verification / Definition of Done), then run `code-review --effort low` on the cumulative diff of that stage.
- Apply fixes ONLY for correctness bugs introduced by your stage's change. NEVER refactor, expand scope, or address pre-existing issues surfaced by the review.
- Report each finding as `finding → action taken`. If zero findings, state `code-review: 0 findings` and stop.
- Stop condition for each stage: `code-review` has run AND findings are either fixed or explicitly accepted.

# Comments & Communication

- Explain "why" not "what" in comments
- Document non-obvious behavior and edge cases
- Include links to relevant documentation or issues
- Keep comments current with code changes
- Keep user-facing updates brief, evidence-based, and scoped to the current task.
