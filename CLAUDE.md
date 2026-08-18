@AGENTS.md

## Claude Code

- This project's memory: `docs/*.org` and `docs/ai/*.org` are canonical. Don't
  duplicate their content here — point to them.
- Current active work: check `PROJECT.org` and `docs/roadmap.org` for which
  Phase 1 sub-phase is in progress before starting anything.
- Prefer reading `docs/ai/troubleshooting.org` before re-diagnosing a problem
  that may already be logged there (e.g. the `$PATH` tilde issue, the
  `package-lint` branch-rename class of `doom sync` failure).
- When proposing a new architectural decision, add it to `docs/decisions.org` as
  a new ADR (context, drivers, candidates, evidence, decision, consequences,
  rejected alternatives, validation, rollback, revisit condition) rather than
  only stating it in conversation.

## Agent skills

### Issue tracker

Issues live as GitHub issues on `Meta-James/doom-config`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), unchanged. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context, but not the CONTEXT.md/docs/adr convention — points at this repo's existing `docs/*.org` structure instead. See `docs/agents/domain.md`.
