---
paths:
  - "*.org"
  - "**/*.org"
---

# Documentation conventions

- `docs/*.org` and `docs/ai/*.org` are canonical — architecture, standards,
  inventory, roadmap, and decisions live there, using real Org capabilities
  (property drawers, `:ID:`, `id:` links, TODO states, tags, tables, LOGBOOK),
  not just files with an `.org` extension.
- `CLAUDE.md`/`AGENTS.md`/`.claude/rules/*.md` are pointers, not canonical
  content — if you're about to write more than a few lines of durable
  architectural reasoning into one of them, it belongs in `docs/` instead, with
  a link left behind.
- Every entry in `docs/decisions.org` needs: context, decision drivers,
  candidates, evidence, decision, consequences, rejected alternatives,
  validation, rollback, and an explicit revisit condition — not just a decision
  and a date.
- Cross-link with `[[id:some-id][label]]`, not by file path, so links survive
  file moves/renames.
- Don't let a Babel source block execute automatically or capture a secret in
  its results — use header arguments that prevent both.
