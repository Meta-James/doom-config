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

;; ChatGPT Integration
(defun my/pass-get (entry)
  "Return first line of `pass ENTRY` or nil."
  (when (executable-find "pass")
    (let* ((out (string-trim (shell-command-to-string (format "pass %s" entry))))
           (first (car (split-string out "\n" t))))
      (unless (or (null first) (string-empty-p first))
        first))))

(let ((key (my/pass-get "api/openai")))
  (when key
    (setenv "OPENAI_API_KEY" key)))

(after! gptel
  ;; Key from pass
  (setq gptel-api-key (lambda () (my/pass-get "api/openai")))

  ;; Set *defaults* (buffer-local vars need setq-default)
  (setq-default
   gptel-backend (gptel-make-openai "OpenAI"
                   :key (lambda () (my/pass-get "api/openai"))
                   :stream t
                   :models '(gpt-4o-mini gpt-4o))
   gptel-model 'gpt-4o-mini
   gptel-default-mode 'org-mode)

  ;; Popup rule for gptel buffers
  (set-popup-rule! "^\\*gptel\\*"
    :side 'right :size 0.42 :quit t :select t :ttl nil))

(defun my/gptel--prompt-rewrite (instruction)
  "Rewrite the active region using INSTRUCTION, replacing the region."
  (unless (use-region-p)
    (user-error "Select a region first"))
  (let* ((orig (buffer-substring-no-properties (region-beginning) (region-end)))
         (buf  (get-buffer-create "*gptel-rewrite*"))
         (start (region-beginning))
         (end   (region-end)))
    ;; Make sure we have a popup buffer
    (with-current-buffer buf
      (erase-buffer)
      (org-mode))
    (pop-to-buffer buf)
    ;; Ask for ONLY the rewritten text so it's easy to paste back
    (with-current-buffer buf
      (insert (format "Rewrite the text following these instructions:\n- %s\n\nReturn ONLY the rewritten text.\n\nTEXT:\n%s"
                      instruction orig))
      ;; Send prompt
      (gptel-send)
      ;; You manually copy/paste the result back (reliable & simple).
      ;; If you want auto-replace, we can wire that up next.
      )))

(defun my/gptel-rewrite-clearer () (interactive)
       (my/gptel--prompt-rewrite "Make it clearer and more concise while keeping the meaning."))

(defun my/gptel-rewrite-formal () (interactive)
       (my/gptel--prompt-rewrite "Rewrite in a more formal tone."))

(defun my/gptel-summarize () (interactive)
       (my/gptel--prompt-rewrite "Summarize in 3-5 bullet points."))

(defun my/gptel-send-buffer ()
  "Send the whole buffer to the current gptel session."
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (gptel-send)))

;; Reclaim SPC a as Doom's "Apps" prefix (instead of embark-act)
(after! doom-keybinds
  (map! :leader "a" nil)
  (map! :leader
        (:prefix ("a" . "apps"))))

(map! :leader
      (:prefix ("a" . "apps")
               (:prefix ("i" . "AI")
                :desc "Chat (popup)" "i" #'gptel
                :desc "Send region"  "s" #'gptel-send
                :desc "Send buffer"  "b" #'my/gptel-send-buffer
                (:prefix ("r" . "Rewrite")
                 :desc "Clearer"  "c" #'my/gptel-rewrite-clearer
                 :desc "Formal"   "f" #'my/gptel-rewrite-formal
                 :desc "Summarize" "s" #'my/gptel-summarize))))

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

(after! copilot
  (set-face-attribute 'copilot-overlay-face nil
                      :foreground "#9FC59F"  ;; zenburn green+2, bright but still subtle
                      :background 'unspecified))
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
