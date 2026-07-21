---
name: new-adr
description: Scaffold a new architectural-decision entry into docs/decisions.org for this Doom Emacs config repo, with the full context/decision-drivers/candidates/evidence/decision/consequences/rejected-alternatives/validation/rollback/revisit-condition structure this project requires. Use when proposing or recording any new architectural decision here, instead of only stating it in conversation.
---

# New ADR

Append a new ADR entry to `docs/decisions.org` in this repo, matching the
structure `.claude/rules/documentation.md` requires and every existing entry
(ADR-001 through ADR-009) already follows.

## Before writing anything

1. Read `docs/decisions.org` fully (or at least `grep -n "^\* ADR-\|^:ID:\|^:STATUS:"`
   it) to find the current highest `ADR-NNN` number and confirm the file's
   exact heading/property-drawer/section style — copy that style, don't
   invent a new one.
2. If the decision's context, drivers, candidates, evidence, or consequences
   aren't already clear from the conversation, ask the user rather than
   inventing plausible-sounding content. A thin ADR with real gaps flagged is
   better than a confident one with fabricated evidence.

## Structure to produce

```
* ADR-<N+1>: <short, decision-stating title — not a question>
:PROPERTIES:
:ID:       adr-<descriptive-kebab-slug, NOT just the number — see existing IDs>
:STATUS:   <Accepted | Accepted (not yet implemented) | Implemented | Implemented, live-verified>
:DATE:     <today, YYYY-MM-DD>
:END:

** Context
<Why this decision is needed now — the problem, constraint, or prompt behind it.>

** Decision drivers
<Bulleted list — constraints, standards.org rules, or user-stated priorities
that shape the choice.>

** Candidates
<Options considered, ideally as a table with a Fate/outcome column, like
ADR-004's or ADR-009's candidates tables.>

** Evidence
<What was actually checked — file/tool output, source reading, live tests —
not assertions. Cite specifics (paths, line numbers, command output).>

** Decision
<The concrete choice, stated as an action — code/config to add, not just a
sentiment.>

** Consequences
<What this implies going forward, including any newly-discovered gaps or
follow-on work.>

** Rejected alternatives
<Can be "See Candidates table above" if that table already carries the
fate/reason for each rejected option — don't duplicate it.>

** Validation
<How to confirm the decision actually holds — commands run, tests passed,
output observed.>

** Rollback
<Concretely how to undo this if it needs reverting.>

** Revisit when
<Bulleted list of concrete future conditions — not "if needed," name the
actual trigger.>
```

## Conventions specific to this repo

- `:ID:` values are kebab-case and describe the decision, not the number
  (`adr-permission-enforcement`, `adr-claude-code-ide-install` — never
  `adr-009`). Check the new slug doesn't collide with an existing `:ID:`.
- Cross-link related entries and docs with `[[id:some-id][label]]`, never by
  file path (per `.claude/rules/documentation.md`).
- If the decision's status changes later (Accepted → Implemented →
  live-verified), add a `:LOGBOOK:` drawer recording each transition with a
  date and one-line reason, as ADR-008 and ADR-009 do — don't just edit
  `:STATUS:` silently.
- Append the new entry at the end of the file, after the last existing ADR.
- If the decision touches another canonical doc (`docs/standards.org`,
  `docs/ai/architecture.org`, `docs/roadmap.org`, etc.), add a short
  cross-reference there too, pointing back to the new ADR's `:ID:` — don't
  let the new decision live only in `decisions.org` if another doc makes a
  claim the decision now changes (see how ADR-009 updated
  `docs/ai/architecture.org` and `docs/standards.org` alongside itself).
- Never fabricate "Evidence" — if something wasn't actually tested/verified,
  say so plainly (this repo's existing ADRs are explicit about what's
  live-verified vs. structural-only vs. not yet exercised; match that
  honesty rather than implying more confidence than the work supports).
