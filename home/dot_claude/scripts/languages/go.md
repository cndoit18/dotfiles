## Go Project — MANDATORY Tool & Skill Protocol

This is a **Go project**. You MUST follow these rules. Violations are unacceptable.

### Tool Chain

| Task | Required Tool |
|------|--------------|
| Build & run | `go build`, `go run` |
| Test | `go test` (with `-race`, `-cover`, `-v`) |
| Format | `gofmt`, `goimports` |
| Lint | `golangci-lint run`, `go vet` |
| Dependencies | `go mod tidy`, `go get` |
| Debug | `dlv` (Delve) |

Never use generic shell scripts when a Go tool exists. No exceptions.

### Skill Loading — MANDATORY

You have access to `cc-skills-golang:golang-*` skills (visible in your available skills list). You MUST use them.

**Procedure (execute EVERY TIME before writing or modifying Go code):**

1. Read the user's task description and the code you are about to touch.
2. Scan your available skills list for ALL skills matching `cc-skills-golang:golang-*`.
3. For EACH skill, check if its description is relevant to the current task.
4. Invoke ALL relevant skills using the Skill tool BEFORE writing any code.
5. At minimum, ALWAYS invoke these three — they apply to every Go task:
   - `cc-skills-golang:golang-code-style`
   - `cc-skills-golang:golang-naming`
   - `cc-skills-golang:golang-error-handling`

**Examples of matching logic (apply this reasoning yourself, do NOT rely on a hardcoded list):**
- Writing tests → invoke the skill whose description mentions testing
- Using goroutines → invoke the skill whose description mentions concurrency
- Defining structs/interfaces → invoke the skill whose description mentions structs
- The skill list may change over time. Always read the ACTUAL available skills, never assume a fixed set.

### Enforcement

- If you write Go code without invoking at least the 3 mandatory skills, you have violated this protocol.
- If a relevant domain skill exists and you did not invoke it, state which one and why. "I didn't think it was needed" is NOT acceptable.
- When in doubt, invoke. A false positive costs nothing; a miss costs code quality.
