;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/radian-software/straight.el#the-recipe-format
;; (package! another-package
;;   :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;; (package! builtin-package :recipe (:nonrecursive t))
;; (package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see radian-software/straight.el#279)
;; (package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;; (package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;; (unpin! pinned-package)
;; ...or multiple packages
;; (unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (unpin! t)
;; (package! seq :recipe (:type built-in))
;; gptel is declared (and pinned) by `:tools llm' -- don't re-declare it here.
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))
(package! perfect-margin)
(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el"))
;; Required by `claude-code-ide-emacs-tools-setup' -- without it the MCP
;; server refuses to start and Emacs-side tools are unavailable to the agent.
(package! web-server)
(package! vulpea)

;; Rice pass (docs/decisions.org ADR-022): animated cursor-motion pulse,
;; replacing the plain nav-flash blink Doom's :ui nav-flash module would
;; otherwise provide.
(package! pulsar)

;; Torrents (docs/decisions.org ADR-030): Emacs front-end for a local
;; transmission-daemon over its RPC API. No Doom module ships a torrent
;; client, and this is the only maintained Emacs one.
(package! transmission)

;; EPUB reading (docs/decisions.org ADR-034): Doom ships no ebook module, and
;; nov.el is the only maintained Emacs EPUB renderer.
(package! nov)

;; elfeed-tube's mpv half. `:app rss +youtube' declares elfeed-tube only, but
;; its config.el binds `C-c C-f' and `C-c C-w' to `elfeed-tube-mpv-follow-mode'
;; and `elfeed-tube-mpv-where' unconditionally -- and those live in
;; elfeed-tube-mpv.el, a separate MELPA package. Without these two declarations
;; both keys are `void-function'. `mpv' is elfeed-tube-mpv's own dependency
;; (Package-Requires: (mpv "0.2.0")); it drives the mpv binary over its JSON
;; IPC socket, which is how follow-along knows the playback position.
(package! mpv)
(package! elfeed-tube-mpv)

(package! citar)

;; org-roam-ui -- not on MELPA as of writing. Recipe confirmed via its own
;; GitHub README (WebSearch/WebFetch; no local straight checkout existed to
;; verify against directly). :files must include "out" -- the prebuilt
;; static web-UI assets shipped in the repo -- or the package installs with
;; nothing for its server to serve.
(package! org-roam-ui
  :recipe (:host github :repo "org-roam/org-roam-ui" :files ("*.el" "out")))

;; org-fc -- not on MELPA/ELPA (confirmed via its own install docs at
;; leonrische.me/fc/installation.html; no local straight checkout existed to
;; verify against -- only an el-get recipe file for the GitHub mirror was
;; found locally, at
;; ~/.config/emacs/.local/straight/repos/el-get/recipes/org-fc.rcp). The
;; canonical repo per org-fc's own docs is sourcehut, not the l3kn/org-fc
;; GitHub mirror; used directly below via a generic git recipe rather than
;; guessing at straight's sourcehut host-keyword support. :files must
;; include "awk" -- org-fc shells out to an awk script bundled in the repo
;; for fast tag-based card scanning, and straight's :defaults file set
;; excludes non-elisp files like it; "demo.org" is upstream's own
;; recipe example, harmless to carry along.
(package! org-fc
  :recipe (:type git :repo "https://git.sr.ht/~l3kn/org-fc"
           :files (:defaults "awk" "demo.org")))

(package! org-transclusion)
;; consult-notes' own recipe (fetched from MELPA's recipe repo, already
;; mirrored locally) points at Codeberg, not GitHub -- no explicit `:recipe'
;; needed here since straight resolves it automatically the same way it does
;; for the plain `(package! foo)' declarations above.
(package! consult-notes)
