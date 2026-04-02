## Go Project — Tool & Skill Requirements

This is a **Go project**. Always use Go-native tools and available `cc-skills-golang:*` skills. No exceptions without explicit justification.

### Tool Chain (always prefer these)

| Task | Required Tools |
|------|---------------|
| Build & run | `go build`, `go run` |
| Test | `go test` (with flags like `-race`, `-cover`, `-v`) |
| Format | `gofmt`, `goimports` |
| Lint | `golangci-lint run`, `go vet` |
| Dependencies | `go mod tidy`, `go get` |
| Debug | `dlv` (Delve) |

### Skill Discovery

Before writing non-trivial Go code, scan the available skill list for any `cc-skills-golang:golang-*` skill matching the task domain (e.g., error handling → `golang-error-handling`, concurrency → `golang-concurrency`). Load the matching skill before proceeding.

### Rules

1. **Go tools first** — never use generic shell scripts when a Go tool exists for the job.
2. **Load matching skills** — scan available `cc-skills-golang:golang-*` skills for the task domain, load if found.
3. **If skipping a Go tool/skill**, state which one and why in one sentence. No hand-waving.
