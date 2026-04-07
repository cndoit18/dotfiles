## Python Project — MANDATORY Tool & Skill Protocol

This is a **Python project**. You MUST follow these rules. Violations are unacceptable.

### Tool Chain

| Task         | Required Tool                                       |
| ------------ | --------------------------------------------------- |
| Build & run  | `uv run` (exclusively)                              |
| Test         | `uv run pytest` (with `-v`, `--cov`, `-x`)          |
| Format       | `uv run ruff format`, `uv run black`                |
| Lint         | `uv run ruff check`, `uv run mypy`, `uv run pylint` |
| Dependencies | `uv add`, `uv sync` (exclusively)                   |
| Debug        | `uv run` with debugger integration                  |

**CRITICAL RULE: NEVER use `python` directly. Use `uv run` for ALL Python execution.**

Never use generic shell scripts when a Python tool exists. No exceptions.

### Skill Loading — MANDATORY

You have access to `python-development:*` skills (visible in your available skills list). You MUST use them.

**Procedure (execute EVERY TIME before writing or modifying Python code):**

1. Read the user's task description and the code you are about to touch.
2. Scan your available skills list for ALL skills matching `python-development:*`.
3. For EACH skill, check if its description is relevant to the current task.
4. Invoke ALL relevant skills using the Skill tool BEFORE writing any code.
5. At minimum, ALWAYS invoke these three — they apply to every Python task:
   - `python-development:python-code-style`
   - `python-development:python-project-structure`
   - `python-development:python-error-handling`

**Examples of matching logic (apply this reasoning yourself, do NOT rely on a hardcoded list):**

- Writing tests → invoke the skill whose description mentions testing
- Using async/await → invoke the skill whose description mentions async
- Defining classes/functions → invoke the skill whose description mentions type safety
- Working with dependencies → invoke the skill whose description mentions packaging
- The skill list may change over time. Always read the ACTUAL available skills, never assume a fixed set.

### Special Considerations for Python

**UV-Only Rule:**

- **NEVER use `python` directly under any circumstances**
- Use `uv run` for ALL Python execution (scripts, modules, tests)
- `uv` manages dependencies and environment automatically - no need to manually handle virtual environments

**Type Safety:**

- Use type hints for all function signatures and class definitions
- Run `uv run mypy` for type checking when available
- Follow PEP 484 type hinting conventions

**Modern Python Features:**

- Use Python 3.12+ features when appropriate (match typing, pattern matching)
- Prefer dataclasses over plain classes for data containers
- Use f-strings over `%` formatting or `str.format()`

### Enforcement

- If you write Python code without invoking at least the 3 mandatory skills, you have violated this protocol.
- If a relevant domain skill exists and you did not invoke it, state which one and why. "I didn't think it was needed" is NOT acceptable.
- When in doubt, invoke. A false positive costs nothing; a miss costs code quality.
