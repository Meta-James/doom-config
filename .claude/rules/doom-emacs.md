---
paths:
  - "*.el"
  - "**/*.el"
---

# Doom Emacs conventions

- Module activation belongs in `init.el`, package declarations in `packages.el`,
  configuration in `config.el` (or `config/*.el` loaded via `load!`, once the
  subsystem is stable enough to justify the split — see `docs/standards.org`).
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
