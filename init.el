;; Kickstart.emacs is *not* a distribution.
;; It's a template for your own configuration.

;; It is recommeded to configure it from the config.org file.
;; The goal is that you read every line, top-to-bottom, understand
;; what your configuration is doing, and modify it to suit your needs.

;; You can delete this when you're done. It's your config now. :)

;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun start/org-babel-tangle-config ()
  "Automatically tangle our Emacs.org config file when we save it. Credit to Emacs From Scratch for this one!"
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'start/org-babel-tangle-config)))

(setq user-full-name "Mark Kornblum"
      user-mail-address "mkornblum@aurorasolar.com")

(require 'use-package-ensure) ;; Load use-package-always-ensure
(setq use-package-always-ensure t) ;; Always ensures that a package is installed
(setq package-archives '(("melpa" . "https://melpa.org/packages/") ;; Sets default package repositories
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))) ;; For Eat Terminal

(menu-bar-mode -1)           ;; Disable the menu bar
(scroll-bar-mode -1)         ;; Disable the scroll bar
(tool-bar-mode -1)           ;; Disable the tool bar
;; (setq inhibit-startup-screen t) ;; Disable welcome screen

(delete-selection-mode 1)    ;; You can select text and delete it by typing.
(electric-indent-mode -1)    ;; Turn off the weird indenting that Emacs does by default.
(electric-pair-mode 1)       ;; Turns on automatic parens pairing

(global-auto-revert-mode t)          ;; Automatically reload file and show changes if the file has changed
(global-display-line-numbers-mode 1) ;; Display line numbers
(global-visual-line-mode t)          ;; Enable truncated lines

(setq mouse-wheel-progressive-speed nil) ;; Disable progressive speed when scrolling
(setq scroll-conservatively 10)          ;; Smooth scrolling when going down with scroll margin
(setq scroll-margin 8)

(setq make-backup-files nil) ;; Stop creating ~ backup files
(setq create-lockfiles nil)
(setq auto-save-default nil) ;; Stop creating # auto save files
;; (setq dired-kill-when-opening-new-dired-buffer t) ;; Dired don't create new buffer

(setq org-edit-src-content-indentation 4) ;; Set src block automatic indent to 4 instead of 2.
(setq-default tab-width 4)

;; Move customization variables to a separate file and load it, avoid filling up init.el with unnecessary variables
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(global-set-key [escape] 'keyboard-escape-quit) ;; Makes Escape quit prompts (Minibuffer Escape)
(blink-cursor-mode 0) ;; Don't blink cursor
(add-hook 'prog-mode-hook (lambda () (hs-minor-mode t))) ;; Enable folding hide/show globally

(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox-light-medium t)) ;; We need to add t to trust this package

(add-to-list 'default-frame-alist '(alpha-background . 90)) ;; For all new frames henceforth

(set-face-attribute 'default nil
                    :font "Monaco" ;; Set your favorite type of font or download JetBrains Mono
                    :height 130
                    :weight 'medium)
;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.

;;(add-to-list 'default-frame-alist '(font . "JetBrains Mono")) ;; Set your favorite font
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)     ;; Sets modeline height
  (doom-modeline-bar-width 5)   ;; Sets right bar width
  (doom-modeline-persp-name t)  ;; Adds perspective name to modeline
  (doom-modeline-persp-icon t) ;; Adds folder icon next to persp name
  (doom-modeline-buffer-file-name-style 'truncate-upto-project))

(use-package projectile
  :init
  (projectile-mode)
  :custom
  (projectile-run-use-comint-mode t) ;; Interactive run dialog when running projects inside emacs (like giving input)
  (projectile-switch-project-action #'projectile-dired)
  (projectile-project-search-path '(("~/code" . 1)))) ;; . 1 means only search the first subdirectory level for projects
;; Use Bookmarks for smaller, not standard projects

(use-package eglot
  :ensure nil ;; Don't install eglot because it's now built-in
  :hook (('python-mode . 'eglot-ensure)) ;; Autostart lsp servers for a given mode
  :config
  ;; Good default
  (setq eglot-events-buffer-size 0 ;; No event buffers (Lsp server logs)
        eglot-autoshutdown t) ;; Shutdown unused servers.
  ;; Manual lsp servers
  ;; (add-to-list 'eglot-server-programs
  ;;              `((python-mode python-ts-mode) . ("ruff-lsp"))) 
  )

(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package yasnippet-snippets
  :custom (yas-snippet-dirs '("~/.config/emacs/snippets"))
  :hook (prog-mode . yas-minor-mode))

(use-package tree-sitter)
(use-package tree-sitter-langs)
(use-package treesit-auto
  :config
  (global-treesit-auto-mode))
(global-tree-sitter-mode)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)

(use-package format-all
  :hook (prog-mode . format-all-mode))

(use-package python-pytest)

;; this fixes a problem where v0.20.4 of this grammar blows up with emacs
(defvar genehack/tsx-treesit-auto-recipe
  (make-treesit-auto-recipe
   :lang 'tsx
   :ts-mode 'tsx-ts-mode
   :remap '(typescript-tsx-mode)
   :requires 'typescript
   :url "https://github.com/tree-sitter/tree-sitter-typescript"
   :revision "v0.20.3"
   :source-dir "tsx/src"
   :ext "\\.tsx\\'")
  "Recipe for libtree-sitter-tsx.dylib")
(add-to-list 'treesit-auto-recipe-list genehack/tsx-treesit-auto-recipe)

(defvar genehack/typescript-treesit-auto-recipe
  (make-treesit-auto-recipe
   :lang 'typescript
   :ts-mode 'typescript-ts-mode
   :remap 'typescript-mode
   :requires 'tsx
   :url "https://github.com/tree-sitter/tree-sitter-typescript"
   :revision "v0.20.3"
   :source-dir "typescript/src"
   :ext "\\.ts\\'")
  "Recipe for libtree-sitter-typescript.dylib")
(add-to-list 'treesit-auto-recipe-list genehack/typescript-treesit-auto-recipe)
(add-to-list 'auto-mode-alist '("\\.\\(jsx\\|tsx\\)\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.\\(js\\|ts\\)\\'" . typescript-ts-mode))

(use-package nvm
  :hook ((tsx-ts-mode . nvm-use-for)
         (typescript-ts-mode . nvm-use-for)))

(use-package dockerfile-mode)

(add-hook 'org-mode-hook 'org-indent-mode) ;; Indent text

(use-package toc-org
  :commands toc-org-enable
  :hook ('org-mode-hook . 'toc-org-enable))

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))

(with-eval-after-load 'org
  (require 'org-tempo))

(use-package eat
  :hook ('eshell-load-hook #'eat-eshell-mode))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; (require 'start-multiFileExample)
(require 'asdf)
(require 'mk-functions)
(require 'meow-qwerty)

;; (start/hello)
(asdf-enable)

(use-package meow)
(meow-setup)
(meow-global-mode 1)

(use-package ace-window
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-background nil)
  :init
  (global-set-key (kbd "M-o") 'ace-window)
)

(use-package rg)

(use-package nerd-icons
  :if (display-graphic-p))

(use-package nerd-icons-dired
  :hook (dired-mode . (lambda () (nerd-icons-dired-mode t))))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package magit
  :commands magit-status)

(use-package diff-hl
  :hook ((magit-pre-refresh-hook . diff-hl-magit-pre-refresh)
         (magit-post-refresh-hook . diff-hl-magit-post-refresh))
  :init (global-diff-hl-mode))

(use-package git-timemachine)
(use-package browse-at-remote)

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-auto-prefix 2)          ;; Minimum length of prefix for auto completion.
  (corfu-popupinfo-mode t)       ;; Enable popup information
  (corfu-popupinfo-delay 0.5)    ;; Lower popupinfo delay to 0.5 seconds from 2 seconds
  (corfu-separator ?\s)          ;; Orderless field separator, Use M-SPC to enter separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
  (completion-ignore-case t)
  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)
  (corfu-preview-current nil) ;; Don't insert completion without confirmation
  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :after corfu
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  ;; The functions that are added later will be the first in the list

  (add-to-list 'completion-at-point-functions #'cape-dabbrev) ;; Complete word from current buffers
  (add-to-list 'completion-at-point-functions #'cape-dict) ;; Dictionary completion
  (add-to-list 'completion-at-point-functions #'cape-file) ;; Path completion
  (add-to-list 'completion-at-point-functions #'cape-elisp-block) ;; Complete elisp in Org or Markdown mode
  (add-to-list 'completion-at-point-functions #'cape-keyword) ;; Keyword/Snipet completion

  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev) ;; Complete abbreviation
  ;;(add-to-list 'completion-at-point-functions #'cape-history) ;; Complete from Eshell, Comint or minibuffer history
  ;;(add-to-list 'completion-at-point-functions #'cape-line) ;; Complete entire line from current buffer
  ;;(add-to-list 'completion-at-point-functions #'cape-elisp-symbol) ;; Complete Elisp symbol
  ;;(add-to-list 'completion-at-point-functions #'cape-tex) ;; Complete Unicode char from TeX command, e.g. \hbar
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml) ;; Complete Unicode char from SGML entity, e.g., &alpha
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345) ;; Complete Unicode char using RFC 1345 mnemonics
  )

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package vertico
  :init
  (vertico-mode))

(savehist-mode) ;; Enables save history mode

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  :hook
  ('marginalia-mode-hook . 'nerd-icons-completion-marginalia-setup))

(use-package consult
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))

  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  ;; (consult-customize
  ;; consult-theme :preview-key '(:debounce 0.2 any)
  ;; consult-ripgrep consult-git-grep consult-grep
  ;; consult-bookmark consult-recent-file consult-xref
  ;; consult--source-bookmark consult--source-file-register
  ;; consult--source-recent-file consult--source-project-recent-file
  ;; :preview-key "M-."
  ;; :preview-key '(:debounce 0.4 any))

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
   ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
   ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
   ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
   ;;;; 4. projectile.el (projectile-project-root)
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function (lambda (_) (projectile-project-root)))
   ;;;; 5. No project support
  ;; (setq consult-project-function nil)
  )

(use-package diminish)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init
  (which-key-mode 1)
  :diminish
  :custom
  (which-key-side-window-location 'bottom)
  (which-key-sort-order #'which-key-key-order-alpha) ;; Same as default, except single characters are sorted alphabetically
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1) ;; Number of spaces to add to the left of each column
  (which-key-min-display-lines 6)  ;; Increase the minimum lines to display, because the default is only 1
  (which-key-idle-delay 0.8)       ;; Set the time delay (in seconds) for the which-key popup to appear
  (which-key-max-description-length 25))

(use-package envrc
  :init
  (envrc-global-mode))

(use-package exec-path-from-shell
  :init 
  (exec-path-from-shell-initialize))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
;; Increase the amount of data which Emacs reads from the process
(setq read-process-output-max (* 1024 1024)) ;; 1mb
