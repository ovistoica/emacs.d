;;; package --- My Emacs config

;;; Commentary:

; The config is mostly focused on Clojure(Script) and React development.
; ClojureScript support in other IDEs is not ideal so this is my attempt
; to create the best environment for web development in ClojureScript


;;; Code:
(setq inhibit-startup-message t)

(scroll-bar-mode -1)       ; Disable visible scrollbar
(tool-bar-mode -1)         ; Disable the toolbar
(tooltip-mode -1)          ; Disable tooltips
(set-fringe-mode 10)       ; Give some breathing room

(menu-bar-mode -1)         ; Disable the menu bar

; Set up the visible bell
(setq visible-bell t)

;;; Navigation keys similar to IntelliJ
(global-set-key (kbd "s-e") 'switch-to-buffer)
(global-set-key (kbd "s-O") 'find-file)
(global-set-key (kbd "s-w") 'kill-buffer)
(global-set-key (kbd "C-\\") 'split-window-right)

;; Recent files
(recentf-mode 1)
(setq recentf-max-menu-items 30)
(setq recentf-max-saved-items 30)
(global-set-key (kbd "C-x C-r") 'recentf-open-files)




(set-face-attribute 'default nil :font "Fira Code Retina" :height 132)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
		treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package command-log-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(lsp-tailwindcss json-mode smartparens smartparents parinfer-rust-mode emacs-prisma-mode prisma-mode treemacs-magit treemacs-icons-dired treemacs-projectile treemacs-evil evil-nerd-commenter company-box lsp-ivy lsp-treemacs lsp-ui lsp-mode which-key expand-region flycheck-clj-kondo markdown-mode evil-magit counsel-projectile web-mode company tide magit tagedit projectile cider clojure-mode-extra-font-locking paredit clojure-mode evil-collection evil general counsel rainbow-delimiters doom-themes all-the-icons doom-modeline ivy command-log-mode use-package))
 '(safe-local-variable-values
   '((eval progn
           (make-variable-buffer-local 'cider-jack-in-nrepl-middlewares)
           (add-to-list 'cider-jack-in-nrepl-middlewares "shadow.cljs.devtools.server.nrepl/middleware")))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))


;; NOTE: The first time you load your configuration on a new machine, you'll
;; need to run the following command interactively so that mode line icons
;; display correctly
;;
;; M-x all-the-icons-install-fonts
(use-package all-the-icons)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package doom-themes
  :init (load-theme 'doom-dracula t))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

(use-package general)

(general-define-key
 "C-M-j" 'counsel-switch-buffer
 "C-s" 'counsel-grep-or-swiper)

;; Vim setup
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))


(defun lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((lsp-mode . lsp-mode-setup))
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (let ((lsp-dir (expand-file-name "~/.lsp")))
    (lsp-enable-which-key-integration t)
    (make-directory lsp-dir t)
    (setenv "PATH" (concat lsp-dir path-separator (getenv "PATH")))
    (dolist (m '(clojure-mode
		 clojurec-mode
		 clojurescript-mode
		 clojurex-mode))
      (add-to-list 'lsp-language-id-configuration `(,m . "clojure"))))
  :custom
  (lsp-lens-enable t))


;; Set garbage collection threshold to 1GB.
;; The default setting is too low for lsp-mode's
;; needs due to the fact that client/server
;; communication generates a lot of memory/garbage.
(setq gc-cons-threshold #x40000000)

;; is too low 4k considering that the some of the language server responses are in
;; 800k - 3M range.
(setq read-process-output-max (* 1024 1024)) ;; 1mb


(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after (treemacs lsp)
  :bind (("s-1" . treemacs)))

(use-package lsp-ivy)


(use-package flycheck
  :init (global-flycheck-mode))

(use-package company
  :after lsp-mode
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))


;; project navigation
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom (projectile-completion-system 'ivy)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/workspace")
    (setq projectile-project-search-path '("~/workspace")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

;; Treemacs
(use-package treemacs
  :ensure t
  :defer t
  :config
  (progn
    (setq
     treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
     treemacs-position                        'left
     treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
     treemacs-show-hidden-files               t
     treemacs-sorting                         'alphabetic-asc
     treemacs-select-when-already-in-treemacs 'move-back
     treemacs-space-between-root-nodes        t
     treemacs-tag-follow-cleanup              t)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("s-1"   . treemacs)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)


(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package lsp-treemacs
  :ensure t
  :after (lsp-mode treemacs)
  :config (lsp-treemacs-sync-mode 1))


;; git integration
(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))


(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package expand-region
  :bind  (("C-=" . er/expand-region)))

(use-package evil-nerd-commenter
  :bind ("s-/" . evilnc-comment-or-uncomment-lines))

(use-package smartparens
  :ensure t
  :init (require 'smartparens-config)
  :config
  (progn

    (define-key sp-keymap (kbd "s-{") 'sp-wrap-curly)
    (define-key sp-keymap (kbd "s-[") 'sp-wrap-square)
    (define-key sp-keymap (kbd "s-(") 'sp-wrap-round)
    (define-key sp-keymap (kbd "s-J") 'sp-forward-barf-sexp)
    (define-key sp-keymap (kbd "s-K") 'sp-forward-slurp-sexp)

    (define-key sp-keymap (kbd "C-M-f") 'sp-forward-sexp)
    (define-key sp-keymap (kbd "C-M-b") 'sp-backward-sexp)

    (define-key sp-keymap (kbd "C-M-d") 'sp-down-sexp)
    (define-key sp-keymap (kbd "C-M-a") 'sp-backward-down-sexp)
    (define-key sp-keymap (kbd "C-S-a") 'sp-beginning-of-sexp)
    (define-key sp-keymap (kbd "C-S-d") 'sp-end-of-sexp)

    (define-key sp-keymap (kbd "C-M-e") 'sp-up-sexp)
    (define-key emacs-lisp-mode-map (kbd ")") 'sp-up-sexp)
    (define-key sp-keymap (kbd "C-M-u") 'sp-backward-up-sexp)
    (define-key sp-keymap (kbd "C-M-t") 'sp-transpose-sexp)

    (define-key sp-keymap (kbd "C-M-n") 'sp-next-sexp)
    (define-key sp-keymap (kbd "C-M-p") 'sp-previous-sexp)
    (define-key sp-keymap (kbd "C-M-k") 'sp-kill-sexp)
    (define-key sp-keymap (kbd "C-M-w") 'sp-copy-sexp)
    (define-key sp-keymap (kbd "M-D") 'sp-splice-sexp)
    (define-key sp-keymap (kbd "C-S-<right>") 'sp-forward-slurp-sexp)
    (define-key sp-keymap (kbd "C-S-<left>") 'sp-forward-barf-sexp)
    (define-key sp-keymap (kbd "C-M-<backspace>") 'sp-splice-sexp-killing-backward)
    (define-key sp-keymap (kbd "C-S-<backspace>") 'sp-splice-sexp-killing-around)
    (define-key sp-keymap (kbd "C-M-S-<backspace>") 'sp-splice-sexp-killing-forward)

    (define-key sp-keymap (kbd "M-F") 'sp-forward-symbol)
    (define-key sp-keymap (kbd "M-B") 'sp-backward-symbol)

    (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil)

;;; markdown-mode
    (sp-with-modes '(markdown-mode gfm-mode rst-mode)
      (sp-local-pair "*" "*" :bind "C-*")
      (sp-local-tag "2" "**" "**")
      (sp-local-tag "s" "```scheme" "```")
      (sp-local-tag "<"  "<_>" "</_>" :transform 'sp-match-sgml-tags))

;;; tex-mode latex-mode
    (sp-with-modes '(tex-mode plain-tex-mode latex-mode)
      (sp-local-tag "i" "\"<" "\">"))

;;; html-mode
    (sp-with-modes '(html-mode sgml-mode)
      (sp-local-pair "<" ">"))

;;; lisp modes
    (sp-with-modes sp--lisp-modes
      (sp-local-pair "(" nil :bind "C-("))))

;;;;
;;;; Programming Languages
;;;;


;;;; All
;;;;
(use-package json-mode
  :ensure t)

(add-hook 'prog-mode-hook
	  (lambda ()
	    ;;(flymake-mode)
	    (flycheck-mode)
	    (setq-default indent-tabs-mode nil)
	    (setq-default fill-column 90)
	    (auto-fill-mode 1)))	;java, c, etc



;;;; Lisp
;;;;

(defun lisp-coding-defaults ()
  "Coding preferences for Lisp."
  (subword-mode 1)
  (when (featurep 'smartparens)
    (smartparens-strict-mode +1)))

(add-hook 'lisp-mode-hook 'lisp-coding-defaults)

(defun interactive-lisp-coding-defaults ()
  (lisp-coding-defaults)
  (whitespace-mode -1))

(add-hook 'lisp-interaction-mode-hook 'interactive-lisp-coding-defaults)

(add-hook 'emacs-lisp-mode-hook
	  (lambda ()
            (local-set-key (kbd "C-M-x") 'compile-defun)
	    (lisp-coding-defaults)))


;;; Clojure
;;;

(defun clojure-coding-defaults ()
  "Use Lisp defaulst + extra clojure."
  (lisp-coding-defaults)
  ;; (eldoc-mode 1) ;; clojure-mode is calling this without positive arg to enable it
  (put-clojure-indent '$ 0)
  (setq fill-column 89
        clojure-docstring-fill-column 89))

;; key bindings and code colorization for Clojure
;; https://github.com/clojure-emacs/clojure-mode
(use-package clojure-mode
  :init
  ;; This is useful for working with camel-case tokens, like names of
  (add-hook 'clojure-mode-hook 'clojure-coding-defaults))


(add-hook 'clojure-mode-hook 'lsp-deferred)
(add-hook 'clojurescript-mode-hook 'lsp-deferred)
(add-hook 'clojurec-mode-hook 'lsp-deferred)
  

;; extra syntax highlighting for clojure
(use-package clojure-mode-extra-font-locking)



;; A little more syntax highlighting
(require 'clojure-mode-extra-font-locking)


;;;;
;; Cider
;;;;

;; integration with a Clojure REPL
;; https://github.com/clojure-emacs/cider

(use-package cider)

;; eldoc conflicts with cider?
;; https://github.com/practicalli/spacemacs-content/issues/287
;; load before cider?
;; https://github.com/emacs-lsp/lsp-mode/issues/2445#issuecomment-751481500

;;(setq cider-jdk-src-paths '("/usr/lib/jvm/java-11-openjdk/lib/src.zip"))

(setq nrepl-popup-stacktraces nil)

(defun my-cider-mode-hook ()
  "Disable LSP completion when cider is started."
  (eldoc-mode 1)
  (setq lsp-enable-indentation nil
	lsp-completion-enable nil
        lsp-lens-enable nil
        lsp-headerline-breadcrumb-enable nil))

(defun my-cider-repl-mode-hook ()
  (interactive-lisp-coding-defaults)
  (eldoc-mode 1))

(add-hook 'cider-mode-hook 'my-cider-mode-hook)
(add-hook 'cider-repl-mode-hook 'my-cider-repl-mode-hook)

(global-set-key (kbd "C-j") 'lsp-describe-thing-at-point)

;;;; Typescript
;;;;
(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (progn
    (setq typescript-indent-level 2)
    (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
    (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))))


;;;; Tailwind
;;;;

(use-package lsp-tailwindcss
  :init
  (setq lsp-tailwindcss-add-on-mode t)
  :config
  (progn
    (setq lsp-tailwindcss-experimental-class-regex ":class\\s+\"([^\"]*)\"")
    (dolist (m '(clojure-mode
		 clojurec-mode
		 clojurescript-mode
		 clojurex-mode))
      (add-to-list 'lsp-tailwindcss-major-modes m))))



(provide 'init)

;;; init.el ends here
