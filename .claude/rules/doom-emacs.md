---
paths:
  - "*.el"
  - "**/*.el"
---

# Doom Emacs conventions

- **This config is literate (ADR-035).** All edits go in `$DOOMDIR/config.org`;
  `init.el`, `packages.el`, `config.el`, `~/.bashrc`, `~/.inputrc` and
  `~/.gitconfig` are tangled output and are overwritten on the next tangle.
  Within `config.org`, module activation still belongs in the `init.el` block,
  package declarations in the `packages.el` block, and configuration in the
  `config.el` sections.
- Tangling runs on every `doom sync` and on every save of `config.org` (that
  save hook is narrowed to `config.org` alone, so saving `docs/*.org` does not
  trigger it). Edits to the `init.el` block land one sync late, because Doom
  loads `init.el` before tangling.
- Use `after!` for config that depends on a package being loaded; `use-package!`
  for package configuration; `map!` for keybindings; `set-popup-rule!` for
  temporary buffers (chat, agent, diff-review popups).
- Any `init.el`/`packages.el` edit requires `doom sync` afterward. Any module or
  package change requires a clean `doom doctor` before the work is considered
  done — don't report success without actually running it and reading the
  output.
- Use `~/.config/emacs/bin/doom` (absolute path), not bare `doom`, when invoking
  from a script or subprocess — see
  `docs/ai/troubleshooting.org::tshoot-path-tilde`.
- Don't unpin packages casually; if a pin needs removing, document why in
  `docs/decisions.org`.
- Check current module names against `~/.config/emacs/sources/doom+/modules/`
  before assuming a module name from an older config example is still correct —
  Doom has renamed modules before (`doom-dashboard` → `dashboard`) and will
  again.
