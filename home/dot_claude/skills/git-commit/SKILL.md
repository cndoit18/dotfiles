---
allowed-tools: AskUserQuestion, Bash(git:*), Glob, Grep, Read, TodoWrite
description: Analyze uncommitted changes and create logical commits with Conventional Commits format
---

# user-git-commit

Analyze uncommitted files, group them into cohesive commits, and create commits following the Conventional Commits standard.

## Implementation

1. **Analyze uncommitted changes**:

   - Run `git status --porcelain` to get all changes
   - Run `git diff` to see unstaged changes
   - Run `git diff --cached` to see staged changes
   - Identify modified, added, and deleted files

2. **Deploy analysis agents**:

   - **Grouping Agent**: Group related changes together
   - **Sequencing Agent**: Determine optimal commit order
   - **Type Agent**: Classify each group by commit type

3. **Group files into logical commits**:

   - Group by feature/functionality
   - Keep related changes together
   - Separate infrastructure from features
   - Isolate breaking changes

4. **Determine commit sequence**:

   - Infrastructure/config changes first
   - Core functionality changes
   - Tests and documentation
   - Style/formatting last

5. **Create commits**:

   - Stage files for each logical group
   - Generate commit message with type, scope, and description
   - Include detailed body when needed
   - Add breaking change footer if applicable

6. **Human confirmation workflow**:
   - Present all planned commits with their messages
   - **Use AskUserQuestion tool to get user approval**
   - Options to present:
     - "Approve all" → proceed with creating all commits
     - "Modify" → user will provide corrections
     - "Cancel" → abort without committing
   - Only execute git commit after receiving approval

## Conventional Commit Types

- **feat**: New feature or functionality
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code formatting (no logic changes)
- **refactor**: Code restructuring
- **test**: Test additions or modifications
- **chore**: Build, config, or dependency updates
- **perf**: Performance improvements
- **ci**: CI/CD changes

## Grouping Principles

1. **Feature Cohesion**: Keep feature files together
2. **Dependency Order**: Commit dependencies before dependents
3. **Test Proximity**: Include tests with their features
4. **Documentation**: Can be separate or with features
5. **Configuration**: Usually goes first

## Example Usage

```text
User: /user-git-commit
Assistant: I'll analyze your uncommitted changes and create logical commits.

Analyzing uncommitted files...

Found 12 uncommitted files:
- 4 new feature files
- 3 test files
- 2 configuration files
- 2 documentation updates
- 1 bug fix

Deploying analysis agents...

[Grouping Agent]
- Group 1: Authentication feature (4 files)
- Group 2: Config updates (2 files)
- Group 3: Bug fix in user service (1 file)
- Group 4: Tests for auth (3 files)
- Group 5: Documentation (2 files)

[Sequencing Agent]
Optimal sequence:
1. Configuration (enables other changes)
2. Bug fix (independent)
3. Authentication feature
4. Tests
5. Documentation

[Type Agent]
- Config: chore(config)
- Bug fix: fix(users)
- Auth feature: feat(auth)
- Tests: test(auth)
- Docs: docs(auth)

Creating commits...

Commit 1/5:
Staging: package.json, tsconfig.json
Message: chore(config): update TypeScript config and dependencies

Commit 2/5:
Staging: src/services/user-service.ts
Message: fix(users): resolve null pointer in user lookup

Commit 3/5:
Staging: src/auth/*, src/middleware/auth.ts
Message: feat(auth): implement JWT authentication system

Adds JWT-based authentication with:
- Login/logout endpoints
- Middleware for protected routes
- Token refresh mechanism

Commit 4/5:
Staging: tests/auth/*
Message: test(auth): add comprehensive auth tests

Commit 5/5:
Staging: README.md, docs/authentication.md
Message: docs(auth): add authentication documentation

[AskUserQuestion]
Question: "Do you want to proceed with creating these commits?"
Options:
- "Approve all": Create all commits as shown above
- "Modify": I'll provide corrections to the messages
- "Cancel": Abort and start over

[User selects "Approve all"]

✅ Creating commits...
Commit 1/5 created: chore(config): update TypeScript config and dependencies
Commit 2/5 created: fix(users): resolve null pointer in user lookup
Commit 3/5 created: feat(auth): implement JWT authentication system
Commit 4/5 created: test(auth): add comprehensive auth tests
Commit 5/5 created: docs(auth): add authentication documentation

✅ Created 5 logical commits from 12 files!
Ready to push when you're ready.
```

## Advanced Scenarios

### Breaking Changes

```text
feat(api)!: change authentication to OAuth2

BREAKING CHANGE: JWT tokens are no longer supported.
Users must re-authenticate using OAuth2 flow.
```

### Multi-scope Changes

```text
fix(api,db): resolve data consistency issue

- Fixed API validation
- Added database constraints
- Ensures data integrity
```

## Notes

- **ALWAYS use AskUserQuestion tool to get user approval before executing git commit**
- Present all planned commit messages, then ask user to:
  - "Approve all" - create all commits as shown
  - "Modify" - user provides corrections, then re-present for approval
  - "Cancel" - abort without committing
- Only proceed with git commit commands after receiving explicit approval
- Analyzes file relationships to create logical groups
- Maintains clean commit history
- Follows Conventional Commits strictly
- Helps with PR reviews by organizing changes
- Can handle complex multi-feature branches

## Boundaries & Scope

- Local commit creation only; do not push or rewrite published history
- No destructive operations (`reset --hard`, `rebase -i`) unless explicitly requested
- Do not mix large refactors with feature/fix changes in the same commit

## Repo Conventions

- Follow `CLAUDE.md` for commit style and repository standards
- Use Conventional Commits types consistently; include scope when helpful
- Keep commit bodies concise; include rationale and tests/docs notes when needed

## Templates/Reports

```text
<type>(<scope>): <summary>

Why: <optional rationale>
Notes: <tests/docs updated>
Tasks: <optional task references>
```

---
