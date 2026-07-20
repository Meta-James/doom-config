;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-zenburn)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Maximize emacs on startup and resize splash screen
(add-hook 'server-after-make-frame-hook
          (lambda ()
            (set-frame-parameter nil 'fullscreen 'maximized)
            (run-with-timer 0.1 nil #'+doom-dashboard/open (selected-frame))))

(add-to-list 'default-frame-alist '(undecorated . t))

(add-hook 'server-after-make-frame-hook
          (lambda ()
            (set-frame-parameter nil 'fullscreen 'maximized)
            (run-with-timer 0.1 nil #'+doom-dashboard/open (selected-frame))))

;; Center text and limit line width for better readability
(use-package! perfect-margin
  :custom
  (perfect-margin-visible-width 100)  ; adjust to your preferred text column width
  :config
  (perfect-margin-mode t)
  (after! doom-modeline
    (setq mode-line-right-align-edge 'right-fringe)))

;; Better default behavior
;;     - No permanent deletion, use trash
;;     - Smoother scrolling
;;     - Don't bother confirming if you want to leave emacs
(setq delete-by-moving-to-trash t
      scroll-margin 8
      scroll-conservatively 101
      confirm-kill-emacs nil)

;; Doom modeline mods
(after! doom-modeline
  ;; 1) Size / spacing
  (setq doom-modeline-height 28          ; modeline height (pixels-ish)
        doom-modeline-bar-width 3        ; left bar width
        doom-modeline-window-width-limit 85) ; hide extra info in narrow windows

  ;; 2) Icons (turn off if you want max speed / no nerd fonts)
  (setq doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t)

  ;; 3) File name style (popular: show relative name from project)
  (setq doom-modeline-buffer-file-name-style 'relative-to-project)

  ;; 4) Common “noise” toggles
  (setq doom-modeline-minor-modes nil    ; hides minor modes list (usually noisy)
        doom-modeline-mu4e nil
        doom-modeline-gnus nil)

  ;; 5) Git + diagnostics (popular to keep on)
  (setq doom-modeline-vcs t
        doom-modeline-checker-simple-format t)

  ;; 6) Extra info (pick what you like)
  (setq doom-modeline-indent-info nil    ; show indent info (spaces/tabs)
        doom-modeline-buffer-encoding nil ; hide UTF-8, etc. (usually not needed)
        doom-modeline-time nil           ; set to t if you want a clock
        doom-modeline-battery nil))      ; set to t on laptops

;; Save minibuffer history (Vertico likes this)
(after! savehist
  (savehist-mode 1))

;; Preview results as you move (feel free to set to nil if annoying)
(after! consult
  (setq consult-preview-key "M-."))

(map! :leader
      :desc "Search project (ripgrep)" "s p" #'consult-ripgrep)

(after! projectile
  (setq projectile-project-search-path '("~/Documents/")
        projectile-indexing-method 'alien) ; uses external tools (fast)
  (add-to-list 'projectile-globally-ignored-directories ".venv")
  (add-to-list 'projectile-globally-ignored-directories "__pycache__")
  (add-to-list 'projectile-globally-ignored-directories ".mypy_cache")
  (add-to-list 'projectile-globally-ignored-directories ".ruff_cache"))

(after! projectile
  (dolist (p '(".venv" "venv" "__pycache__" ".mypy_cache" ".pytest_cache" ".ruff_cache"))
    (add-to-list 'projectile-globally-ignored-directories p)))

(map! :leader :desc "Magit status" "g s" #'magit-status)

;; VTerm in project root
(defun my/project-vterm ()
  "Open vterm in the current project's root."
  (interactive)
  (let ((default-directory (projectile-project-root)))
    (vterm)))

(map! :leader :desc "Project vterm" "p t" #'my/project-vterm)

(after! envrc
  (envrc-global-mode))

;; Python IDE Setup
(after! flycheck
  (flycheck-define-checker python-ruff
    "A Python linter using Ruff."
    :command ("ruff" "check"
              "--output-format" "concise"
              "--stdin-filename" source-original
              "-")
    :standard-input t
    :error-patterns
    ((error line-start (file-name) ":" line ":" column ": " (message) line-end))
    :modes (python-mode python-ts-mode))

  (add-to-list 'flycheck-checkers 'python-ruff))

(after! (flycheck lsp-mode)
  (defun my/python-flycheck-chain-lsp-then-ruff ()
    "In Python buffers, run LSP diagnostics first, then Ruff."
    (when (and (memq major-mode '(python-mode python-ts-mode))
               (bound-and-true-p lsp-mode)
               (flycheck-valid-checker-p 'lsp)
               (flycheck-valid-checker-p 'python-ruff))
      (setq-local flycheck-checker 'lsp)
      (flycheck-remove-next-checker 'lsp 'python-ruff)
      (flycheck-add-next-checker 'lsp 'python-ruff 'append)))

  (add-hook 'lsp-managed-mode-hook #'my/python-flycheck-chain-lsp-then-ruff))


(after! python
  ;; Use Black as the formatter for Python (file-based, respects pyproject.toml)
  (set-formatter! 'black '("black" "-q" "--stdin-filename" (or buffer-file-name "stdin.py") "-"))
  (setq-hook! 'python-mode +format-with 'black)
  (setq-hook! 'python-ts-mode +format-with 'black))

(defun my/python-ruff-fix-buffer ()
  "Run `ruff check --fix` on a temp file, then replace the buffer with the fixed code.
Does not write to disk unless you save."
  (interactive)
  (unless (executable-find "ruff")
    (user-error "Ruff not found on PATH"))
  (unless buffer-file-name
    (user-error "Save the file once so Ruff can resolve project settings"))

  (let* ((root (or (locate-dominating-file default-directory "pyproject.toml")
                   default-directory))
         (tmp  (make-temp-file (expand-file-name "ruff-fix-" root) nil ".py"))
         (orig (buffer-string))
         (orig-point (point)))
    (unwind-protect
        (progn
          ;; write buffer to temp file
          (with-temp-file tmp
            (insert orig))

          ;; run ruff fix on temp file; ignore exit code
          (call-process "ruff" nil "*ruff-fix*" nil
                        "check" "--fix" tmp)

          ;; read fixed temp file back into buffer
          (let ((fixed (with-temp-buffer
                         (insert-file-contents tmp)
                         (buffer-string))))
            (if (string= orig fixed)
                (message "Ruff: no changes")
              (erase-buffer)
              (insert fixed)
              (goto-char (min orig-point (point-max)))
              (message "Ruff: fixes applied to buffer (not saved)"))))
      (when (file-exists-p tmp)
        (delete-file tmp)))))

(map! :after python
      :map (python-mode-map python-ts-mode-map)
      :localleader
      "r f" #'my/python-ruff-fix-buffer)

(after! lsp-pyright
  (setq lsp-pyright-typechecking-mode "strict"))

;; Add jk as an escape sequence
(after! evil-escape
  (setq evil-escape-key-sequence "jk"
        evil-escape-delay 0.20)
  (evil-escape-mode 1))

;; AI: chat and focused transformation via gptel.
;; Credentials come from Doom's `:tools pass' module (`+auth' flag), never
;; hand-rolled shell wrappers. See docs/ai/providers.org for the full
;; credential map and docs/decisions.org ADR-003/004 for why the leader
;; namespace and provider choices look like this.
(after! gptel
  (setq gptel-default-mode 'org-mode)

  ;; Anthropic is the default backend. `:models' is deliberately omitted on
  ;; both backends below -- gptel ships and maintains its own current model
  ;; registry (gptel--anthropic-models / gptel--openai-models), so omitting
  ;; `:models' tracks upstream automatically instead of hardcoding names that
  ;; will be stale within months.
  (setq-default
   gptel-backend (gptel-make-anthropic "Claude"
                   :key (lambda () (+pass-get-secret "api/anthropic"))
                   :stream t)
   gptel-model 'claude-sonnet-5)

  ;; OpenAI kept as a secondary backend, explicitly selectable via `gptel-menu'.
  (gptel-make-openai "ChatGPT"
    :key (lambda () (+pass-get-secret "api/openai"))
    :stream t)

  ;; Reusable rewrite/transform directives, selectable from `gptel-rewrite''s
  ;; own transient (its "s" suffix edits/picks the active directive) instead
  ;; of bespoke commands that paste results into a scratch buffer for manual
  ;; copy-paste.
  (setf (alist-get 'clearer gptel-directives)
        "Make the following clearer and more concise while keeping the meaning. Return only the rewritten text.")
  (setf (alist-get 'formal gptel-directives)
        "Rewrite the following in a more formal tone. Return only the rewritten text.")
  (setf (alist-get 'summarize gptel-directives)
        "Summarize the following in 3-5 bullet points.")

  (set-popup-rule! "^\\*gptel\\*"
    :side 'right :size 0.42 :quit t :select t :ttl nil))

(defun my/gptel-add-diagnostics ()
  "Add the current buffer's Flycheck diagnostics to gptel's context.
gptel has no built-in equivalent -- `gptel-add'/`gptel-add-file' cover
region/buffer/project-file context already."
  (interactive)
  (unless (bound-and-true-p flycheck-mode)
    (user-error "Flycheck is not active in this buffer"))
  (require 'flycheck)
  (let ((errors (flycheck-overlay-errors-in (point-min) (point-max)))
        (src (or (buffer-file-name) (buffer-name)))
        (buf (get-buffer-create "*gptel-diagnostics-context*")))
    (unless errors
      (user-error "No Flycheck diagnostics in this buffer"))
    (with-current-buffer buf
      (erase-buffer)
      (insert (format "Flycheck diagnostics for %s:\n\n" src))
      (dolist (err errors)
        (insert (format "%s:%s: %s: %s\n"
                        src
                        (flycheck-error-line err)
                        (flycheck-error-level err)
                        (flycheck-error-message err)))))
    (gptel-context--add-buffer buf)
    (message "Added %d diagnostic(s) to gptel context." (length errors))))

;; SPC a is the AI namespace outright (see docs/decisions.org ADR-003) --
;; this permanently removes Doom's default `embark-act' binding at SPC a,
;; confirmed acceptable since Embark's leader shortcut isn't needed here.
(map! :leader "a" nil)
(map! :leader
      (:prefix ("a" . "AI")
       :desc "Chat (popup)"           "i" #'gptel
       :desc "Send region"            "s" #'gptel-send
       :desc "Add context (region/buffer/files)" "a" #'gptel-add
       :desc "Add diagnostics context" "d" #'my/gptel-add-diagnostics
       :desc "Rewrite/transform"      "r" #'gptel-rewrite
       :desc "Model/provider/directive menu" "m" #'gptel-menu
       :desc "Agent (Claude Code)"    "g" #'claude-code-ide-menu
       :desc "Project vterm"          "t" #'my/project-vterm))

;; Inline completion: Copilot overlay + Next Edit Suggestions.
;; TAB/C-TAB below are copilot.el's own default bindings (`copilot-completion-map'
;; and `copilot-nes-mode-map'), not re-bound here -- both are activated via
;; overlay-local/filtered keymaps that fall through to Company/indent/yasnippet
;; when no suggestion is pending. See docs/ai/keybindings.org for the precedence
;; analysis and docs/decisions.org ADR-007.
(use-package! copilot
  :hook ((prog-mode . copilot-mode)
         (prog-mode . copilot-nes-mode)))

(after! copilot
  (set-face-attribute 'copilot-overlay-face nil
                      :foreground "#9FC59F"  ;; zenburn green+2, bright but still subtle
                      :background 'unspecified))

;; Primary agentic coding workflow: claude-code-ide.el drives the already-
;; installed Claude Code CLI over MCP. vterm backend and ediff-based review
;; match this config's existing incumbents (docs/decisions.org ADR-004).
;; Settings below are set explicitly even where they match upstream defaults,
;; so an upstream default change doesn't silently change behavior here.
(use-package! claude-code-ide
  :commands (claude-code-ide-menu)
  :init
  (setq claude-code-ide-terminal-backend 'vterm
        claude-code-ide-diagnostics-backend 'flycheck
        claude-code-ide-use-ide-diff t)
  :config
  (claude-code-ide-emacs-tools-setup))

;; EXWM
;; (defun my/exwm-screen-layout ()
;;   "Configure monitors: external on the left of the laptop."
;;   (start-process-shell-command
;;    "xrandr" nil
;;    ;; External HDMI-1 on the left, laptop eDP-1 on the right
;;    "xrandr --output HDMI-1 --auto --left-of eDP-1 --output eDP-1 --auto --primary"))

;; ;; Apply once at startup
;; (add-hook 'exwm-init-hook #'my/exwm-screen-layout)

;; ;; Optional: re-apply on EXWM restart (only if your EXWM provides this hook)
;; (when (boundp 'exwm-restart-hook)
;;   (add-hook 'exwm-restart-hook #'my/exwm-screen-layout))

;; ;; RandR integration (multi-monitor awareness)
;; (require 'exwm-randr)

;; ;; Re-apply layout when screens change (dock/undock, power cycle, etc.)
;; (add-hook 'exwm-randr-screen-change-hook #'my/exwm-screen-layout)

;; ;; Optional: pin workspaces to monitors
;; ;; 0–4 on HDMI-1 (left), 5–9 on eDP-1 (right)
;; (setq exwm-randr-workspace-output-plist
;;       '(0 "HDMI-1" 1 "HDMI-1" 2 "HDMI-1" 3 "HDMI-1" 4 "HDMI-1"
;;         5 "eDP-1"  6 "eDP-1"  7 "eDP-1"  8 "eDP-1"  9 "eDP-1"))

;; (exwm-randr-mode 1)

;; ;; Make class name the buffer name
;; (add-hook 'exwm-update-class-hook
;;           (lambda ()
;;             (exwm-workspace-rename-buffer exwm-class-name)))

;; ;; Global keybindings.
;; (unless (get 'exwm-input-global-keys 'saved-value)
;;   (setq exwm-input-global-keys
;;         `(
;;           ;; Helpful Commands
;;           ([?\s-/] . exwm-input-release-keyboard)
;;           ([?\s-?] . exwm-reset)
;;           ;; Toggles
;;           ([?\s-F] . exwm-floating-hide)
;;           ([?\s-f] . exwm-floating-toggle-floating)
;;           ([?\s-m] . exwm-layout-toggle-mode-line)
;;           ([f11] . exwm-layout-toggle-fullscreen)
;;           ;; Workspace Management
;;           ([?\s-w] . exwm-workspace-switch)
;;           ([?\s-W] . exwm-workspace-swap)
;;           ([?\s-\C-w] . exwm-workspace-move)
;;           ;; Switch workspace with super+[0-9]
;;           ([?\s-0] . (lambda () (interactive) (exwm-workspace-switch-create 0)))
;;           ([?\s-1] . (lambda () (interactive) (exwm-workspace-switch-create 1)))
;;           ([?\s-2] . (lambda () (interactive) (exwm-workspace-switch-create 2)))
;;           ([?\s-3] . (lambda () (interactive) (exwm-workspace-switch-create 3)))
;;           ([?\s-4] . (lambda () (interactive) (exwm-workspace-switch-create 4)))
;;           ([?\s-5] . (lambda () (interactive) (exwm-workspace-switch-create 5)))
;;           ([?\s-6] . (lambda () (interactive) (exwm-workspace-switch-create 6)))
;;           ([?\s-7] . (lambda () (interactive) (exwm-workspace-switch-create 7)))
;;           ([?\s-8] . (lambda () (interactive) (exwm-workspace-switch-create 8)))
;;           ([?\s-9] . (lambda () (interactive) (exwm-workspace-switch-create 9)))
;;           ;; Window Management
;;           ([?\s-\C-v] . evil-window-vsplit)
;;           ([?\s-z] . evil-window-split)
;;           ([?\s-b] . ibuffer)
;;           ([?\s-B] . kill-current-buffer)
;;           ([?\s-C] . +workspace/close-window-or-workspace)
;;           ([?\s-x] . doom/open-scratch-buffer)
;;           ;; Change window focus with super+h,j,k,l
;;           ([?\s-h] . evil-window-left)
;;           ([?\s-j] . evil-window-down)
;;           ([?\s-k] . evil-window-up)
;;           ([?\s-l] . evil-window-right)
;;           ;; Move windows around using super+shift+h,j,k,l
;;           ([?\s-H] . +evil/window-move-left)
;;           ([?\s-J] . +evil/window-move-down)
;;           ([?\s-K] . +evil/window-move-up)
;;           ([?\s-L] . +evil/window-move-right)
;;           ;; Essential Programs
;;           ([?\s-d] . dired)
;;           ([?\s-t] . (lambda () (interactive)
;;                        (start-process-shell-command "terminal" "*terminal*" "xfce4-terminal")))
;;           ;; Launch application.
;;           ([?\M-\s-7] . (lambda (command)
;;                           (interactive (list (read-shell-command "$ ")))
;;                           (start-process-shell-command command nil command))))))

;; ;; Line-editing shortcuts
;; (unless (get 'exwm-input-simulation-keys 'saved-value)
;;   (setq exwm-input-simulation-keys
;;         '(([?\C-b] . [left])
;;           ([?\C-f] . [right])
;;           ([?\C-p] . [up])
;;           ([?\C-n] . [down])
;;           ([?\C-a] . [home])
;;           ([?\C-e] . [end])
;;           ([?\M-v] . [prior])
;;           ([?\C-v] . [next])
;;           ([?\C-d] . [delete])
;;           ([?\C-k] . [S-end delete])
;;           ([?\s-c] . [?\C-c])
;;           ([?\s-v] . [?\C-v]))))

;; ;; Enable EXWM
;; (exwm-enable)

;; ;; Open Workspaces and start programs?
