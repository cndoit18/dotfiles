---
allowed-tools: AskUserQuestion, Bash(git:*), Glob, Grep, LSP, Read, Task, TodoWrite
description: Multi-aspect code review with comprehensive analysis
---

# Code Review

## Current Repository State

```bash
git status --short && echo "---" && git diff --stat && echo "---" && git log --oneline -5
```

## Pre-Review Analysis

Before performing the review, analyze the context:

1. **What changed?** (file types, scope, complexity)
2. **What's the impact?** (systems affected, risk level, stakeholders)
3. **What reviews are needed?** (select dimensions based on file types)

## Scope Detection

Execute:

```bash
git diff --name-only --cached 2>/dev/null || git diff --name-only
```

Categorize changes and select review dimensions:

- **Documentation only** (_.md, _.txt, README): Documentation review
- **Test files only** (_\_test._, _.spec._, test/): Testing + Code Quality reviews
- **Config files** (_.json, _.yaml, *.toml, .*rc): Security + Architecture reviews
- **Source code** (_.ts, _.js, _.py, _.go, etc.): All 6 dimensions
- **Mixed changes**: All relevant dimensions

## Execution

Perform comprehensive code review covering the following dimensions:

### 1. Architecture & Design

- Module organization and separation of concerns
- Dependency management and abstraction levels
- Design pattern usage and consistency
- Integration points and coupling

**Think through:**

- How does this change affect dependent systems?
- What breaks when components fail?
- How does this fit into the broader architecture?

### 2. Code Quality

- Readability and naming conventions
- Code complexity and DRY principles
- Code smells and refactoring opportunities
- Consistent coding patterns

### 3. Security & Dependencies

- Input validation and injection vulnerabilities
- Authentication/authorization issues
- Secrets management
- Dependency vulnerabilities and license compliance
- Supply chain security

**Consider alternative hypotheses:**

- Beyond obvious vulnerabilities, what other attack vectors exist?
- What assumptions could an attacker violate?

### 4. Performance & Scalability

- Algorithm complexity and efficiency
- Memory usage and resource management
- Database queries and caching strategies
- Async patterns and load handling
- Horizontal scaling considerations

### 5. Testing Quality

- Meaningful assertions and edge case coverage
- Test isolation and failure scenarios
- Mock vs real dependencies balance
- Test maintainability and clarity
- Actual behavior verification (not just coverage)

### 6. Documentation & API

- README completeness and API documentation
- Breaking changes and migration impact
- Code comments and documentation coverage
- Usage examples and developer experience
- API consistency and contract clarity

## Report Template

**Placeholder Guide:**

- `[Target]` → Project name, component name, or directory path
- `[directory/files reviewed]` → Specific path being reviewed
- `[doc/test/config/source]` → File type category
- `[actual dimensions executed]` → Dimensions used (e.g., "Architecture, Security, Performance")
- `[X/Y/Z]` → Replace with actual numbers (X=critical, Y=high, Z=medium)
- `[path:line]` → File path and line number (e.g., `src/auth.ts:45`)
- `[🏗️Architecture/...]` → Choose one icon that matches issue type
- `X/10` → Replace X with actual score (0-10)

Generate report in this format:

````
🗂 Comprehensive Code Review Report - [Target]

📋 Review Scope
Target: [directory/files reviewed]
File Types: [doc/test/config/source]
Dimensions: [actual dimensions executed]

📊 Executive Summary
[Brief quality assessment, key strengths, critical issues]

🔴 Critical Issues (Must Fix Immediately)
1. [🏗️Architecture/🔒Security/⚡Performance/🧪Testing/📝Documentation/💥Breaking] [Issue Name]
   File: [path:line]
   Impact: [description]
   Solution:
   ```[code example]```

2. [Additional critical issues...]

🟠 High Priority Issues
1. [Type icon] [Issue Name]
   File: [path:line]
   Impact: [description]
   Solution: [recommendation]

2. [Additional high priority issues...]

🟡 Medium Priority Issues
1. [Type icon] [Issue Name] - [file:line]
   Refactoring suggestion: [suggestion]

2. [Additional medium priority issues...]

✅ Quality Scores
┌─────────────────┬───────┬────────────────────────────────────┐
│ Dimension       │ Score │ Notes                              │
├─────────────────┼───────┼────────────────────────────────────┤
│ Architecture    │ X/10  │ [Module separation/coupling issues]│
│ Code Quality    │ X/10  │ [Readability/consistency/patterns] │
│ Security        │ X/10  │ [Critical vulnerabilities (if any)] │
│ Performance     │ X/10  │ [Bottlenecks/scalability concerns] │
│ Test Coverage   │ X/10  │ [Coverage/test quality]            │
│ Documentation   │ X/10  │ [API docs/comments/examples]       │
└─────────────────┴───────┴────────────────────────────────────┘

✨ Key Strengths
- [Key strength with evidence]
- [Other strengths...]

🚀 Improvement Recommendations
1. [Practice/pattern name]
   ```[code example]```

2. [Other recommendations...]

📊 Issue Distribution
- Architecture: [X critical, Y high priority, Z medium priority]
- Security: [X critical, Y high priority, Z medium priority]
- Performance: [X critical, Y high priority, Z medium priority]
- Testing: [X critical, Y high priority, Z medium priority]
- Documentation: [X critical, Y high priority, Z medium priority]

⚠️ Systemic Issues
Recurring patterns to address:
- [Issue pattern] (occurred X times)
  → [Actionable fix/next step]
- [Other issues and solutions...]
````

## Example Usage

**Scenario 1: Reviewing recent changes**

```
User: /code-review
Assistant: I'll review your recent changes...

[Performs git diff analysis → Detects file types → Executes relevant reviews → Outputs report]
```

**Scenario 2: Reviewing specific files**

```
User: /code-review src/components/UserProfile.tsx
Assistant: I'll review the UserProfile component...

[Reads file → Performs all 6 dimension reviews → Outputs comprehensive report]
```

**Scenario 3: Reviewing documentation changes**

```
User: /code-review README.md docs/
Assistant: I'll review your documentation changes...

[Performs documentation and API review only → Outputs focused report]
```

## Instructions

When this command is invoked:

1. **Gather Context**: Run git commands to understand changes
2. **Detect Scope**: Identify file types and select relevant review dimensions
3. **Execute Reviews**: For each selected dimension:
   - Use Read tool to examine files
   - Use Grep tool to search for patterns
   - Use LSP tool for code intelligence (if available)
   - Apply deep thinking for complex analysis
4. **Generate Report**: Consolidate findings using the template above

DO NOT mention this internal process to the user. Simply perform the review and present the final report.
