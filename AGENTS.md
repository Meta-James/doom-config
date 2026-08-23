# AGENTS.md

Shared instructions for any coding agent working in this repository (Doom Emacs
personal configuration).

## What this repo is

A Doom Emacs `$DOOMDIR`: `init.el` (module activation), `packages.el` (package
declarations), `config.el` (configuration). Canonical long-form documentation is
in `docs/*.org` and `docs/ai/*.org` — read those before making non-trivial
changes, don't re-derive architecture from scratch. `docs/roadmap.org` and
`PROJECT.org` show what phase of work is currently active.

## Hard rules

- Doom-first: use `package!`, module flags, `use-package!`, `after!`, `map!`,
  `set-popup-rule!`, `load!`, `add-hook!`, `setq-hook!`. Never `package-install`
  or a second package manager.
- Evil-first: don't design workflows that fight Evil states or Doom's modal
  conventions.
- The agent may commit, push, amend/rebase/reset/clean/rewrite history — but
  only after proposing the specific command in conversation and getting
  explicit, in-the-moment permission each time; a past approval doesn't carry
  forward to the next one. Read-only git commands and diffs need no
  permission. Enforced technically for Claude Code via `.claude/settings.json`
  (forces a confirmation prompt, doesn't block outright) — see
  `docs/decisions.org` ADR-015 (supersedes ADR-009).
- Never hardcode, print, log, or commit secret values. Credential entry *names*
  are fine to reference; values never are. See `docs/ai/providers.org` for the
  credential architecture.
- Package installs, system/Emacs upgrades, broad rewrites, deletions, and
  permission changes need explicit approval in the current conversation — a
  past approval for one category doesn't cover a new one.
- After any `init.el`/`packages.el` change, run `doom sync`. After any
  module/package change, run `doom doctor` and confirm it's clean before calling
  the work done. Use `~/.config/emacs/bin/doom` (absolute path) when running
  Doom's CLI from a subprocess/script — `$PATH` has a literal-tilde bug that
  breaks non-interactive `doom` invocation; see
  `docs/ai/troubleshooting.org::tshoot-path-tilde`.
- One tool per responsibility (one chat client, one primary agentic-coding
  frontend). Don't add a second without a clearly distinct, frequently-useful
  role the first can't cover. Completion is scoped per axis, not as a single
  responsibility: one engine for in-buffer code completion (Corfu) and one for
  minibuffer/`completing-read` completion (Vertico) — these solve different
  problems and both existing is not a violation. Don't stack two engines on
  the *same* axis (e.g. Corfu and Company both active). See `docs/decisions.org`
  ADR-021.

## Where to look first

- `docs/standards.org` — durable cross-phase rules
- `docs/inventory.org` — verified current state (don't assume, check this first)
- `docs/decisions.org` — why things are the way they are, and when to revisit
- `docs/ai/troubleshooting.org` — known issues and their fixes, before treating a
  symptom as new
- `docs/ai/architecture.org` — how chat, completion, agentic coding, and review
  fit together, and where enforcement is technical vs. instructional
- `docs/ai/workflows.org` — the one default, documented workflow per
  responsibility (chat, focused transform, completion, agentic coding, review),
  with the actual keybindings in `docs/ai/keybindings.org`

<!-- caveman-begin -->
Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:
- Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
- Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
- Pattern: [thing] [action] [reason]. [next step].
- Not: "Sure! I'd be happy to help you with that."
- Yes: "Bug in auth middleware. Fix:"

Switch level: /caveman lite|full|ultra|wenyan-lite|wenyan-full|wenyan-ultra
Stop: "stop caveman" or "normal mode"

Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

Boundaries: code/commits/PRs written normal.
<!-- caveman-end -->
