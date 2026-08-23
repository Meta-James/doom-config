;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find a link to Doom's Module Index where all
;;      of our modules are listed, including what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c c k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;      directory (for easy access to its source code).

;; NOTE Every flag a module accepts is listed in [brackets] at the end of its
;;      comment, enabled or not -- so the line shows both what's on and what
;;      else is available. A module with no bracket takes no flags at all.
;;      Flag lists were read out of
;;      ~/.config/emacs/sources/doom+/modules (each module's README.org
;;      "Module flags" section plus its own 'modulep!' calls) on 2026-08-23,
;;      against doom core ad55ed0; re-derive them rather than trusting this
;;      comment after a 'doom upgrade'.

(doom! :input
       ;;bidi              ; (tfel ot) thgir etirw uoy gnipleh
       ;;chinese           ; spend your 3 hours a week in Emacs [+childframe +rime]
       ;;japanese          ; ah, a man of culture
       ;;layout            ; auie,ctsrnm is the superior home row [+azerty +bepo]

       :completion
       ;;(company +childframe) ; the ultimate code completion backend [+childframe +tng]
       (corfu +orderless +icons +dabbrev) ; complete with cap(f), cape and a flying feather! [+dabbrev +icons +orderless]
       ;;helm              ; the *other* search engine for love and life [+childframe +fuzzy +icons]
       ;;ido               ; the other *other* search engine...
       ;;ivy               ; a search engine for love and life [+childframe +fuzzy +icons +prescient]
       (vertico +icons)    ; the search engine of the future [+childframe +icons]

       :ui
       ;;deft              ; notational velocity for Emacs
       doom                ; what makes DOOM look the way it does
       dashboard           ; a nifty splash screen for Emacs
       ;;doom-quit         ; DOOM quit-message prompts when you quit Emacs
       ;;(emoji +unicode)  ; 🙂 [+ascii +github +unicode]
       hl-todo             ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       indent-guides       ; highlighted indent columns
       (ligatures +extra)  ; ligatures and symbols to make your code pretty again [+extra]
       minimap             ; show a map of the code on the side
       modeline            ; snazzy, Atom-inspired modeline, plus API [+light]
       ;;nav-flash         ; blink cursor line after big motions -- superseded by pulsar, see config.el
       ;;neotree           ; a project drawer, like NERDTree for vim
       ophints             ; highlight the region an operation acts on
       (popup +defaults +all) ; tame sudden yet inevitable temporary windows [+all +defaults]
       (smooth-scroll +interpolate) ; So smooth you won't believe it's not butter [+interpolate]
       tabs                ; a tab bar for Emacs
       ;;treemacs          ; a project drawer, like neotree but cooler [+lsp]
       ;;unicode           ; extended unicode support for various languages
       (vc-gutter +pretty) ; vcs diff in the fringe [+pretty]
       vi-tilde-fringe     ; fringe tildes to mark beyond EOB
       ;;window-select     ; visually switch windows [+numbers +switch-window]
       workspaces          ; tab emulation, persistence & separate workspaces
       (zen +focus)        ; distraction-free coding or writing [+focus]

       :editor
       (evil +everywhere)  ; come to the dark side, we have cookies [+everywhere]
       file-templates      ; auto-snippets for empty files
       fold                ; (nigh) universal code folding
       (format +onsave)    ; automated prettiness [+lsp +onsave]
       ;;god               ; run Emacs commands without modifier keys
       ;;lispy             ; vim for lisp, for people who don't like vim
       ;;multiple-cursors  ; editing in many places at once
       ;;objed             ; text object editing for the innocent [+manual]
       ;;parinfer          ; turn lisp into python, sort of
       ;;rotate-text       ; cycle region at point between text candidates
       snippets            ; my elves. They type so I don't have to
       (whitespace +guess +trim) ; a butler for your whitespace [+guess +trim]
       ;;word-wrap         ; soft wrapping with language-aware indent

       :emacs
       (dired +icons +dirvish) ; making dired pretty [functional] [+dirvish +icons]
       electric            ; smarter, keyword-based electric-indent
       eww                 ; the internet is gross
       ;;ibuffer           ; interactive buffer management [+icons]
       tramp               ; remote files at your arthritic fingertips
       undo                ; persistent, smarter undo for your inevitable mistakes [+tree]
       vc                  ; version-control and Emacs, sitting in a tree

       :term
       ;;eshell            ; the elisp shell that works everywhere
       (ghostel +everywhere) ; libghostty-vt powered terminal emulation [+everywhere]
       ;;shell             ; simple shell REPL for Emacs
       ;;term              ; basic terminal emulator for Emacs
       ;;vterm             ; the best terminal emulation in Emacs -- migrated to ghostel, see ADR-014

       :checkers
       syntax              ; tasing you for every semicolon you forget [+childframe +flymake +icons]
       (spell +flyspell +aspell +everywhere) ; tasing you for misspelling mispelling [+aspell +enchant +everywhere +flyspell +hunspell]
       grammar             ; tasing grammar mistake every you make

       :tools
       ;;ansible           ; allow silly people to focus on silly things
       ;;biblio            ; Writes a PhD for you (citation needed)
       ;;collab            ; buffers with friends [+tunnel]
       ;;debugger          ; FIXME stepping through code, to help you add bugs [+lsp]
       direnv              ; save (or destroy) the environment at your leisure
       ;;docker            ; contain your enthusiasm [+lsp +tree-sitter]
       ;;editorconfig      ; let someone else argue about tabs vs spaces
       ;;ein               ; tame Jupyter notebooks with emacs
       (eval +overlay)     ; run code, run (also, repls) [+overlay]
       llm                 ; when I said you needed friends, I didn't mean...
       (lookup +dictionary +docsets +offline) ; navigate your code and its documentation [+dictionary +docsets +offline +yandex]
       (lsp +peek)         ; M-x vscode [+booster +eglot +peek]
       (magit +forge)      ; a git porcelain for Emacs [+forge]
       ;;make              ; run make tasks from Emacs
       (pass +auth)        ; password manager for nerds [+auth]
       pdf                 ; pdf enhancements
       ;;terraform         ; infrastructure as code [+lsp]
       ;;tmux              ; an API for interacting with tmux
       tree-sitter         ; syntax and parsing, sitting in a tree...
       ;;upload            ; map local to remote projects via ssh/ftp

       :os
       (:if (featurep :system 'macos) macos) ; improve compatibility with macOS
       ;;tty               ; improve the terminal Emacs experience [+osc]

       :lang
       ;;ada               ; in strong typing we (blindly) trust [+lsp +tree-sitter]
       ;;agda              ; types of types of types of types... [+local +tree-sitter]
       ;;beancount         ; mind the GAAP [+lsp]
       ;;(cc +lsp)         ; C > C++ == 1 [+lsp +tree-sitter]
       ;;clojure           ; java with a lisp [+lsp +tree-sitter]
       ;;common-lisp       ; if you've seen one lisp, you've seen them all
       ;;coq               ; proofs-as-programs
       ;;crystal           ; ruby at the speed of c [+lsp]
       ;;csharp            ; unity, .NET, and mono shenanigans [+dotnet +lsp +tree-sitter +unity]
       ;;data              ; config/data formats
       ;;(dart +flutter)   ; paint ui and not much else [+flutter +lsp +tree-sitter]
       ;;dhall             ; config as code
       ;;elixir            ; erlang done right [+lsp +tree-sitter]
       ;;elm               ; care for a cup of TEA? [+lsp]
       emacs-lisp          ; drown in parentheses
       ;;erlang            ; an elegant language for a more civilized age [+lsp +tree-sitter]
       ;;ess               ; emacs speaks statistics [+lsp +stan]
       ;;factor            ; a concatenative language with a stack of parens
       ;;faust             ; dsp, but you get to keep your soul
       ;;fortran           ; in FORTRAN, GOD is REAL (unless declared INTEGER) [+intel +lsp]
       ;;fsharp            ; ML stands for Microsoft's Language [+lsp +tree-sitter]
       ;;fstar             ; (dependent) types and (monadic) effects and Z3
       ;;gdscript          ; the language you waited for [+lsp +tree-sitter]
       ;;(go +lsp)         ; the hipster dialect [+lsp +tree-sitter]
       ;;(graphql +lsp)    ; Give queries a REST [+lsp +tree-sitter]
       ;;graphviz          ; diagrams to confuse yourself even more
       ;;(haskell +lsp)    ; a language that's lazier than I am [+lsp +tree-sitter]
       ;;hy                ; readability of scheme w/ speed of python
       ;;idris             ; a language you can depend on [+lsp]
       (json +lsp +tree-sitter) ; At least it ain't XML [+lsp +tree-sitter]
       ;;janet             ; fun fact: Janet is me! [+tree-sitter]
       ;;(java +lsp)       ; the poster child for carpal tunnel syndrome [+lsp +tree-sitter]
       ;;javascript        ; all(hope(abandon(ye(who(enter(here)))))) [+lsp +tree-sitter]
       ;;julia             ; a better, faster MATLAB [+lsp +snail +tree-sitter]
       ;;kotlin            ; a better, slicker Java(Script) [+lsp +tree-sitter]
       (latex +lsp)        ; writing papers in Emacs has never been so fun [+cdlatex +fold +lsp]
       ;;lean              ; for folks with too much to prove [+lsp +v3]
       ;;ledger            ; be audit you can be
       ;;lua               ; one-based indices? one-based indices [+fennel +lsp +moonscript +tree-sitter]
       (markdown +lsp +grip +tree-sitter) ; writing docs for people to ignore [+grip +lsp +tree-sitter]
       ;;nim               ; python + lisp at the speed of c
       ;;nix               ; I hereby declare "nix geht mehr!" [+lsp +tree-sitter]
       ;;ocaml             ; an objective camel [+lsp]
       ;;odin              ; C, minus its footguns [+lsp +tree-sitter]
       (org +pandoc +roam +gnuplot +jupyter +pretty +noter +dragndrop) ; organize your plain life in plain text [+crypt +dragndrop +gnuplot +journal +jupyter +noter +pandoc +present +pretty +roam]
       ;;php               ; perl's insecure younger brother [+hack +lsp +tree-sitter]
       ;;plantuml          ; diagrams for confusing people more
       ;;purescript        ; javascript, but functional [+lsp]
       (python +lsp +pyenv +poetry +pyright +tree-sitter) ; beautiful is better than ugly [+conda +cython +lsp +poetry +pyenv +pyright +tree-sitter +uv]
       ;;qt                ; the 'cutest' gui framework ever [+lsp +tree-sitter]
       ;;racket            ; a DSL for DSLs [+hash-lang +lsp +xp]
       ;;raku              ; the artist formerly known as perl6
       ;;rest              ; Emacs as a REST client [+jq]
       ;;rst               ; ReST in peace
       ;;(ruby +rails)     ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"} [+chruby +lsp +rails +rbenv +rvm +tree-sitter]
       ;;(rust +lsp)       ; Fe2O3.unwrap().unwrap().unwrap().unwrap() [+lsp +tree-sitter]
       ;;scad              ; trust the preview, regret the render [+lsp +tree-sitter]
       ;;scala             ; java, but good [+lsp +tree-sitter]
       ;;(scheme +guile)   ; a fully conniving family of lisps [+chez +chibi +chicken +gambit +gauche +guile +kawa +mit +racket]
       (sh +lsp)           ; she sells {ba,z,fi}sh shells on the C xor [+fish +lsp +powershell]
       ;;sml               ; [+lsp +tree-sitter]
       ;;solidity          ; do you need a blockchain? No.
       ;;swift             ; who asked for emoji variables? [+lsp +tree-sitter]
       ;;terra             ; Earth and Moon in alignment for performance.
       ;;web               ; the tubes [+lsp +tree-sitter]
       ;;yaml              ; JSON, but readable [+lsp +tree-sitter]
       ;;zig               ; C, but simpler [+lsp +tree-sitter]

       :email
       (mu4e +org +gmail +mbsync) ; [+gmail +mbsync +offlineimap +org]
       ;;notmuch           ; [+afew +org]
       ;;(wanderlust +gmail) ; [+gmail +xface]

       :app
       ;;calendar          ; watch your missed deadlines in real time
       ;;emms              ; a media player for music no one's heard of
       ;;everywhere        ; *leave* Emacs!? You must be joking
       ;;irc               ; how neckbeards socialize
       (rss +org +youtube) ; emacs as an RSS reader [+org +youtube]

       :config
       ;;literate          ; disguise your config as poor documentation
       (default +bindings +smartparens +gnupg)) ; [+bindings +gnupg +smartparens]
