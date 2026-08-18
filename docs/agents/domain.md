# Domain Docs

How agent skills should consume this repo's domain documentation when exploring
the codebase.

This repo does not use the CONTEXT.md / docs/adr/ convention. Its canonical
docs are org-mode files under `docs/`, and skills should read those instead.

## Before exploring, read these

- `docs/standards.org` — durable cross-phase rules
- `docs/inventory.org` — verified current state (check here first; don't assume)
- `docs/architecture.org` — how the major pieces fit together
- `docs/ai/*.org` — troubleshooting, workflows, keybindings, provider specifics
- `PROJECT.org` and `docs/roadmap.org` — which work phase is currently active,
  before starting anything

## Architectural decisions (ADR equivalent)

- `docs/decisions.org` is the ADR log for this repo — one file, org headings per
  decision, not the `docs/adr/*.md` per-file convention.
- To record a new decision, use the `new-adr` Claude Code skill, which scaffolds
  the full context/decision-drivers/candidates/evidence/decision/consequences/
  rejected-alternatives/validation/rollback/revisit-condition structure this
  project requires — don't hand-write a new ADR format.
- If your output contradicts an existing decision in `docs/decisions.org`,
  surface it explicitly rather than silently overriding.

## Use the glossary's vocabulary

This repo doesn't maintain a separate CONTEXT.md glossary; domain vocabulary
lives in `docs/inventory.org` and `docs/architecture.org`. Match the terms used
there rather than inventing synonyms.

## Format convention

Prefer `.org` for any new documentation in this repo, and convert existing
non-`.org` docs to `.org` when practical — except files Claude Code itself
reads as markdown by convention (`CLAUDE.md`, `AGENTS.md`, and the
`docs/agents/*.md` files this setup skill writes), which stay markdown since
that's the format Claude Code is built to consume well.
