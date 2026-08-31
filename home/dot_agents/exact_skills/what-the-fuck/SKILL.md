---
name: what-the-fuck
description: >
  Code quality is inversely proportional to the reader's "what the fuck" moments
  (WTFs/minute). Use this skill whenever WRITING code — self-check every chunk
  before yielding — and whenever REVIEWING code, to eliminate surprising,
  misleading, or unclear constructs. Triggers include any coding task, "readable",
  "clean code", "WTF", "would a reviewer understand this", "make this less confusing".
alwaysApply: true
---

# What the Fuck — Write Code That Doesn't Surprise

> The only valid measurement of code quality: WTFs/minute.
> — "WTFs/m" cartoon (Thom Holwerda, OSNews 2008), popularized by Robert C. Martin's *Clean Code*

Every "what the fuck" a reader utters is a place where the code defeated them:
they had to stop, re-read, grep, or guess. Good code earns zero WTFs because its
intent is obvious on the first pass. Use this skill as the reader's proxy:
you cannot judge your own code's clarity, so you must re-read it as a stranger.

The bar, in one line: **read the function name, know what the code does.**
If the name plus one cold read doesn't tell the whole story, the code owes the
reader a rewrite. Code should be simple and elegant — if it isn't, it fights
every reader for the rest of its life.

## The WTF loop

After writing a chunk of code (function, class, module — whatever the unit is):

1. Read it top to bottom once, at reading speed, as if you had never seen it.
2. Every moment you stall, double-take, or think "why is that there?" — that is a
   WTF. Fix it now, not "later". It will not get clearer with age.
3. Re-read after fixing. Stop when a clean pass produces no stalls.

Cost of each WTF you ship: every future reader pays it again, including future
you, after context has faded. The minutes saved by writing it unclearly the first
time are paid back with interest by every reader, every time.

## The WTF catalog

The patterns below account for most reader WTFs. For each: why it surprises the
reader, and the fix. A reader is surprised because the code violates an expectation
formed by its name, its surroundings, or common convention. The first three
sections are the most common WTFs in real agent-written code — they matter more
than the textbook ones below them.

### Useless abstraction — "why does this exist?"

The single most common WTF in real sessions: code whose reason for existing the
reader cannot find. It duplicates what the platform already does, it was built
for a future that never arrived, or it splits one thing into two for ceremony
instead of meaning.

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| A wrapper around something the framework/platform already does | Reader must find the difference; if there is none, the file is dead weight | Before writing: "does the native mechanism already do this?" Use it |
| An abstraction with no second consumer | Reader can't find who needs it; it promises generality nothing consumes | Build the abstraction when the second consumer appears, not before |
| A new module where a function in an existing module fits | Reader must decide whether the split carries meaning or is ceremony | Add to the existing module; split only when the new one has a real, nameable responsibility |
| Two code paths that do the same job | Reader must work out which is canonical, whether they diverge, and which to change | One path. Delete the loser — git keeps it |

### Hardcoding — "why is this welded shut?"

Distinct from magic numbers: a hardcoded value is legible but brittle. The
reader sees a path, flag, or assumption fixed in code that will inevitably vary —
by environment, by user, by the next feature — and knows the next change will
break it.

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| Values that vary by environment or user baked into code | Reader must hunt down every site when the value changes | Parameter, config, or constant table — anything user- or environment-specific belongs outside the logic |
| "Only one" assumptions (`template-new`, always `amd64`) | Reader can't tell invariant from accident; the code is built for today only | Model the variation: a list, a registry, a loop over "all of X" |
| Logic written for the first case, not the case list | The second case forces a rewrite; reader sees the seams where it will break | Generalize to the collection now — the loop costs the same as the one-off |


### Out-of-scope changes — "why was this touched?"

Not a line of code, but a diff. The reviewer must classify every hunk: needed
for the task, or drive-by? Every unrelated hunk is a WTF the reader pays to
investigate — and an unexpected deletion can destroy something load-bearing.

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| Changes unrelated to the task mixed into the diff | Reader must audit each hunk to separate the fix from the drive-by edits | Touch only what the task needs; if something outside scope is genuinely broken, report it — don't silently change it |
| Deleting or editing config that looks unused | Reader can't distinguish dead from load-bearing, and a wrong guess is catastrophic | Never delete "unused-looking" config without proving it's unused; monitoring, sidecars, and volume mounts are usually load-bearing |

### Naming

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| `d`, `data`, `info`, `tmp`, `result` | Name carries no intent; reader must trace usage to learn meaning | Name the meaning: `days_overdue`, `last_attempt_time` |
| Magic numbers (`if status == 3`) | Reader can't know what 3 means without a schema lookup | Named constant: `ORDER_PAID` |
| Unit-less numbers (`timeout = 30`) | Is it seconds? millis? The reader must find the call site | Encode units: `timeout_ms`, `distance_meters` |
| Misleading name (`get_users()` that mutates or writes files) | Name promises a pure read; behavior betrays it | Rename to the truth: `fetch_and_cache_users()` |
| Nearly-identical names (`userData`, `userInfo`, `userDetails`) | Reader can't tell which is which, or whether the difference matters | Rename so each states its distinguishing trait |
| One-letter names beyond trivial loops | `i` is fine in a 3-line loop; elsewhere the reader must page back to recall | Spell out meaning in any scope the reader can't hold in their head |

### Control flow

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| Deep nesting (3+ levels of `if`/loops) | Reader must maintain a mental stack of conditions | Guard clauses: return early, flatten the happy path |
| Negated conditions (`if !not_ready`) | Double negatives force a logic table in the reader's head | State the positive: `if ready` |
| Boolean flag parameters (`send(msg, true)`) | At the call site, `true` is invisible — reader must open the callee | Split into two functions or pass a named enum |
| Condition with hidden business meaning (`a && b && !c`) | Reader sees booleans, not the rule | Extract a predicate: `is_eligible_for_discount(customer)` |
| Side effect buried mid-function | Reader assumes a function does what its name says; mutation elsewhere surprises them | Keep side effects obvious: at the edges, or in a name that admits it |
| Returns changing type by branch (`list or None or str`) | Every caller needs the same `if` dance; each reader re-derives it | Normalize the return: one type, empty collection instead of None |

### Functions

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| Function that validates + transforms + persists + emails | Can't be summarized without the word "and" | Split into one-intent functions; orchestrate from a parent named after the whole |
| Mixed abstraction levels in one function | Reader jumps between SQL and business policy in adjacent lines | One level per function; low-level detail moves down |
| 6+ parameters, especially same-typed (`f(x1, x2, x3)`) | Argument order is memorization, not understanding | Group into a value object; or shrink the function's job |
| Output parameters (callee writes into caller's variable) | Who changed `result`? Reader must audit every call | Return the value instead; mutation via `out` only if the language/idiom demands it |
| Function does more than its name (`validate()` also writes to DB) | The name is a contract; violating it poisons every caller's reasoning | Split, or rename to the whole truth |

### Data & state

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| Mutable global state read and written from everywhere | To reason about one function the reader must reason about the whole program | Pass state explicitly; keep globals for process-wide config only |
| Stringly-typed values (`status = "active"`) | Typos and invalid states are possible; reader can't see the domain | Enum/union type where the language allows |
| Boolean fields that should be state (`is_processing && is_done`) | Impossible combinations are representable; reader must rule them out mentally | Model state explicitly: one enum field (`PENDING/ACTIVE/DONE`) |
| Returning null when the caller can't know | Null checks sprout at every call site; reader must guess which sites are guarded | Empty object/collection, or an explicit Option/Result type |

A module-level service seam (logger, clock, email client) is not the same WTF:
it exists so one line can be swapped in tests. Keep it read-only after init,
documented, and wired in one place. The WTF is state that *varies* at runtime,
not the global binding itself.

### Error handling

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| Empty catch block (`except: pass`) | Failure is invisible; reader can't tell intent from accident | Handle it, log it, or add a comment explaining why swallowing is correct |
| Catching a broad type to "be safe" (`except Exception`) | Hides programming errors the reader would want to see | Catch the specific error you can actually handle |
| Exceptions as control flow | Reader must track two paths through the same logic | Check preconditions first; reserve exceptions for exceptional cases |
| Re-raise without context (`raise ValueError`) | The original location and cause are lost; reader can't trace the failure | Chain the cause (`raise X from e`) or wrap with context |

### Comments

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| Comment restates code (`# increment i by one` above `i += 1`) | Why is this comment here? Is the code about to change? | Delete it; the code already says it |
| Comment contradicts the code (stale) | Which one is true? Reader now distrusts both | Delete or correct; a wrong comment is worse than none |
| Commented-out code block | Is it needed? Is it coming back? The reader must decide | Delete it; git history keeps it |
| Comment explains *what* instead of *why* | The why (constraint, quirk, decision) is the only part the reader can't re-derive | Rewrite as the reason: "API uses 1-based page index" |

### Duplication

| WTF trigger | Why the reader stalls | Fix |
|---|---|---|
| Same business rule copied in three places | Reader can't tell if the copies are in sync; change requires a scavenger hunt | Extract the rule once; the rule is knowledge, not text |
| Copy-paste with subtle diffs (one `<=`, one `<`) | The difference may be a bug or a feature; reader can't tell which | Unify, or make the difference explicit and named |
| Near-duplicate entire functions differing by a constant | Reader must diff two screens of code mentally | Parameterize the difference |

But: duplicate *text* is only a WTF when it duplicates *knowledge*. Two similar-looking
blocks with independent reasons to change should stay separate — merging them is a
different WTF ("why are unrelated things coupled?").

## Review mode

When reviewing someone else's code, the same catalog applies, with one difference:
you can ask. But before asking, check whether the answer belongs in the code.
If the author must explain something, the code failed — the explanation should be a
name, a comment, or a restructure, not a reply that evaporates.

Report WTFs as questions, ranked by how many future readers will pay:
"what does `status == 3` mean?" beats "this line is 1px misaligned".

## When NOT to chase zero WTFs

- **Domain complexity is real.** A pricing engine will always be hard; the goal is
  that its *intent* is obvious, not that its math is simple.
- **Don't add abstraction to look clean.** A pointless interface or premature split
  is itself a WTF ("why does this exist?"). Boring, direct code beats clever code.
- **Correctness and performance first.** Clarity never justifies changing behavior
  or making the hot path slow.
- **Don't fight the codebase's conventions.** A consistent local idiom the team
  already knows is not a WTF for them; introducing your "better" style is.
- **Style trivia is for tools.** Formatting, linting, import order: leave to the
  formatter and linter. This skill guards *meaning*, not whitespace.

## The one-question self-check

Before yielding code: **"If a reviewer reads this cold, where do they stop and say
'what the fuck'?"** If you can point at a spot, fix that spot. The review that
would have caught it is yours, for free, right now.
