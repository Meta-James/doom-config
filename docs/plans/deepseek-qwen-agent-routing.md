# DeepSeek + Qwen (+ Claude) via existing tooling, tiered by OpenCode's own router plugin

*Status: researched and drafted 2026-09-09/10, not yet implemented — nothing
installed. This is a plan, not an ADR; promote the accepted shape of it into
`docs/decisions.org` as ADR-045 when implementation actually starts, per
this repo's own convention that decisions.org is where implemented/accepted
architecture lives.*

## Context

Follows directly from ADR-044 (`docs/decisions.org`, accepted, not yet
implemented — agent-shell as a secondary agentic-coding frontend for Codex).
The user then asked for DeepSeek and Qwen access too (latest models, hosted
elsewhere since their hardware can't run these locally), with automatic
cheap/expensive tiering so routine work uses a cheap model and hard problems
escalate to a powerful one, without fully knowing current best practice
("things are moving fast") — hence the research-heavy shape of this doc.

Three planning rounds happened before this was ready to promote to an ADR:

1. First draft proposed a self-hosted LiteLLM proxy in front of official
   DeepSeek + Alibaba DashScope APIs, with hand-written heuristic routing.
2. User pushed back: does this use existing tooling, is it Emacs-first, how
   do people with similar setups actually do this, they want Claude added
   to agent-shell too despite it being redundant with claude-code-ide.el,
   are DeepSeek/Qwen really the most open models, and does a real
   difficulty-router already exist rather than hand-rolling one. Fresh
   research answered all of these and the LiteLLM proxy was dropped
   entirely in favor of tooling that already exists in the OpenCode/
   agent-shell ecosystem.
3. User then said they're okay with silent fallback between providers —
   removing the objection that had kept the design's escalation-to-Claude
   step manual/human-gated. The router's top tier now lands on Claude
   automatically.

## Research findings that shaped the design

- **OpenCode already ships DeepSeek as a built-in provider** — `/connect`,
  official API, OpenAI-compatible, no proxy needed. DeepSeek V4's
  checkpoints are MIT-licensed.
- **Qwen has no built-in OpenCode provider**, but Alibaba's DashScope
  "Coding Plan" endpoint is itself OpenAI-compatible
  (`https://coding-intl.dashscope.aliyuncs.com/v1`, mainland variant at
  `coding.dashscope.aliyuncs.com`), so it slots into OpenCode's existing
  custom-provider mechanism (`@ai-sdk/openai-compatible`) the same way the
  ADR-044 research already found for Ollama — no new infra class, just one
  more provider block. Qwen3.8-27B and Qwen3-235B-A22B are Apache-2.0.
  Note: Qwen's free OAuth tier was discontinued 2026-04-15 — this is a paid
  plan now, not a free one.
- **A real difficulty-tiering plugin already exists for OpenCode**:
  `opencode-model-router` (npm, GPL-3.0, ~110 stars, 230 commits) does
  fast/medium/heavy delegation via a prompt-injected task taxonomy the
  orchestrator model reads and acts on — not a trained classifier (there
  isn't a good current one; LMSYS's RouteLLM is stale/inactive since 2024),
  not a separate service, just OpenCode-native config. This replaces a
  hand-rolled proxy entirely. Honest limitations: advisory enforcement by
  default (a subagent can ignore its tier cap unless hard-blocking is
  turned on), ~800-1,300 tokens of prompt overhead per message, no adaptive
  learning, and none of its 7 built-in presets target DeepSeek/Qwen
  specifically — a custom "hybrid" preset (one of its 7 built-in preset
  *types*, meant for mixing providers across tiers) is needed either way.
- **gptel (already installed, already this repo's chat/transform tool) can
  take DeepSeek and Qwen as ordinary backends for free** — both APIs are
  OpenAI-compatible, and `gptel-make-openai` already exists as the pattern
  used for the current secondary OpenAI backend (`docs/ai/providers.org`).
  This is the actual best-use-of-existing-tooling / Emacs-first answer for
  anything that's chat or a focused transform rather than full repo-wide
  agentic work — zero new packages, zero new services, reuses
  `+pass-get-secret` exactly as-is, and the tier choice is just which
  backend the user picks in the already-existing `gptel-menu`
  (`SPC o l m`).
- **On openness**: DeepSeek V4 (MIT) and Qwen3.8/Qwen3-235B-A22B (Apache
  2.0) are already close to the most permissively-licensed flagship-class
  coding models available in 2026. Two names worth knowing even if not
  adopted now: GLM-5.2 (plain MIT, strongest SWE-bench Pro score among
  MIT-licensed models) is a same-openness peer; Kimi K3 has the best raw
  benchmark score of the open-weight field but sits under a more
  restrictive custom license with conditions for large-scale commercial/MaaS
  use — worth naming precisely because it's *not* as open despite the
  benchmark headline, which is what was actually asked.
- **On "more tokens"**: yes, multiple providers is the real 2026 pattern for
  a hobbyist setup, not one bigger contract. Groq's free tier (30k TPM,
  14,400 requests/day, LPU hardware) serves Qwen3-32B and
  DeepSeek-R1-Distill — smaller/distilled versions, not the flagship
  V4/Max tier, but genuinely free and fast. Cerebras (wafer-scale hardware,
  very high tokens/sec) hosts larger open models at low-but-nonzero cost.
  Recommendation: add Groq later as a free extra rung (Phase 2 below), once
  the paid DeepSeek/DashScope rungs are actually in use and their limits
  are felt — don't provision every provider on day one.
- **On Claude via agent-shell**: the user wants it despite ADR-044 already
  finding it strictly worse than claude-code-ide.el on the Claude axis
  specifically (separate `claude-agent-acp` npm package and login, no reuse
  of the existing `claude` CLI session, none of claude-code-ide.el's
  Emacs-side MCP tools exposed back to the agent). Adding it anyway for
  unified-UI convenience is a legitimate, explicitly-acknowledged trade —
  claude-code-ide.el stays primary/preferred for real Claude work (ADR-004
  unchanged); the agent-shell Claude session is a convenience extra, not a
  replacement.

## Design

Two layers, matching this repo's existing responsibility split
(`docs/ai/architecture.org`) rather than inventing a new one.

### Layer 1 — gptel gets DeepSeek and Qwen backends (chat/focused transform)

Trivial addition, worth doing regardless of the rest:
- `gptel-make-openai` backend for DeepSeek (`api/deepseek` pass credential,
  DeepSeek's official OpenAI-compatible endpoint).
- `gptel-make-openai` backend for Qwen (`api/dashscope` pass credential,
  DashScope's coding-plan OpenAI-compatible endpoint).
- Both follow the exact pattern the existing OpenAI secondary backend
  already uses (`docs/ai/providers.org` row 23) — no new abstraction.
- Update `docs/ai/providers.org`'s credential table with both new rows.

### Layer 2 — agent-shell gains three more backends (repo-wide agentic work)

Extends ADR-044 (Codex, already accepted) rather than replacing it:

1. **OpenCode**, configured with:
   - DeepSeek as OpenCode's built-in provider.
   - Qwen as a custom `openai-compatible` provider pointed at DashScope's
     coding endpoint.
   - Both API keys referenced as `{env:DEEPSEEK_API_KEY}` /
     `{env:DASHSCOPE_API_KEY}` in `opencode.json` — never pasted into
     tracked config or stored via OpenCode's own `/connect` credential
     store, per this repo's pass-only credential rule
     (`.claude/rules/security.md`). The actual secret material is injected
     the way `config.org:84-87` already demonstrates this repo doing
     subprocess-environment manipulation around an agent launch: Emacs
     calls `+pass-get-secret` for `api/deepseek`/`api/dashscope` and
     `let`-binds `process-environment` just for the OpenCode subprocess
     agent-shell starts, not globally.
   - `opencode-model-router` plugin installed, with a custom "hybrid"
     preset mapping `@fast`→DeepSeek-Flash/Qwen-Flash,
     `@medium`→DeepSeek-Pro/Qwen-Max, `@heavy`→Claude (Opus/Fable-class,
     via OpenCode's own built-in Anthropic provider — its own
     `api/anthropic` pass credential, not the `claude` CLI subscription
     login). This is the full automatic difficulty-router the user asked
     for: fully silent, cheap-to-expensive, no human gate at the top end,
     per the user's explicit "I'm okay with silent fallback between
     providers." That narrows `docs/ai/architecture.org`'s existing "no
     silent fallback between providers" line: still true for gptel and for
     which agent-shell backend a human starts; no longer true for
     `opencode-model-router`'s automatic tier selection inside an OpenCode
     session — needs stating explicitly in that doc, not left standing
     unqualified next to behavior that now contradicts it.
   - **Consequence worth naming plainly**: this means real money can now
     move to Claude automatically, from a purely rule-based/prompt-injected
     classifier with no adaptive learning and advisory-only enforcement by
     default. Worth deciding at implementation time whether to turn on
     `opencode-model-router`'s hard-blocking/cap mode and/or set a spend
     alert on the `api/anthropic` credential used here, rather than relying
     purely on trust in the heuristic. This is a real trade the user is
     choosing, not a gap being smoothed over.
   - The separate agent-shell Claude and Codex sessions (below) remain a
     fully manual, human-chosen alternate path — talking to Claude/Codex
     *directly*, bypassing the router entirely — distinct from the
     router's own automatic `@heavy` tier, which happens to also land on
     Claude but via OpenCode's own Anthropic provider, not via that
     session.
2. **Codex** — unchanged from ADR-044, already accepted.
3. **Claude**, via `@agentclientprotocol/claude-agent-acp` — new,
   explicitly redundant with claude-code-ide.el, added anyway per the
   user's own informed choice above. Same Evil `RET` fix and localleader
   pattern as the other two backends, not a separate config path.

All three share one agent-shell install and one localleader map
(`agent-shell-mode-map`, prefix `,a`), extending rather than duplicating
what ADR-044 already specified for Codex.

## What's genuinely uncertain (verify during implementation, don't assume)

- Exact current DeepSeek V4 / Qwen3.x model-id strings for the
  `opencode-model-router` custom preset — pull from each vendor's live docs
  at implementation time, not from this doc's research snapshot.
- Whether OpenCode's `{env:VAR}` interpolation combined with Emacs-injected
  subprocess environment actually reaches the process the way agent-shell
  launches it — same class of unverified path ADR-044 already flagged for
  local Ollama (issue #526); smoke-test before building the tier config on
  top of it.
- `opencode-model-router`'s advisory-only enforcement — decide during
  implementation whether hard-blocking mode is worth turning on, given it's
  off by default.

## Implementation steps

1. **Credentials**: `pass insert api/deepseek`, `pass insert api/dashscope`
   (Alibaba Cloud Coding Plan key — confirm this is now a paid plan, per
   the free-tier-discontinued finding above, before assuming zero setup
   cost). `api/anthropic` already exists (`docs/ai/providers.org` row 22,
   present but unverified) and is reused as-is for OpenCode's own Anthropic
   provider — the router's automatic `@heavy` tier — no new Claude
   credential needed for that part specifically (separate from the
   agent-shell Claude *session's* own login in step 5). Update
   `docs/ai/providers.org` with the two new rows and this reuse note.
2. **gptel backends** (Layer 1): add both `gptel-make-openai` blocks to
   `config.org`'s existing gptel section, next to the current OpenAI
   backend.
3. **agent-shell package**: `(package! agent-shell :recipe (:host github
   :repo "xenodium/agent-shell"))` in `packages.el`, `use-package!` block in
   `config.org` with the Evil `RET` fix and localleader map (per ADR-044,
   now shared by all three secondary backends).
4. **Codex backend**: as ADR-044 already specified — `npm install -g
   @agentclientprotocol/codex-acp`, `codex login`.
5. **Claude backend**: `npm install -g
   @agentclientprotocol/claude-agent-acp`, its own login via
   `agent-shell-anthropic-make-authentication`.
6. **OpenCode backend**: install OpenCode, configure DeepSeek (built-in)
   and Qwen (custom `openai-compatible` provider) in `opencode.json`, wire
   the pass-sourced env-var injection around the subprocess launch (Layer
   2, step 1 above). **Smoke-test this in isolation before step 7.**
7. **opencode-model-router**: `npm install -g opencode-model-router`, add
   the plugin entry to `opencode.json`, write a custom tiers-override file
   mapping fast/medium/heavy to the DeepSeek/Qwen/Claude models actually
   configured in step 6.
8. **Documentation**: promote this doc's accepted shape into a new ADR-045
   in `docs/decisions.org` extending ADR-044 (not replacing it), full
   structure per this repo's convention (context/drivers/candidates/
   evidence/decision/consequences/rejected-alternatives/validation/
   rollback/revisit). Update `docs/ai/architecture.org`'s diagram/table
   (now: claude-code-ide.el primary, agent-shell secondary with Codex +
   Claude + OpenCode/DeepSeek/Qwen) and the "no silent fallback" narrowing
   described above, and `docs/ai/providers.org`'s credential map (new rows:
   `api/deepseek`, `api/dashscope`, Codex login, agent-shell Claude login,
   plus the `api/anthropic` reuse note from step 1).

## Phase 2 (later, not blocking this plan)

- Groq as an additional free-tier OpenCode/opencode-model-router provider
  (Qwen3-32B, DeepSeek-R1-Distill) for extra free quota once the paid
  DeepSeek/DashScope rungs are actually in use and their limits are felt.
- GLM-5.2 as a same-openness (MIT), strong-benchmark peer to fold into the
  provider mix if DeepSeek/Qwen prove insufficient.
- `opencode-model-router`'s hard-blocking enforcement mode, if the advisory
  default turns out to be ignored in practice.
- The Org/agenda/worktree workflow layer from the second survey doc the
  user originally supplied — still deliberately deferred.

## Verification

- `doom doctor` clean after `packages.el`/`config.org` changes, `doom sync`.
- gptel: both new backends selectable in `gptel-menu`, one real round-trip
  prompt through each.
- agent-shell: one real session per backend (Codex, Claude, OpenCode) — a
  trivial prompt through each, confirming OpenCode actually reaches
  DeepSeek and Qwen (not silently falling through to a default).
- `opencode-model-router`: one message that should classify `@fast` and one
  that should classify `@medium`/`@heavy`, confirm via OpenCode's own
  logs/output which tier actually got used, including a case that should
  reach `@heavy`/Claude.
- Regression check: claude-code-ide.el unaffected.
- `docs/inventory.org` and `docs/ai/providers.org` rows match what's
  actually installed.

## Explicitly not doing here

- No self-hosted LiteLLM proxy (superseded by OpenCode's built-in provider
  + `opencode-model-router`).
- No trained/ML difficulty classifier (still doesn't exist maturely
  self-hosted in 2026; `opencode-model-router`'s heuristic is the closest
  real, maintained tool).
- No OpenRouter account (official per-vendor APIs chosen instead).
- No Groq/Cerebras/GLM-5.2 in this pass — named as Phase 2, not built now.
- No change to claude-code-ide.el's primary status (ADR-004 stands); the
  new agent-shell Claude session is an acknowledged-redundant convenience,
  not a replacement.
- No Org/agenda/worktree automation layer from the second survey doc.
