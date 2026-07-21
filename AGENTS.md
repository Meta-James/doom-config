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
- Never commit. Never push. Never amend/rebase/reset/clean/rewrite history
  without explicit in-the-moment permission. Read-only git commands and diffs
  are fine. At a stable checkpoint, say the tree is ready for the user to review
  and commit — don't do it yourself. Enforced technically for Claude Code via
  `.claude/settings.json`, not just stated here — see `docs/decisions.org`
  ADR-009.
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
- One tool per responsibility (one chat client, one completion engine, one
  primary agentic-coding frontend). Don't add a second without a clearly
  distinct, frequently-useful role the first can't cover.

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
