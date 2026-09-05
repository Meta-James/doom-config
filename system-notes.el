;;; system-notes.el -*- lexical-binding: t; -*-

;; Hand-maintained, NOT tangled. Unlike `config.el'/`init.el'/`packages.el',
;; this file has no `config.org' source block -- it is loaded directly via
;; `(load! "system-notes")' in config.org's "System-replication notes
;; generator" section (see that heading's :ID: system-notes-generator-anchor).
;; Edit this file itself.
;;
;; Generator for the self-documenting system-replication notes (zettelkasten-
;; integration plan, workstream 6): installed packages, keybindings, and
;; incidents from docs/ai/troubleshooting.org, written as static Vulpea-
;; indexed notes under ~/org/roam/system/. Introspection-based (live
;; `straight--build-cache', Doom's module list via `doom-module-list'/
;; `doom-package-list'), annotated with rationale pulled from config.org /
;; docs/decisions.org. Manually triggered, not wired into `doom sync'.
;; Generated notes are pure/disposable; personal annotation lives in separate
;; notes that `org-transclusion' them in.
;;
;;; Acceptance criteria every generated item is supposed to satisfy (plan §8):
;;   1. States what the thing does FOR YOU, not what it is.
;;   2. Names at least one concrete situation where you'd reach for it.
;;   3. Explicitly flags whether it's currently unused/underused.
;; This generator BAKES IN THE STRUCTURE (every package/binding heading gets
;; fixed "What it does" / "When you'd reach for it" / "Usage status"
;; subheadings) but does NOT fabricate situational prose it can't verify --
;; "does this teach a newcomer" is not something a first pass can fully
;; automate (see the anchor heading's own commentary in config.org). Where
;; real data exists (a package's own `lm-summary' one-liner, a command's
;; docstring, whether config.org actually mentions the thing) it is used;
;; where it doesn't, the note says so explicitly with a placeholder marked
;; for human/agent follow-up during review, rather than guessing.
;;
;;; Package-list source decision (see zettelkasten-integration-plan.md §8,
;; and AGENTS.md: "Doom-first... never package-install or a second package
;; manager" -- Doom uses straight, not package.el):
;;   - `package-alist' is NOT used. Doom sets `package-enable-at-startup' to
;;     nil (`~/.config/emacs/lisp/doom.el') specifically so package.el's own
;;     bookkeeping never runs; `package-alist' is empty/unreliable here.
;;   - `straight--build-cache' (a hash table keyed by package name, loaded
;;     eagerly at Doom startup via `straight--load-build-cache') is the real,
;;     live "what's actually built and present" registry -- verified against
;;     `~/.config/emacs/.local/straight/repos/straight.el/straight.el'.
;;   - `doom-package-list' (`~/.config/emacs/lisp/doom-packages.el') is
;;     Doom's own API for "what packages does this set of enabled modules
;;     declare", read from every enabled module's own packages.el (not just
;;     this repo's `packages.el' -- this is exactly what surfaces the
;;     ~55 packages installed via Doom modules that config.org never names).
;;   - Every package name this generator writes a note for is cross-checked
;;     against `straight--build-cache' so a note is never generated for
;;     something declared-but-not-actually-installed.
;;
;;; Keybinding-introspection coverage -- what is NOT covered (be honest about
;; this rather than pretend `SPC h b b' is fully replicated):
;;   - Only `doom-leader-map' (the `SPC'-prefixed leader map created by
;;     Doom's `map!' `:leader') is walked. Evil state maps
;;     (`evil-normal-state-map' etc.), localleader bindings, and mode-local
;;     keymaps are NOT walked.
;;   - which-key's own resolution (`:desc' labels, `:which-key' replacement
;;     rules) is used when available via the private
;;     `which-key--get-keymap-bindings' function, because it is the only
;;     thing that resolves prefix labels the way `SPC h b b' would show them.
;;     This is a private, unversioned which-key API and may break on a
;;     which-key upgrade; there is a raw `map-keymap' fallback if it's gone
;;     or which-key isn't loaded.
;;   - Remapped commands, `:which-key' rename-only entries, and conditional
;;     bindings (`:when'/`:unless' inside `map!') resolve to whatever is
;;     bound in the *running* session at generation time -- correct for that
;;     session, not necessarily for a config after further edits.
;;
;;; Durability (plan §8 / §11 finding 2 -- load-bearing): every note written
;; by this file is fully, unconditionally overwritten on every run of the
;; function that owns it. No note is ever read-modify-written. Personal
;; annotation does not belong in these files -- write a separate note that
;; `#+transclude: [[id:...]]'s the generated heading in instead; this
;; generator never opens or edits a note it didn't itself just write from
;; scratch. IDs are deterministic (namespace + kind + slugified name, see
;; `my/system-notes--id'), never regenerated randomly, specifically so
;; backlinks and transclusions survive a regenerate.

(require 'cl-lib)
(require 'subr-x)
(require 'org-id)


;;; * Configuration

(defvar my/system-notes-directory
  (expand-file-name "roam/system/" org-directory)
  "Directory generated system-replication notes are written into.
Inside `org-roam-directory' (see config.org's org-roam-alongside-Vulpea
section) so org-roam-ui graphs these notes; still under `org-directory' so
Vulpea indexes them too.")

(defvar my/system-notes-repo-root
  (expand-file-name "~/.config/doom/")
  "Root of the Doom config repo this generator reads rationale/incidents from.
Defaults to the primary checkout, per this repo's own convention (worktrees
are for editing, not for pointing tools at) -- but every function that reads
from the repo takes REPO-ROOT as an optional argument, so this generator
itself is not hardcoded to this one repo if pointed elsewhere.")

(defvar my/system-notes-id-namespace "system-notes"
  "Fixed namespace prefix for every ID this generator writes.
IDs are deterministic (namespace + kind + slug), not random UUIDs, so the
same package/binding/incident gets the same ID on every run -- see
`my/system-notes--id'. This is the mechanism that keeps backlinks and
`org-transclusion' targets alive across regeneration.")

(defvar my/system-notes-pilot-package-count 18
  "Target package count for the pilot package-note run (plan §13: ~15-20).")

(defvar my/system-notes-pilot-keymap-prefix "n"
  "Default keymap-prefix string (under the leader) for the pilot run.
\"n\" (Notes) is chosen deliberately: it's the prefix this very workstream's
own binding lives under, so the pilot dogfoods its own output.")


;;; * ID and slug helpers

(defun my/system-notes--slug (s)
  "Turn S into a filename/ID-safe slug: lowercase, [a-z0-9] runs joined by -."
  (let ((down (downcase (format "%s" s))))
    (string-trim
     (replace-regexp-in-string
      "-\\{2,\\}" "-"
      (replace-regexp-in-string "[^a-z0-9]+" "-" down))
     "-" "-")))

(defun my/system-notes--id (kind name)
  "Deterministic ID for a generated note/heading of KIND identifying NAME.
Same (KIND . NAME) always yields the same string -- that's the whole point
\(see the Durability commentary at the top of this file). Not a UUID; org
property drawers accept any unique string, and a readable slug is easier to
recognize in a raw org buffer than a hash would be."
  (format "%s--%s--%s"
          my/system-notes-id-namespace
          (my/system-notes--slug kind)
          (my/system-notes--slug name)))


;;; * Low-level note writer (shared by all three sources)

(defun my/system-notes--write-note (filename id title tags body)
  "Write a file-level Vulpea/org-roam note, unconditionally overwriting.
FILENAME is relative to `my/system-notes-directory'. ID and TITLE become the
file's :ID: property and #+title:. TAGS is a list of tag strings for
#+filetags:. BODY is the pre-rendered org text that follows.

Deliberately does NOT use `vulpea-create': that function refuses to
overwrite an existing file (`vulpea.el', `vulpea--create-file' -- \"Safety
check: refuse to overwrite existing files\"), which is exactly wrong for a
generator whose notes must be freely regenerable. Writes the file directly
in the same property-drawer/#+title/#+filetags shape `vulpea--format-note-
content' produces, then calls the same low-level bookkeeping
\(`org-id-add-location', `vulpea-db-update-file') `vulpea-create' would have
called, so Vulpea's DB and org-id's location cache both learn about the note
immediately rather than waiting for the next autosync pass."
  (let* ((path (expand-file-name filename my/system-notes-directory))
         (dir (file-name-directory path))
         (drawer (list ":PROPERTIES:"
                        (format org-property-format ":ID:" id)
                        ":END:"
                        (format "#+title: %s" title)))
         (drawer (if tags
                     (append drawer
                             (list (concat "#+filetags: :"
                                           (string-join tags ":")
                                           ":")))
                   drawer))
         (content (concat (string-join drawer "\n") "\n\n" body)))
    (unless (file-directory-p dir)
      (make-directory dir t))
    (with-temp-buffer
      (insert content)
      (unless (eq (char-before) ?\n) (insert "\n"))
      (write-region (point-min) (point-max) path nil 'silent))
    (org-id-add-location id path)
    (if (fboundp 'vulpea-db-update-file)
        (vulpea-db-update-file path)
      (message "system-notes: vulpea-db-update-file unavailable; %s written but not indexed until next autosync" path))
    path))


;;; * Incidents source (docs/ai/troubleshooting.org)
;;
;; Parsed first and independently of the other two sources -- package and
;; keybinding rendering both call `my/system-notes--incidents-matching' to
;; fold in relevant lessons, but incident parsing never depends on having
;; generated the incidents note first (no ordering requirement between the
;; three generate-* orchestrators).

(defun my/system-notes--troubleshooting-file (&optional repo-root)
  "Path to docs/ai/troubleshooting.org under REPO-ROOT (default: primary checkout)."
  (expand-file-name "docs/ai/troubleshooting.org"
                     (or repo-root my/system-notes-repo-root)))

(defun my/system-notes--parse-incidents (&optional file)
  "Parse FILE (default: `my/system-notes--troubleshooting-file') into a list
of plists, one per top-level heading: (:id STR :status STR :title STR
:heading STR :gist STR :keywords (STR...)).

FILE is read-only here -- this function never edits it. Heading line is
expected as \"* STATUS: title\" (e.g. \"* RESOLVED: foo\", \"* Technique:
bar\", \"* OPEN (workaround known): baz\") followed by a :PROPERTIES: drawer
carrying :ID:, optionally a :LOGBOOK: drawer, then body text. :STATUS is
everything before the first top-level colon; :GIST is the first non-empty,
non-drawer body line/paragraph, truncated. :KEYWORDS are the =verbatim=
code-span terms in the heading line (this doc's own convention for quoting
symbol/package/command names), used later for substring cross-referencing
against package and command names -- a heuristic, not a guarantee every
relevant incident gets linked from every note it concerns."
  (let ((file (or file (my/system-notes--troubleshooting-file)))
        incidents)
    (unless (file-readable-p file)
      (user-error "system-notes: cannot read %s" file))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (while (re-search-forward "^\\* \\(.+\\)$" nil t)
        (let* ((heading (match-string-no-properties 1))
               (body-start (line-beginning-position 2))
               (next (save-excursion
                       (if (re-search-forward "^\\* " nil t)
                           (match-beginning 0)
                         (point-max))))
               (status (if (string-match "\\`\\([^:]+\\):\\s-*" heading)
                           (match-string 1 heading)
                         "?"))
               (title (if (string-match "\\`[^:]+:\\s-*\\(.*\\)\\'" heading)
                          (match-string 1 heading)
                        heading))
               (keywords (let (ks (start 0))
                           (while (string-match "=\\([^=\n]+\\)=" heading start)
                             (push (match-string 1 heading) ks)
                             (setq start (match-end 0)))
                           (nreverse ks)))
               (id (progn
                     (goto-char body-start)
                     (if (re-search-forward "^[ \t]*:ID:[ \t]+\\(\\S-+\\)" next t)
                         (match-string-no-properties 1)
                       (my/system-notes--slug heading))))
               (gist (progn
                       (goto-char body-start)
                       ;; Skip whole :PROPERTIES:...:END: / :LOGBOOK:...:END:
                       ;; drawer blocks (as blocks, not by guessing line
                       ;; prefixes inside them -- LOGBOOK content varies:
                       ;; "- Resolved ...", "- Found ...", state-change
                       ;; lines, CLOCK lines) to reach the first real
                       ;; paragraph line, then skip blank lines too.
                       (while (and (< (point) next)
                                   (or (looking-at-p "^[ \t]*:\\(PROPERTIES\\|LOGBOOK\\):[ \t]*$")
                                       (looking-at-p "^[ \t]*$")
                                       ;; A handful of entries (e.g.
                                       ;; tshoot-tangle-drops-file-local-vars)
                                       ;; open with a "** Symptom"-style
                                       ;; sub-heading instead of prose --
                                       ;; skip the marker line itself so the
                                       ;; gist is the sentence under it.
                                       (looking-at-p "^\\*+ [A-Za-z].*$")))
                         (if (looking-at-p "^[ \t]*:\\(PROPERTIES\\|LOGBOOK\\):[ \t]*$")
                             (if (re-search-forward "^[ \t]*:END:[ \t]*$" next t)
                                 (forward-line 1)
                               (goto-char next))
                           (forward-line 1)))
                       (if (< (point) next)
                           (let ((line (string-trim
                                        (buffer-substring-no-properties
                                         (point) (line-end-position)))))
                             (if (> (length line) 180)
                                 (concat (substring line 0 177) "...")
                               line))
                         ""))))
          (goto-char next)
          (push (list :id id :status status :title title :heading heading
                      :gist gist :keywords keywords)
                incidents))))
    (nreverse incidents)))

(defun my/system-notes--incidents-matching (incidents name)
  "Return the subset of INCIDENTS (as from `my/system-notes--parse-incidents')
whose :keywords contain NAME as a case-insensitive substring match, either
direction (a keyword inside NAME, or NAME inside a keyword) -- generous on
purpose, since incident headings quote things like \"=doom sync=\" or
\"=vterm=\" where an exact-token match would miss e.g. package `vterm' vs
heading text `(require 'vterm)'."
  (let ((needle (downcase (format "%s" name))))
    (seq-filter
     (lambda (inc)
       (seq-some
        (lambda (kw)
          (let ((kw (downcase kw)))
            (or (string-match-p (regexp-quote needle) kw)
                (string-match-p (regexp-quote kw) needle))))
        (plist-get inc :keywords)))
     incidents)))

(defun my/system-notes--render-known-issues (incidents name &optional repo-root)
  "Render a \"Known issues\" subsection for NAME from matching INCIDENTS, or nil."
  (let ((matches (my/system-notes--incidents-matching incidents name)))
    (when matches
      (concat "**** Known issues\n"
              (mapconcat
               (lambda (inc)
                 (format "- [[file:%s::*%s][%s: %s]] :: %s\n"
                         (my/system-notes--troubleshooting-file repo-root)
                         (plist-get inc :heading)
                         (plist-get inc :status)
                         (plist-get inc :title)
                         (plist-get inc :gist)))
               matches "")
              "\n"))))

(defun my/system-notes--render-incident-item (incident)
  "Render one INCIDENT plist as a level-3 org heading with its own stable ID.
Does not reuse the incident's real :ID: from troubleshooting.org verbatim as
this heading's own :ID: -- that file isn't under `org-directory' so it isn't
normally org-id/Vulpea-tracked, but reusing its ID string here would still
risk a collision if it ever became tracked. The real ID is kept as a plain
:SOURCE_ID: property and a file+search-headline link back to the source
\(robust regardless of whether that file's IDs are indexed anywhere)."
  (let ((id (my/system-notes--id "incident" (plist-get incident :id))))
    (format (concat "*** %s: %s\n"
                     ":PROPERTIES:\n"
                     ":ID:       %s\n"
                     ":SOURCE_ID: %s\n"
                     ":END:\n\n"
                     "%s\n\n"
                     "Source: [[file:%s::*%s][%s]]\n\n")
            (plist-get incident :status)
            (plist-get incident :title)
            id
            (plist-get incident :id)
            (if (string-empty-p (plist-get incident :gist))
                "(no gist extracted -- see source)"
              (plist-get incident :gist))
            (my/system-notes--troubleshooting-file)
            (plist-get incident :heading)
            (plist-get incident :heading))))

;;;###autoload
(defun my/system-notes-generate-incidents (&optional repo-root)
  "Generate the single \"incidents\" note: one heading per troubleshooting.org
entry (all of them -- 24 as of this writing, already a fully-scoped set per
plan §13, no pilot subsetting needed here)."
  (interactive)
  (let* ((repo-root (or repo-root my/system-notes-repo-root))
         (incidents (my/system-notes--parse-incidents
                     (my/system-notes--troubleshooting-file repo-root)))
         (id (my/system-notes--id "incidents" "all"))
         (body (concat
                "Generated from =docs/ai/troubleshooting.org= "
                (format "(%d entries). " (length incidents))
                "Regenerated wholesale on every run of "
                "=my/system-notes-generate-incidents= -- do not hand-edit; "
                "add personal commentary in a separate note that "
                "transcludes the heading you care about instead.\n\n"
                (mapconcat #'my/system-notes--render-incident-item
                           incidents ""))))
    (my/system-notes--write-note
     "incidents.org" id "System notes: incidents"
     '("system" "generated") body)
    (message "system-notes: wrote %d incidents" (length incidents))
    incidents))


;;; * Packages source

(defun my/system-notes--live-package-names ()
  "Return the sorted list of package names (strings) straight has actually
built and has live in this session -- see the Package-list source decision
commentary at the top of this file for why this, not `package-alist'."
  (unless (boundp 'straight--build-cache)
    (user-error "system-notes: straight--build-cache not bound -- is straight.el loaded?"))
  (sort (mapcar #'symbol-name
                (hash-table-keys
                 (if (hash-table-p straight--build-cache)
                     straight--build-cache
                   (make-hash-table))))
        #'string<))

(defun my/system-notes--module-title (module-key)
  "Human-readable title for MODULE-KEY, a (GROUP . NAME) cons from `doom-module-list'."
  (let ((group (doom-keyword-name (car module-key)))
        (name (cdr module-key))
        (flags (doom-module-get module-key :flags)))
    (concat ":" group (if name (format " %s" name) "")
            (when flags (format " %s" (mapconcat #'symbol-name flags " "))))))

(defun my/system-notes--module-slug (module-key)
  (my/system-notes--slug (my/system-notes--module-title module-key)))

(defun my/system-notes--module-package-names (module-key)
  "Declared package names (strings) for MODULE-KEY, cross-checked against
`my/system-notes--live-package-names' so a note is never written for
something declared but not actually built (e.g. a since-removed package!
form Doom hasn't re-synced yet)."
  (let ((live (my/system-notes--live-package-names))
        (declared (mapcar (lambda (spec) (symbol-name (car spec)))
                           (doom-package-list (list module-key)))))
    (seq-filter (lambda (name) (member name live)) declared)))

(defun my/system-notes--doom-modules ()
  "All enabled Doom module keys, in `doom-module-list' depth order."
  (doom-module-list))

(defun my/system-notes--modules-with-packages (module-keys)
  "Alist of (MODULE-KEY . (package-name-string...)) for MODULE-KEYS,
dropping any module that (after live cross-check) contributes zero packages."
  (delq nil
        (mapcar (lambda (key)
                  (let ((pkgs (my/system-notes--module-package-names key)))
                    (when pkgs (cons key pkgs))))
                module-keys)))

(defun my/system-notes--pilot-modules (&optional target-count)
  "Accumulate enabled modules (in their natural order) until their combined
live package count reaches TARGET-COUNT (default
`my/system-notes-pilot-package-count'). Returns an alist like
`my/system-notes--modules-with-packages'. Module-driven rather than a
hardcoded package list, so the pilot stays meaningful if this repo's module
set changes, and so this generator doesn't assume any specific module name
exists (it may be pointed at a different Doom config later)."
  (let ((target (or target-count my/system-notes-pilot-package-count))
        (total 0)
        acc)
    (catch 'done
      (dolist (key (my/system-notes--doom-modules))
        (let ((pkgs (my/system-notes--module-package-names key)))
          (when pkgs
            (push (cons key pkgs) acc)
            (setq total (+ total (length pkgs)))
            (when (>= total target) (throw 'done nil))))))
    (nreverse acc)))

(defun my/system-notes--package-summary (name)
  "Return package NAME's `lm-summary' header one-liner, or nil.
Read-only header scraping (`lm-summary' regex-scans the file's first line,
never `load's it) -- safe to call for every package during generation."
  (require 'lisp-mnt)
  (when-let* ((file (locate-library name)))
    (ignore-errors (lm-summary file))))

(defun my/system-notes--config-org-rationale (name &optional repo-root)
  "Best-effort rationale for package NAME from config.org under REPO-ROOT.
Returns a plist (:comment STRING-OR-NIL :adrs (STRING...) :found BOOL).
Looks for a `(package! NAME' or `(use-package! NAME' form; if found, takes
up to 6 immediately-preceding `;; ...' comment lines as :comment and scans a
±40-line window around the match for \"ADR-NNN\" tokens. This only catches
packages this repo's own config.org actually names -- by design, most
module-installed packages will come back with :found nil, which is itself
the exact signal workstream 6 exists to surface (plan §8/§11 finding 4)."
  (let* ((repo-root (or repo-root my/system-notes-repo-root))
         (file (expand-file-name "config.org" repo-root))
         result)
    (when (file-readable-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (when (re-search-forward
               (format "(\\(?:package\\|use-package\\)! +%s\\_>"
                       (regexp-quote name))
               nil t)
          (let* ((match-line (line-number-at-pos))
                 (comment-lines nil))
            (save-excursion
              (forward-line 0)
              (let ((n 0))
                (while (and (< n 6) (= (forward-line -1) 0)
                            (looking-at-p "^\\s-*;;"))
                  (push (string-trim (buffer-substring-no-properties
                                       (point) (line-end-position)))
                        comment-lines)
                  (setq n (1+ n)))))
            (let (adrs)
              (save-excursion
                (goto-char (point-min))
                (forward-line (max 0 (- match-line 40)))
                (let ((window-end (save-excursion (forward-line 80) (point))))
                  (while (re-search-forward "ADR-[0-9]+" window-end t)
                    (cl-pushnew (match-string 0) adrs :test #'equal))))
              (setq result (list :comment (when comment-lines
                                             (string-join comment-lines "\n"))
                                  :adrs (nreverse adrs)
                                  :found t)))))))
    (or result (list :comment nil :adrs nil :found nil))))

(defun my/system-notes--render-package-item (name incidents &optional repo-root)
  "Render package NAME as a level-3 heading satisfying the three acceptance
criteria as fixed subheadings (see file header commentary)."
  (let* ((id (my/system-notes--id "package" name))
         (summary (my/system-notes--package-summary name))
         (rationale (my/system-notes--config-org-rationale name repo-root))
         (found (plist-get rationale :found))
         (known-issues (my/system-notes--render-known-issues incidents name repo-root)))
    (concat
     (format "*** %s\n:PROPERTIES:\n:ID:       %s\n:END:\n\n" name id)
     "**** What it does\n"
     (if summary
         (format "%s\n\n(package-authored summary -- rephrase into \"what it does for you\" per acceptance criterion 1 during review)\n\n" summary)
       "No `lm-summary' header found for this package (not on `load-path' under this name, or missing an `;;; foo.el --- SUMMARY' header line).\n\n")
     "**** When you'd reach for it\n"
     "/Needs a concrete usage scenario -- fill in during review (acceptance criterion 2)./\n\n"
     "**** Usage status\n"
     (if found
         "Explicitly configured in config.org (see Rationale below) -- likely in active, conscious use.\n\n"
       "No explicit mention found in config.org -- installed only via a Doom module's own packages.el. Likely unused or underused in this workflow; confirm during review (acceptance criterion 3).\n\n")
     (when found
       (concat "**** Rationale\n"
               (if (plist-get rationale :comment)
                   (format "%s\n\n" (plist-get rationale :comment))
                 "(matched a package!/use-package! form but no preceding `;; ' comment block)\n\n")
               (when (plist-get rationale :adrs)
                 (format "See: %s\n\n"
                         (mapconcat #'identity (plist-get rationale :adrs) ", ")))))
     known-issues)))

(defun my/system-notes--render-module-note (module-key package-names incidents &optional repo-root)
  "Render the full body (module description + one heading per package) for MODULE-KEY."
  (concat
   (format "Doom module =%s=, %d live package(s). Generated -- do not
hand-edit; annotate via a separate note that transcludes a specific package
heading instead.\n\n"
           (my/system-notes--module-title module-key) (length package-names))
   (mapconcat (lambda (name)
                (my/system-notes--render-package-item name incidents repo-root))
              (sort (copy-sequence package-names) #'string<)
              "")))

;;;###autoload
(defun my/system-notes-generate-packages (&optional module-keys repo-root)
  "Generate one note per Doom module in MODULE-KEYS (default: the pilot set
from `my/system-notes--pilot-modules'), each with one heading per live
package that module declares. Call with `(my/system-notes--doom-modules)'
for full coverage instead of the pilot."
  (interactive)
  (let* ((repo-root (or repo-root my/system-notes-repo-root))
         (modules (my/system-notes--modules-with-packages
                   (or module-keys (mapcar #'car (my/system-notes--pilot-modules)))))
         (incidents (my/system-notes--parse-incidents
                     (my/system-notes--troubleshooting-file repo-root)))
         (written 0))
    (dolist (entry modules)
      (let* ((key (car entry))
             (pkgs (cdr entry))
             (slug (my/system-notes--module-slug key))
             (id (my/system-notes--id "module" slug))
             (title (format "System notes: %s" (my/system-notes--module-title key)))
             (body (my/system-notes--render-module-note key pkgs incidents repo-root)))
        (my/system-notes--write-note
         (format "pkg-%s.org" slug) id title '("system" "generated") body)
        (setq written (+ written (length pkgs)))))
    (message "system-notes: wrote %d module note(s), %d package(s) total"
             (length modules) written)
    modules))


;;; * Keybindings source

(defun my/system-notes--keymap-bindings (keymap prefix-kbd)
  "Return an alist of (KEY-DESCRIPTION . BINDING) for every leaf reachable
under PREFIX-KBD (a `kbd'-return-value key vector/string) inside KEYMAP.
BINDING is a command symbol, or a string (\"prefix\"/\"lambda\"/\"closure\"/
\"function\") when which-key's own classification is used.

Prefers which-key's private `which-key--get-keymap-bindings' (raw, pre-
formatting variant -- NOT `which-key--get-current-bindings', which
propertizes and truncates for popup display) because it resolves prefix
labels and remaps the way `SPC h b b' would show them. Falls back to a
plain recursive `map-keymap' walk if which-key isn't loaded. See the
Keybinding-introspection coverage commentary at the top of this file for
what neither path covers."
  (let ((sub (lookup-key keymap prefix-kbd)))
    (unless (keymapp sub)
      (user-error "system-notes: %s is not bound to a keymap under this prefix"
                  (key-description prefix-kbd)))
    (if (fboundp 'which-key--get-keymap-bindings)
        (mapcar (lambda (kv) (cons (car kv) (cdr kv)))
                (which-key--get-keymap-bindings
                 keymap nil prefix-kbd nil 'all))
      (let (acc)
        (letrec ((walk (lambda (km keys)
                          (map-keymap
                           (lambda (event binding)
                             (let ((keys2 (vconcat keys (vector event))))
                               (cond
                                ((keymapp binding) (funcall walk binding keys2))
                                ((and binding (symbolp binding) (commandp binding))
                                 (push (cons (key-description keys2) binding) acc)))))
                           km))))
          (funcall walk sub prefix-kbd))
        (nreverse acc)))))

(defun my/system-notes--config-org-mentions-key-p (key-desc command repo-root)
  "Heuristic: does config.org's own text mention COMMAND or KEY-DESC?
Used as the \"explicitly configured by this repo\" signal for the usage-
status heuristic -- true only means \"textually present\", not \"correctly
bound\" or \"actually used\"."
  (let ((file (expand-file-name "config.org" (or repo-root my/system-notes-repo-root))))
    (and (file-readable-p file)
         (with-temp-buffer
           (insert-file-contents file)
           (goto-char (point-min))
           (or (search-forward (format "%s" command) nil t)
               (progn (goto-char (point-min))
                      (search-forward (format "\"%s\"" (car (last (split-string key-desc " ")))) nil t)))))))

(defun my/system-notes--render-binding-item (key-desc binding incidents repo-root)
  "Render one (KEY-DESC . BINDING) pair as a level-3 heading."
  (let* ((id (my/system-notes--id "binding" key-desc))
         (command (and (symbolp binding) binding))
         (label (if command (symbol-name command) (format "%s" binding)))
         (doc (and command (fboundp command) (documentation command)))
         (doc-line (when doc (car (split-string doc "\n"))))
         (explicit (and command
                        (my/system-notes--config-org-mentions-key-p key-desc command repo-root)))
         (known-issues (my/system-notes--render-known-issues incidents label repo-root)))
    (concat
     (format "*** SPC %s -- %s\n:PROPERTIES:\n:ID:       %s\n:END:\n\n"
             key-desc label id)
     "**** What it does\n"
     (if doc-line
         (format "%s\n\n" doc-line)
       (format "(%s -- no interactive command docstring available to quote)\n\n" label))
     "**** When you'd reach for it\n"
     "/Needs a concrete usage scenario -- fill in during review (acceptance criterion 2)./\n\n"
     "**** Usage status\n"
     (if explicit
         "This repo's own config.org explicitly names this command/key -- likely in active, conscious use.\n\n"
       "No direct textual match in config.org -- this is either a Doom/module stock default never customized here, or a remap this heuristic missed. Confirm during review (acceptance criterion 3).\n\n")
     known-issues)))

;;;###autoload
(defun my/system-notes-generate-keybindings (&optional prefix repo-root)
  "Generate one note for the keymap prefix PREFIX (a string like \"n\",
default `my/system-notes-pilot-keymap-prefix'), under `doom-leader-map',
with one heading per bound command reachable under it (recursively -- see
Granularity in the plan: nothing non-obvious gets collapsed away)."
  (interactive
   (list (read-string (format "Leader prefix (default %S): "
                               my/system-notes-pilot-keymap-prefix)
                       nil nil my/system-notes-pilot-keymap-prefix)))
  (unless (boundp 'doom-leader-map)
    (user-error "system-notes: doom-leader-map not bound -- is Doom's keybind core loaded?"))
  (let* ((repo-root (or repo-root my/system-notes-repo-root))
         (prefix (or prefix my/system-notes-pilot-keymap-prefix))
         (prefix-kbd (kbd prefix))
         (bindings (my/system-notes--keymap-bindings doom-leader-map prefix-kbd))
         (incidents (my/system-notes--parse-incidents
                     (my/system-notes--troubleshooting-file repo-root)))
         (slug (my/system-notes--slug prefix))
         (id (my/system-notes--id "keymap" slug))
         (title (format "System notes: keybindings under SPC %s" prefix))
         (body (concat
                (format "Leaf bindings reachable under =SPC %s= in
`doom-leader-map', walked live at generation time (%d found). Generated --
do not hand-edit.\n\n" prefix (length bindings))
                (mapconcat
                 (lambda (kv)
                   (my/system-notes--render-binding-item (car kv) (cdr kv) incidents repo-root))
                 bindings ""))))
    (my/system-notes--write-note
     (format "keys-%s.org" slug) id title '("system" "generated") body)
    (message "system-notes: wrote %d binding(s) under SPC %s" (length bindings) prefix)
    bindings))


;;; * Orchestrators

;;;###autoload
(defun my/system-notes-generate-pilot ()
  "Pilot-scoped run of all three sources (plan §13): ~15-20 packages across
however many modules it takes to reach that count, one keymap prefix's
bindings, and all 24 troubleshooting incidents. Judge the output against
the three acceptance criteria (file header) before ever calling
`my/system-notes-generate-all'."
  (interactive)
  (my/system-notes-generate-packages)
  (my/system-notes-generate-keybindings my/system-notes-pilot-keymap-prefix)
  (my/system-notes-generate-incidents)
  (message "system-notes: pilot generation complete -- review notes under %s before widening scope"
           my/system-notes-directory))

;;;###autoload
(defun my/system-notes-generate-all (&optional keymap-prefixes)
  "Full-coverage run: every enabled Doom module's packages, all 24
incidents, and KEYMAP-PREFIXES (default: just the pilot prefix -- widening
keybinding coverage means naming more prefixes here one at a time; see the
Keybinding-introspection coverage commentary at the top of this file for
why this stays opt-in rather than attempting to walk the entire leader map
unattended)."
  (interactive)
  (my/system-notes-generate-packages (my/system-notes--doom-modules))
  (dolist (prefix (or keymap-prefixes (list my/system-notes-pilot-keymap-prefix)))
    (my/system-notes-generate-keybindings prefix))
  (my/system-notes-generate-incidents)
  (message "system-notes: full generation complete"))

;;;###autoload
(defun my/system-notes-generate (scope)
  "Interactive entry point. SCOPE is one of \"pilot\", \"packages\",
\"keybindings\", \"incidents\", \"all\" -- prompted for when called
interactively. Bound under =SPC n v g= (see config.org's system-notes-
generator-anchor)."
  (interactive
   (list (completing-read "Generate system notes (scope): "
                           '("pilot" "packages" "keybindings" "incidents" "all")
                           nil t nil nil "pilot")))
  (pcase scope
    ("pilot" (my/system-notes-generate-pilot))
    ("packages" (my/system-notes-generate-packages))
    ("keybindings" (call-interactively #'my/system-notes-generate-keybindings))
    ("incidents" (my/system-notes-generate-incidents))
    ("all" (my/system-notes-generate-all))
    (_ (user-error "system-notes: unknown scope %S" scope))))

;; No `;;;###autoload' cookies are load-bearing here despite being present
;; above (kept for documentation/consistency with Doom's own convention seen
;; in doom-packages.el/doom-modules.el): this file is loaded unconditionally
;; and eagerly via `(load! "system-notes")' in config.org, not scanned into
;; Doom's generated autoloads file the way a module's autoload/*.el is. grep
;; confirms config.org itself uses no `;;;###autoload' cookies anywhere.

(provide 'system-notes)
;;; system-notes.el ends here
