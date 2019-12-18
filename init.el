;;;; init.el --- Personal  configuration of alifarazz
;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Based on personal Emacs configuration of Samuel Tonini

;;; Code:

;;; Debugging
(setq message-log-max 10000)

;; Please don't load outdated byte code
(setq load-prefer-newer t)

;; Bootstrap `use-package'
(require 'package)
(setq package-enable-at-startup nil)
(setq use-package-always-ensure t)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'bind-key)

(use-package diminish )

;; Customization
(defconst tonini-custom-file (locate-user-emacs-file "customize.el") ;
  "File used to store settings from Customization UI.")

(setq temporary-file-directory (expand-file-name "~/.emacs.d/tmp"));
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'tonini-utils)
(require 'tonini-keybindings)
;; enbale Xah fly keys
(use-package xah-fly-keys
  :delight xah
  :diminish (xah-fly-keys)
  ;; :init
  :config
  (xah-fly-keys-set-layout "qwerty")
  (define-key xah-fly-key-map (kbd "C-o") 'helm-find-files)
  (define-key xah-fly-key-map (kbd "/") 'set-mark-command)
  (define-key xah-fly-key-map (kbd ";") 'xah-end-of-line-or-block)
  (define-key xah-fly-dot-keymap (kbd "t") 'treemacs))
(xah-fly-keys 1) ;; enable'm

(defun my-minibuffer-setup-hook ()
   (setq gc-cons-threshold most-positive-fixnum))
;;(defun my-minibuffer-setup-hook ())
 (defun my-minibuffer-exit-hook ()
   (setq gc-cons-threshold 800000))
;(defun my-minibuffer-exit-hook ())
(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)

;;; User interface

;; Get rid of tool bar, menu bar and scroll bars.  On OS X we preserve the menu
;; bar, since the top menu bar is always visible anyway, and we'd just empty it
;; which is rather pointless.
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (and (eq system-type 'gnu/linux) (fboundp 'menu-bar-mode))
  (menu-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(set-default 'truncate-lines t)
(set-default 'indent-tabs-mode nil)
;; (global-visual-line-mode)
(global-subword-mode t)
(delete-selection-mode 1)
(transient-mark-mode 1)
;; No blinking and beeping, no startup screen, no scratch message and short
;; Yes/No questions.
(blink-cursor-mode 1)
(setq ring-bell-function #'ignore
      inhibit-startup-screen t
      echo-keystrokes 0.1
      linum-format " %d"
      initial-scratch-message "Hi fa! >.<\n")
(fset 'yes-or-no-p #'y-or-n-p)
;; Opt out from the startup message in the echo area by simply disabling this
;; ridiculously bizarre thing entirely.
(fset 'display-startup-echo-area-message #'ignore)

(global-linum-mode)

(set-face-attribute 'default nil
                    :family "Hack" :height 90)
(set-face-attribute 'variable-pitch nil
                    :family "Source Code Pro" :height 90 :weight 'regular)

;; (set-frame-parameter nil 'fullscreen 'fullboth)

;; (add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;; (load-theme 'misterioso t)
;; (load-theme 'adwaita t)
;; (load-theme 'ample-flat t)

;; UTF-8 please
(setq locale-coding-system 'utf-8) ; pretty
(set-terminal-coding-system 'utf-8) ; pretty
(set-keyboard-coding-system 'utf-8) ; pretty
(set-selection-coding-system 'utf-8) ; please
(setq-default buffer-file-coding-system 'utf-8-unix)
(setq-default default-buffer-file-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)
(when (eq system-type 'windows-nt)
  (set-clipboard-coding-system 'utf-16le-dos))


;; System setup

;; `gc-cons-threshold'

;; http://www.gnu.org/software/emacs/manual/html_node/elisp/Garbage-Collection.html
;;
;; I have a modern machine ;)
;;
;; (setq gc-cons-threshold 20000000)

;;;;; Startup optimizations
;;;;;; Set garbage collection threshold
;; From https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/
(setq gc-cons-threshold-original gc-cons-threshold)
(setq gc-cons-threshold (* 1024 1024 100))
;;;;;; Set file-name-handler-alist
;; Also from https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/
(setq file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
;;;;;; Set deferred timer to reset them
(run-with-idle-timer
 5 nil
 (lambda ()
   (setq gc-cons-threshold gc-cons-threshold-original)
   (setq file-name-handler-alist file-name-handler-alist-original)
   (makunbound 'gc-cons-threshold-original)
   (makunbound 'file-name-handler-alist-original)
   (message "gc-cons-threshold and file-name-handler-alist restored")))
;;;;; End of startup optimizations


(setq delete-old-versions t
      make-backup-files nil
      create-lockfiles nil
      ring-bell-function 'ignore
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

(server-start) ;; Allow this Emacs process to be a server for client processes.

(use-package page-break-lines           ; Turn page breaks into lines
  :init (global-page-break-lines-mode)
  :diminish page-break-lines-mode)

(use-package cus-edit
  :defer t
  :config
  (setq custom-file tonini-custom-file
        custom-buffer-done-kill nil            ; Kill when existing
        custom-buffer-verbose-help nil         ; Remove redundant help text
        ;; Show me the real variable name
        custom-unlispify-tag-names nil
        custom-unlispify-menu-entries nil)
  :init (load tonini-custom-file 'no-error 'no-message))

(use-package smartparens
  :init
  (smartparens-global-mode)
  (show-smartparens-global-mode)
  ;; (dolist (hook '(inferior-emacs-lisp-mode-hook
  ;;                 emacs-lisp-mode-hook))
  ;; (add-hook hook #'smartparens-strict-mode))

  :config
  (require 'smartparens-config)
  (setq sp-autoskip-closing-pair 'always)
  :bind
  (:map smartparens-mode-map)
  ("C-c s u" . sp-unwrap-sexp)
  ("C-c s w" . sp-rewrap-sexp)
  :diminish (smartparens-mode))

(use-package ido
  :config
  (setq ido-enable-flex-matching t)
  ;; (ido-everywhere t) ;; disabled due to conflit with helm-mode
  (ido-mode 1))

(use-package hl-line
  :init (global-hl-line-mode 1))

(use-package rainbow-delimiters
  :defer t
  :init
  (dolist (hook '(text-mode-hook prog-mode-hook emacs-lisp-mode-hook))
    (add-hook hook #'rainbow-delimiters-mode)))

(use-package hi-lock
  :init (global-hi-lock-mode))

(use-package highlight-numbers

  :defer t
  :init (add-hook 'prog-mode-hook #'highlight-numbers-mode))

(use-package rainbow-mode
  :bind (("C-c t r" . rainbow-mode))
  :config (add-hook 'css-mode-hook #'rainbow-mode)
  :diminish (rainbow-mode))

(use-package company                    ; Graphical (auto-)completion
  :init (global-company-mode)
  :config
  (progn
    (delete 'company-dabbrev company-backends)
    (setq company-tooltip-align-annotations t)
    company-tooltip-minimum-width 27
    company-idle-delay 0.3
    company-tooltip-limit 10
    company-minimum-prefix-length 3
    company-tooltip-flip-when-above t)
  :bind (:map company-active-map
              ("M-k" . company-select-next)
              ("M-i" . company-select-previous)
              ("TAB" . company-complete-selection))
  :diminish company-mode)

;;; alifarzz: with icons!! ;; acutally, NO!
;(use-package company-box
;  :hook (company-mode . company-box-mode))

(use-package ag
  :commands (ag ag-regexp ag-project))

(use-package tester
  :load-path "~/Projects/tester.el"
  :commands (tester-run-test-file tester-run-test-suite))

(use-package helm
  :bind (("M-a" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x f" . helm-recentf)
         ("C-SPC" . helm-dabbrev)
         ("M-y" . helm-show-kill-ring)
         ("C-x b" . helm-buffers-list))
  :bind (:map helm-map
              ("M-i" . helm-previous-line)
              ("M-k" . helm-next-line)
              ("M-I" . helm-previous-page)
              ("M-K" . helm-next-page)
              ("M-h" . helm-beginning-of-buffer)
              ("M-H" . helm-end-of-buffer)
              ("<tab>" . helm-execute-persistent-action)
              ("C-i" . helm-execute-persistent-action))
  :config (progn
            (setq helm-buffers-fuzzy-matching t)
            (helm-mode 1))
  (setq helm-split-window-in-side-p           t
        helm-buffers-fuzzy-matching           t
        helm-move-to-line-cycle-in-source     t
        helm-ff-search-library-in-sexp        t
        helm-ff-file-name-history-use-recentf t
        helm-ag-fuzzy-match                   t)

  (substitute-key-definition 'find-tag 'helm-etags-select global-map)
  (setq projectile-completion-system 'helm)
  ;; Display helm buffers always at the bottom
  ;; Source: http://www.lunaryorn.com/2015/04/29/the-power-of-display-buffer-alist.html
  (add-to-list 'display-buffer-alist
               `(,(rx bos "*helm" (* not-newline) "*" eos)
                 (display-buffer-reuse-window display-buffer-in-side-window)
                 (reusable-frames . visible)
                 (side            . bottom)
                 (window-height   . 0.4)))
  :diminish (helm-mode))
(use-package helm-descbinds

  :bind ("C-h b" . helm-descbinds))
(use-package helm-files
  :bind (:map helm-find-files-map
              ("M-i" . nil)
              ("M-k" . nil)
              ("M-I" . nil)
              ("M-K" . nil)
              ("M-h" . nil)
              ("M-H" . nil)
              ("M-v" . yank)))
(use-package helm-swoop
  :bind (("M-m" . helm-swoop)
         ("M-M" . helm-swoop-back-to-last-point))
  :init
  (bind-key "M-m" 'helm-swoop-from-isearch isearch-mode-map))
(use-package helm-ag
  :ensure helm-ag
  :bind ("M-p" . helm-projectile-ag)
  :commands (helm-ag helm-projectile-ag)
  :init (setq helm-ag-insert-at-point 'symbol
              helm-ag-command-option "--path-to-ignore ~/.agignore")) ;

(use-package helm-info
  :ensure helm
  :bind (([remap info] . helm-info-at-point)
         ("C-c h e"    . helm-info-emacs))
  :config
  ;; Also lookup symbols in the Emacs manual
  (add-to-list 'helm-info-default-sources
               'helm-source-info-emacs))

(use-package helm-flycheck              ; Helm frontend for Flycheck errors
  :defer t
  :after flycheck)

(use-package winner                     ; Undo and redo window configurations
  :init (winner-mode))

(use-package desktop                    ; Save buffers, windows and frames
  :disabled t
  :init (desktop-save-mode)
  :config
  ;; Save desktops a minute after Emacs was idle.
  (setq desktop-auto-save-timeout 60)

  ;; Don't save Magit and Git related buffers
  (dolist (mode '(magit-mode magit-log-mode))
    (add-to-list 'desktop-modes-not-to-save mode))
  (add-to-list 'desktop-files-not-to-save (rx bos "COMMIT_EDITMSG")))


(use-package multiple-cursors           ; Edit text with multiple cursors
  :bind (("C-c o <SPC>" . mc/vertical-align-with-space)
         ("C-c o a"     . mc/vertical-align)
         ("C-c o e"     . mc/mark-more-like-this-extended)
         ("C-c o h"     . mc/mark-all-like-this-dwim)
         ("C-c o l"     . mc/edit-lines)
         ("C-c o n"     . mc/mark-next-like-this)
         ("C-c o p"     . mc/mark-previous-like-this)
         ("C-c o r"     . vr/mc-mark)
         ("C-c o C-a"   . mc/edit-beginnings-of-lines)
         ("C-c o C-e"   . mc/edit-ends-of-lines)
         ("C-c o C-s"   . mc/mark-all-in-region))
  :config
  (setq mc/mode-line
        ;; Simplify the MC mode line indicator
        '(:propertize (:eval (concat " " (number-to-string (mc/num-cursors))))
                      face font-lock-warning-face)))

;; (use-package autorevert                 ; Auto-revert buffers of changed files
;;   :init (global-auto-revert-mode)
;;   :config
;;   (setq auto-revert-verbose nil         ; Shut up, please!
;;         ;; Revert Dired buffers, too
;;         global-auto-revert-non-file-buffers t)

  ;; (when (eq system-type 'darwin)
  ;;   ;; File notifications aren't supported on OS X
  ;;   (setq auto-revert-use-notify nil))
  ;; :diminish (auto-revert-mode))

(use-package subword                    ; Subword/superword editing
  :defer t
  :diminish subword-mode)

(use-package ibuffer-vc                 ; Group buffers by VC project and status
  :disabled t
  :defer t
  :init (add-hook 'ibuffer-hook
                  (lambda ()
                    (ibuffer-vc-set-filter-groups-by-vc-root)
                    (unless (eq ibuffer-sorting-mode 'alphabetic)
                      (ibuffer-do-sort-by-alphabetic)))))

(use-package projectile
  :bind (("C-x p" . projectile-persp-switch-project))
  :config
  (setq projectile-completion-system 'helm)
  (projectile-global-mode)
  (helm-projectile-on)
  (setq projectile-enable-caching nil)
  :diminish (projectile-mode))

(use-package ibuffer-projectile         ; Group buffers by Projectile project
  :defer t
  :init (add-hook 'ibuffer-hook #'ibuffer-projectile-set-filter-groups))

(use-package persp-projectile
  :defer 1
  ;; :bind (("C-p s" . projectile-persp-switch-project))
  :config
  (persp-mode))
  ;; (defun persp-format-name (name)
  ;;   "Format the perspective name given by NAME for display in `persp-modestring'."
  ;;   (let ((string-name (format "%s" name)))
  ;;     (if (equal name (persp-name persp-curr))
  ;;         (propertize string-name 'face 'persp-selected-face))))

;;   (defun persp-update-modestring ()
;;     "Update `persp-modestring' to reflect the current perspectives.
;; Has no effect when `persp-show-modestring' is nil."
;;     (when persp-show-modestring
;;       (setq persp-modestring
;; 	    (append '("[")
;; 		    (persp-intersperse (mapcar 'persp-format-name (persp-names)) "")
;; 		    '("]")))))


(use-package helm-projectile
  :config
  (helm-projectile-on))

;; (use-package elixir-mode
;;   :load-path "~/Projects/emacs-elixir/"
;;   :config (progn
;; 	    (defun my-elixir-do-end-close-action (id action context)
;; 	      (when (eq action 'insert)
;; 		(newline-and-indent)
;; 		(forward-line -1)
;; 		(indent-according-to-mode)))

;; 	    (sp-with-modes '(elixir-mode)
;; 	      (sp-local-pair "do" "end"
;; 			     :when '(("SPC" "RET"))
;; 			     :post-handlers '(:add my-elixir-do-end-close-action)
;; 			     :actions '(insert)))))

(use-package yasnippet
  :defer t
  :init
  (yas-global-mode +1)
  :config
  (setq yas-snippet-dirs "~/.emacs.d/snippets")
  :diminish (yas-minor-mode . " YS"))

;; (use-package alchemist
;;   :defer 1
;;   :load-path "~/Projects/alchemist.el/"
;;   :bind (:map alchemist-iex-mode-map
;; 	      ("C-d" . windmove-right)
;; 	 :map alchemist-mode-map
;; 	      ("M-w" . alchemist-goto-list-symbol-definitions))
;;   :config (progn
;; 	    (setq alchemist-goto-elixir-source-dir "~/Projects/elixir/")
;; 	    (setq alchemist-goto-erlang-source-dir "~/Projects/otp/")
;; 	    (defun tonini-alchemist-mode-hook ()
;; 	      (tester-init-test-run #'alchemist-mix-test-file "_test.exs$")
;; 	      (tester-init-test-suite-run #'alchemist-mix-test))
;;             (add-hook 'alchemist-mode-hook 'tonini-alchemist-mode-hook)

;; 	    ;; Display alchemist buffers always at the bottom
;; 	    ;; Source: http://www.lunaryorn.com/2015/04/29/the-power-of-display-buffer-alist.html
;; 	    (add-to-list 'display-buffer-alist
;; 			 `(,(rx bos (or "*alchemist test report*"
;; 					"*alchemist mix*"
;; 					"*alchemist help*"
;; 					"*alchemist elixir*"
;; 					"*alchemist elixirc*"))
;; 			   (display-buffer-reuse-window
;; 			    display-buffer-in-side-window)
;; 			   (reusable-frames . visible)
;; 			   (side            . right)
;; 			   (window-width   . 0.5)))))

;; (use-package erlang
;;
;;   :bind (:map erlang-mode-map ("M-," . alchemist-goto-jump-back))
;;   :config
;;   (setq erlang-indent-level 2))

;; (use-package enh-ruby-mode
;;
;;   :defer t
;;   :mode (("\\.rb\\'"       . enh-ruby-mode)
;;          ("\\.ru\\'"       . enh-ruby-mode)
;;          ("\\.jbuilder\\'" . enh-ruby-mode)
;;          ("\\.gemspec\\'"  . enh-ruby-mode)
;;          ("\\.rake\\'"     . enh-ruby-mode)
;;          ("Rakefile\\'"    . enh-ruby-mode)
;;          ("Gemfile\\'"     . enh-ruby-mode)
;;          ("Guardfile\\'"   . enh-ruby-mode)
;;          ("Capfile\\'"     . enh-ruby-mode)
;;          ("Vagrantfile\\'" . enh-ruby-mode))
;;   :config (progn
;;             (setq enh-ruby-indent-level 2
;;                   enh-ruby-deep-indent-paren nil
;;                   enh-ruby-bounce-deep-indent t
;;                   enh-ruby-hanging-indent-level 2)
;;             (setq ruby-insert-encoding-magic-comment nil)))

;; (use-package rubocop
;;
;;   :defer t
;;   :init (add-hook 'ruby-mode-hook 'rubocop-mode))

;; (use-package rspec-mode
;;
;;   :defer t
;;   :config (progn
;;             (defun rspec-ruby-mode-hook ()
;;               (tester-init-test-run #'rspec-run-single-file "_spec.rb$")
;;               (tester-init-test-suite-run #'rake-test))
;;             (add-hook 'enh-ruby-mode-hook 'rspec-ruby-mode-hook)))

(use-package rbenv
  :defer t
  :init (progn)
    (setq rbenv-show-active-ruby-in-modeline nil)
    (global-rbenv-mode)
  :config (progn
            (global-rbenv-mode)
            (add-hook 'enh-ruby-mode-hook 'rbenv-use-corresponding)))

(use-package f)

;; ;;; OS X support
;; (use-package ns-win                     ; OS X window support
;;   :ensure f
;;   :defer t
;;   :if (eq system-type 'darwin)
;;   :config
;;   (setq ns-pop-up-frames nil            ; Don't pop up new frames from the
;;                                         ; workspace
;;         mac-option-modifier 'meta       ; Option is simply the natural Meta
;;         mac-command-modifier 'meta      ; But command is a lot easier to hit
;;         mac-right-command-modifier 'left
;;         mac-right-option-modifier 'none ; Keep right option for accented input
;;         ;; Just in case we ever need these keys
;;         mac-function-modifier 'hyper))

;;; Environment fixup
(use-package exec-path-from-shell
  :config
  (progn
    (exec-path-from-shell-initialize)
    ;; Re-initialize the `Info-directory-list' from $INFOPATH.  Since package.el
    ;; already initializes info, we need to explicitly add the $INFOPATH
    ;; directories to `Info-directory-list'.  We reverse the list of info paths
    ;; to prepend them in proper order subsequently
    (with-eval-after-load 'info
      (dolist (dir (nreverse (parse-colon-path (getenv "INFOPATH"))))
        (when dir
          (add-to-list 'Info-directory-list dir))))))

(use-package default-text-scale
  )

(use-package overseer
  :init
  (progn
    (defun test-emacs-lisp-hook ()
      (tester-init-test-run #'overseer-test-file "-test.el$")
      (tester-init-test-suite-run #'overseer-test))
    (add-hook 'overseer-mode-hook 'test-emacs-lisp-hook)))

(use-package karma
  :init)

(use-package elisp-slime-nav
  :init (add-hook 'emacs-lisp-mode-hook #'elisp-slime-nav-mode)
  :diminish elisp-slime-nav-mode)

(use-package emacs-lisp-mode
  :ensure f
  :defer t
  :interpreter ("emacs" . emacs-lisp-mode)
  :bind (:map emacs-lisp-mode-map
              ("C-c e r" . eval-region)
              ("C-c e b" . eval-buffer)
              ("C-c e e" . eval-last-sexp)
              ("C-c e f" . eval-defun))
  :diminish (emacs-lisp-mode . "EL"))

(use-package cask-mode
  :defer t)

(use-package macrostep
  :after elisp-mode
  :bind (:map emacs-lisp-mode-map ("C-c m x" . macrostep-expand)
              :map lisp-interaction-mode-map ("C-c m x" . macrostep-expand)))

(use-package ert
  :after elisp-mode)

(use-package js2-mode
  :mode (("\\.js\\'" . js2-mode)
         ("\\.js.erb\\'" . js2-mode)
         ("\\.jsx\\'" . js2-jsx-mode))
  :bind (:map js2-mode-map)
        ("M-j" . backward-char)
  :config (setq js2-basic-offset 2))

(use-package typescript-mode
  :config (setq typescript-indent-level 2))

(use-package coffee-mode
  :mode (("\\.coffee\\'" . coffee-mode)
         ("\\.coffee.erb\\'" . coffee-mode)))

(use-package js2-refactor
  :after js2-mode
  :init
  (add-hook 'js2-mode-hook 'js2-refactor-mode)
  :config
  (js2r-add-keybindings-with-prefix "C-c m r"))

(use-package company-tern
  :disabled t
  :after company)

(use-package flycheck
  :defer 5
  ;; :config
  ;; (add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++17")))
  ;; (add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c17")))
  ;; (global-flycheck-mode 1)
  :diminish (flycheck-mode))

(use-package drag-stuff
  :config
  (progn
    (drag-stuff-global-mode 1)
    (drag-stuff-define-keys))
  :diminish (drag-stuff))


(use-package magit
  :defer 2
  :bind (("C-x g" . magit-status))
  :config
  (progn
    (delete 'Git vc-handled-backends)))

(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

(use-package web-mode
  :mode (("\\.erb\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.html?\\'" . web-mode)
         ("\\.eex\\'" . web-mode)
         ("\\.php\\'" . web-mode))
  :config (progn
            (setq web-mode-markup-indent-offset 2
                  web-mode-css-indent-offset 2
                  web-mode-code-indent-offset 2)))

(use-package emmet-mode
  :bind (:map emmet-mode-keymap)
        ("M-e" . emmet-expand-line)
  :config (add-hook 'web-mode-hook 'emmet-mode))

(use-package sass-mode
  )

(use-package scss-mode
  )

(use-package whitespace-cleanup-mode
  :bind (("C-c t c" . whitespace-cleanup-mode)
         ("C-c x w" . whitespace-cleanup))
  :init (dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
          (add-hook hook #'whitespace-cleanup-mode))
  :diminish (whitespace-cleanup-mode))

(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode))

;;; alifarazz mods
;; IDE-like stuff

;; (use-package neotree
;;   :config
;;   (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
;;   (setq neo-smart-open t)
;;   (setq neo-theme 'icons))
;; (use-package all-the-icons)
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-follow-delay             0.2
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-desc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-width                         30)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ;; ("M-0"       . treemacs-select-window)
        ;; ("C-x t 1"   . treemacs-delete-other-windows)
        ;; ("C-x t t"   . treemacs)
        ;; ("C-x t B"   . treemacs-bookmark)
        ;; ("C-x t C-t" . treemacs-find-file)
        ;; ("C-x t M-t" . treemacs-find-tag)
))
;; (use-package treemacs-evil
;;   :after treemacs evil
;;   :ensure t)
(use-package treemacs-projectile
  :after treemacs projectile)
(use-package treemacs-icons-dired
  :after treemacs dired  ;; disabled due to a bug in intel's opencl driver triggerd by imagemagick
  :config (treemacs-icons-dired-mode))
(use-package treemacs-magit
  :after treemacs magit)

;; C[pp] stuff
(use-package cmake-mode
  :mode ("CMake.Lists.txt\\'" . cmake-mode))
;; (use-package ggtags
;;   :init (add-hook 'c-mode-hook 'c++-mode-hook))
(use-package clang-format
  :hook c-mode ;; is cc-mode useless?
  :bind (:map c-mode-base-map
              ("C-c f r" . clang-format-region)
              ("C-c f b" . clang-format-buffer)
))
;; (use-package beacon
;;   :config
;;   (progn (beacon-mode 1))
;; )
(blink-cursor-mode 0)

;; Multiple cursor incremental search & replace
(use-package phi-search
  :bind ("M-%" . phi-replace-query))

;; lsp for language server stuff
(use-package lsp-mode
  :config
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection "pyls")
                    :major-modes '(python-mode)
                    :server-id 'pyls))
  (add-hook 'python-mode-hook #'lsp)
  (setq create-lockfiles nil) ;we will get error "Wrong type argument: sequencep" from `eldoc-message' if `lsp-enable-eldoc' is non-nil
  (setq lsp-message-project-root-warning t) ;avoid popup warning buffer if lsp can't found root directory (such as edit simple *.py file)
  (setq lsp-enable-eldoc nil) ;we will get error "Error from the Language Server: FileNotFoundError" if `create-lockfiles' is non-nil
  :commands lsp)

(use-package lsp-ui
  :config
  ;; (setq lsp-ui-sideline-ignore-duplicate t)
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))

(use-package company-lsp
  :config
  (push 'company-lsp company-backends))

(use-package dap-mode
  :after lsp-mode
  :config
  (progn
    (dap-mode 1)
    (dap-ui-mode 1)
    ;; enables mouse hover support
    (dap-tooltip-mode 1)
    ;; use tooltips for mouse hover
    ;; if it is not enabled `dap-mode' will use the minibuffer.
    (tooltip-mode 1)))

;; java stuff
(use-package lsp-ui)
(use-package dap-java :ensure nil :after (lsp-java))
(use-package lsp-java :after lsp
  :config (add-hook 'java-mode-hook 'lsp))

;; language server for python
(use-package lsp-python-ms
  :config
  (add-hook 'python-mode-hook #'lsp-python-enable))

;; language server for C[pp]
(use-package ccls
  :config (setq ccls-executable "/usr/bin/ccls")
  :hook ((c-mode c++-mode objc-mode) .
         (lambda () (require 'ccls) (lsp))))

;; support for the rest of cpp files
(dolist (mode (list '("\\.h\\'" . c-mode)
                    '("\\.hpp\\'" . c++-mode)
                    '("\\.hxx\\'" . c++-mode)
                    '("\\.hh\\'" . c++-mode)
                    '("\\.cc\\'" . c++-mode)))
  (add-to-list 'auto-mode-alist mode))

;; disable flymake on python
;; (add-hook 'python-mode-hook (lambda () (setq flymake-mode -1)))

;; generic Emacs/Scheme interaction mode
(use-package geiser
  :config
  (setq geiser-active-implementations '(guile chez))
)

;; Hydra config
(use-package hydra
  )
(use-package use-package-hydra
  :after hydra
  )
(use-package cider-hydra
  :after hydra
  :config (add-hook 'clojure-mode-hook #'cider-hydra-mode))


;; Clojure
(use-package clojure-mode)

(use-package cider
  :delight
  :config  (add-hook 'clojure-mode-hook #'cider-mode))

;; (use-package parinfer
;;
;;   :delight
;;   :bind
;;   (("C-," . parinfer-toggle-mode))
;;   :init
;;   (progn
;;     (setq parinfer-extensions
;;           '(defaults       ; should be included.
;;              pretty-parens))  ; different paren styles for different modes.
;;     ;; evil           ; If you use Evil.
;;     ;; lispy          ; If you use Lispy. With this extension, you should install Lispy and do not enable lispy-mode directly.
;;     ;; paredit        ; Introduce some paredit commands.
;;     ;; smart-tab      ; C-b & C-f jump positions and smart shift with tab & S-tab.
;;     ;; smart-yank   ; Yank behavior depend on mode.

;;     (add-hook 'clojure-mode-hook #'parinfer-mode)
;;     (add-hook 'emacs-lisp-mode-hook #'parinfer-mode)
;;     (add-hook 'common-lisp-mode-hook #'parinfer-mode)
;;     (add-hook 'scheme-mode-hook #'parinfer-mode)
;;     (add-hook 'lisp-mode-hook #'parinfer-mode)))

;;; General
;; auto update packages
;(use-package auto-package-update
;
;  :config
;  (setq auto-package-update-delete-old-versions t)
;  (setq auto-package-update-hide-results t)
;  (auto-package-update-maybe))

;; ;; enable hungry-delete on all modes
;; (use-package hungry-delete
;;   :commands global-hungry-delete-mode)

(use-package which-key
  :config (which-key-mode 1))


;; theme
(use-package ample-theme
  :init (progn
          (load-theme 'ample t t)
          (load-theme 'ample-flat t t)
          (load-theme 'ample-light t t)
          (enable-theme 'ample-flat))
  :defer t
)
;; (use-package flatland-theme
;;   ;; :init (progn (load-theme 'flatland t t))
;;   ;;              (enable-theme 'flatland))
;;   :defer t
;; )
;; (use-package ujelly-theme
;;   ;; :init (progn (load-theme 'ujelly t t))
;;                ;; (enable-theme 'ujelly))
;;   :defer t
;; )
;; (use-package monokai-pro-theme
;;   :init (progn (load-theme 'monokai-pro t t)

;;                )
;;   :defer t
;; )

;; (use-package waf-mode
;;   :mode ("wscript\\'" . cmake-mode)
;; )

(use-package fish-mode
  :mode ("\\.fish\\'" . markdown-mode)
)

;; remove trailing white-space
(use-package simple
  :ensure nil
  :hook
  (before-save . delete-trailing-whitespace)
 )

;; for reading epubs.
(use-package nov
  :config
  (push '("\\.epub\\'" . nov-mode) auto-mode-alist)
)

;; (use-package crystal-mode
;;   :mode ("\\.cr\\'" . crystal-mode)
;; )

(provide 'init)

;;; init.el ends here
(put 'upcase-region 'disabled nil)
