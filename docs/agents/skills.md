# Engineering skills

This repo's curated default subset of the `mattpocock-skills` Claude Code
plugin, adopted in [ADR-016](../decisions.org) (`adr-mattpocock-skills-adoption`).
The plugin ships eleven skills; these six are the ones documented here as the
go-to toolkit for work in this repo. The other five (`prototype`, `research`,
`resolving-merge-conflicts`, `wizard`, `grilling`) remain installed and usable,
just not part of the documented default — reach for them when they genuinely
fit, same as any other available skill.

## `tdd`

Recommended for well-specified feature work — a clear, testable behavior
where writing the test first makes sense. **Not** a replacement for this
repo's existing default workflow (`docs/ai/workflows.org`, `wf-agent`:
plan → edit → test → Ediff review). Most edits here are exploratory
Emacs-config tweaks (keybindings, popup rules, UI behavior) that don't lend
themselves to test-first; for those, keep using the existing workflow. Reach
for `tdd` specifically when the task already has a crisp spec and an
observable pass/fail.

## `mattpocock-skills:code-review`

**Always invoke by this full, namespaced name** — this repo also has a
built-in skill literally named `code-review` (correctness/simplification/
efficiency findings, with `--fix`/`--comment`/`ultra` modes; see `CLAUDE.md`'s
"Session-specific guidance" section for `/code-review ultra`). The two are
genuinely different tools, not duplicates:

- `code-review` (built-in): finds defects and reuse/simplification/efficiency
  cleanups in a diff.
- `mattpocock-skills:code-review`: checks changes against two axes —
  **Standards** (does the code follow this repo's documented standards?) and
  **Spec** (does it match what the originating issue/spec asked for?) — via
  two parallel sub-agent reviews.

Use the built-in one to hunt bugs and cleanup opportunities; use
`mattpocock-skills:code-review` to check conformance against
`docs/standards.org` and a GitHub issue/spec.

## `codebase-design`

Deep-module vocabulary for designing interfaces, finding deepening
opportunities, and deciding where a seam goes. Per ADR-016's scope, this is
currently applied to the meta-docs/AI-tooling layer (skill files, `docs/`
structure) — not to `init.el`/`packages.el`/`config.el`. If a future decision
extends this repo's use of agent skills into actual Elisp module design,
revisit that scope explicitly rather than assuming it.

## `writing-for-agents`

Use when creating or editing skills, or modifying `AGENTS.md`/`CLAUDE.md` —
which is most of what changes in this meta-docs layer.

## `diagnosing-bugs`

A diagnosis loop for hard bugs and performance regressions. Complements,
rather than replaces, `docs/ai/troubleshooting.org`: per `AGENTS.md`/`CLAUDE.md`,
check `troubleshooting.org` first for a problem that may already be logged
there; reach for `diagnosing-bugs` when the problem is novel and needs an
actual investigation loop, not a lookup.

## `domain-modeling`

Scoped narrowly here: sharpen and record terminology **within** this repo's
existing `docs/*.org` files and `docs/decisions.org` ADR log. This repo
deliberately does **not** maintain a separate `CONTEXT.md`-style domain-model
file — see `docs/agents/domain.md`. Adopting this skill does not reopen that
decision; don't create a new domain-model artifact under this skill's
prompting.
