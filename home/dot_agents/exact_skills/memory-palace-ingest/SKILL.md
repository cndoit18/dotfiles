---
name: memory-palace-ingest
description: This skill should be used when the user asks to analyze, ingest, import, summarize into, or update a memory palace, LLM Wiki, long-term notes, or durable knowledge base. It identifies stable architecture, decisions, responsibilities, reliability knowledge, constraints, and source evidence while excluding brittle details such as directory trees, script paths, file inventories, transient logs, and code-layout facts maintained by project instructions or live source search.
---

# Memory Palace Ingest

Use this skill when turning raw material into durable long-term knowledge. The goal is not to preserve everything; it is to compound the knowledge base with stable, reusable understanding.

## Core stance

Act like an architecture-minded knowledge librarian:

- Extract durable concepts: system boundaries, responsibilities, tradeoffs, invariants, decisions, reliability goals, operating constraints, and unresolved questions.
- Avoid brittle details that are better maintained by source files, project instructions, git history, or live source search.
- Preserve provenance so future readers can trace why a record says what it says.
- Prefer updating existing knowledge over creating duplicates.
- Keep changes scoped, conservative, and reviewable.

## What belongs in long-term knowledge

Prefer recording information that remains useful after filenames, owners, and implementation details change:

- Architecture shape: layers, flows, trust boundaries, ownership boundaries, integration seams.
- Component responsibilities: what a component owns, what it explicitly does not own, and what it depends on.
- Design decisions: options considered, chosen direction, tradeoffs, constraints, and decision rationale.
- Operational knowledge: stable operating principles, failure modes, symptoms, recovery principles, environment assumptions.
- Reliability knowledge: SLOs, stability targets, risk areas, degradation behavior, drills, and mitigation strategy.
- Project context: why work exists, durable stakeholder or policy constraints, migration goals, and sourced deadlines only when they explain an architectural or operational decision.
- Source material: meeting notes, interview notes, imported documents, links, screenshots, and raw notes when they are evidence for later synthesis.

## What usually does not belong

Filter out details likely to go stale or already maintained elsewhere:

- Full code directory structures, file inventories, import graphs, or package-by-package walkthroughs.
- Exact function lists, class lists, line numbers, flag names, script paths, command sequences, or command outputs unless they are stable public interfaces or critical evidence.
- Git activity summaries, recent commits, authorship, or temporary branch state.
- Debugging recipes whose real source of truth is the committed fix or test.
- Generated logs, transient metrics, build output, stack traces, or one-off terminal state.
- Broad code-style conventions or project setup facts already captured in project instructions.

If a brittle detail is needed for provenance, keep it as a source pointer or a short evidence quote rather than making it a durable architectural claim.

## Ingest workflow

### 1. Identify the source and intended use

Before editing, determine:

- What material is being ingested.
- Whether the user wants read-only analysis, proposed changes, or direct knowledge-base edits.
- Which project/domain the material belongs to.
- Whether existing records already cover the topic.

If scope or edit permission is unclear, ask one concise question.

### 2. Search before creating

Look for existing records by project name, component name, decision topic, and related concepts. Prefer these outcomes in order:

1. Update a canonical existing record.
2. Add a source record and link it to an existing synthesis record.
3. Create a new record only when no existing record has a clear home for the knowledge.

Use the storage conventions of the current knowledge system; do not impose format-specific metadata. Do not create empty structure. Do not create parallel records that differ only by wording or date.

### 3. Classify the material

Use a small type vocabulary. Do not over-model.

- `overview` — domain landing page or map of content.
- `architecture` — system architecture, module relationships, flows, boundaries.
- `component` — one service, module, subsystem, or integration point.
- `operation` — concrete environment operation, deployment, or command workflow when it is stable and canonical.
- `troubleshooting` — symptom, cause, fix, incident notes.
- `reliability` — stability goals, SLOs, risks, drills, resilience planning.
- `decision` — ADR-style choice, tradeoff, chosen direction.
- `source` — meeting notes, interview notes, raw imported material.
- `reference` — glossary, terminology, external pointers.
- `archive` — obsolete or superseded material.

When material contains both raw evidence and synthesis, either keep raw evidence in a `source` record and synthesize into a canonical record, or clearly separate source evidence from synthesized conclusions.

### 4. Distill architecture-level knowledge

For each candidate fact, ask:

- Will this still matter if files move or functions are renamed?
- Does it explain a boundary, responsibility, constraint, decision, or failure mode?
- Can a future agent act better because this is recorded?
- Is there a source or evidence trail?

If the answer is mostly no, leave it out or keep it as a source pointer.

### 5. Preserve provenance

Every non-obvious factual claim should point back to a source:

- Existing record identifier, title, or path.
- User-provided document, meeting, transcript, screenshot, or URL.
- Local file or command result used as evidence.
- Explicitly user-stated context.

If sources conflict, record the conflict instead of silently choosing one.

### 6. Write in the current knowledge system's native format

Use the format and metadata conventions already present in the target knowledge system. Keep metadata minimal and useful for future retrieval. Do not guess owners, dates, deadlines, source URLs, or relationships.

Add links or references only where the relationship is semantically strong. A few high-signal references are better than linking every repeated term.

## Suggested record shapes

### Architecture record

```markdown
# <System> Architecture

## Summary

## Context and goals

## Architecture boundaries

## Main flows

## Key decisions and tradeoffs

## Reliability and operational implications

## Open questions

## Sources
```

### Component record

```markdown
# <Component>

## Summary

## Responsibilities

## Non-responsibilities

## Interfaces and dependencies

## Operational notes

## Sources
```

### Decision record

```markdown
# <Decision>

## Context

## Decision

## Alternatives considered

## Consequences

## Sources
```

## Report before applying larger changes

For non-trivial ingest work, first produce a concise assessment:

```markdown
## Source material

## Existing records found

## Durable knowledge to capture

## Details to exclude or keep only as provenance

## Proposed updates

| Record | Type | Change |
|---|---|---|

## Questions or approvals needed
```

Apply direct edits only when the user asked for implementation or when the change is low-risk, such as adding obvious semantic references, normalizing existing metadata, or appending a short sourced summary.

Ask for explicit approval before moving, renaming, splitting, merging, archiving, or deleting records; rewriting large sections; or changing the meaning of existing statements.

## Final response style

Keep the response concise. State what source was analyzed, which records were updated or proposed, what was intentionally excluded as too brittle, and any open questions.