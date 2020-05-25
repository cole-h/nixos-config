;;; config.el -*- lexical-binding: t; -*-

;; system setup and friends
;; (toggle-debug-on-quit)
;; (toggle-debug-on-error)
;; (doom/toggle-debug-mode)

(setq user-full-name "Cole Helbling"
      user-mail-address "cole.e.helbling@outlook.com"

      ; max-lisp-eval-depth 400
      ; max-specpdl-size 650
      )

;; modes and friends
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(evil-unimpaired-mode)
(global-eldoc-mode -1)

;; loading and friends
(load! "funcs.el")

;; functions and friends

;; setq and friends
(setq display-line-numbers-type 'relative
      doom-modeline-lsp nil
      inhibit-read-only t
      mouse-wheel-progressive-speed nil
      tab-always-indent 'complete
      which-key-idle-delay 0.4

      ;; lsp-ui-doc-enable nil
      ccls-args '("-v=2" "-log-file=/tmp/ccls.log")
      +workspaces-on-switch-project-behavior t

      magit-repository-directories '(("~/workspace/vcs" . 1)
                                     ("~/workspace/langs" . 1))
      magit-save-repository-buffers nil
      transient-values '((magit-commit "--gpg-sign=B37E0F2371016A4C")
                         (magit-rebase "--autosquash" "--gpg-sign=B37E0F2371016A4C")
                         (magit-pull "--rebase" "--gpg-sign=B37E0F2371016A4C"))

      password-cache-expiry (* 4 (* 60 60))

      inhibit-compacting-font-caches t

      ivy-count-format ""
      ivy-display-style nil
      ivy-extra-directories nil
      ivy-magic-tilde nil)

;; after! and friends
(after! recentf
  (add-to-list 'recentf-exclude "^/dev/shm/"))

(after! company
  (setq company-minimum-prefix-length 2
        company-tooltip-limit 10
        company-idle-delay 0.2))

(after! doom-modeline
  (doom-modeline-def-modeline 'main
    '(bar modals window-number matches buffer-info remote-host buffer-position selection-info)
    '(misc-info persp-name irc mu4e github debug input-method buffer-encoding lsp major-mode process vcs checker)))

(after! evil
  (setq evil-want-fine-undo t
        evil-ex-substitute-global nil))

(after! evil-magit
  (setq evil-magit-use-z-for-folds t))

(after! evil-escape
  (setq evil-escape-inhibit t))

(after! magit
  (setq magit-display-buffer-function 'magit-display-buffer-traditional
        magit-completing-read-function 'ivy-completing-read
        magit-revision-headers-format (concat magit-revision-headers-format "\n%GG"))
  (set-popup-rule! "^.*magit" :slot -1 :side 'bottom :size 15 :select t))

(after! org
  (remove-hook 'org-tab-first-hook #'+org|cycle-only-current-subtree)
  (setq org-log-states-order-reversed t
        org-ellipsis " ▼ "
        org-bullets-bullet-list '(">")
        org-hide-emphasis-markers t
        org-todo-keywords
        '((sequence
           "TODO(t!)" "NEXT(n!)" "ONGOING(o!)" "BLOCKED(b!)"
           "DELEGATE(g!)" "DELEGATED(G!)" "FOLLOWUP(f!)"
           "BACKLOG(T!)" "IDEA(i!)" "|" "CANCELED(c!)" "DONE(d!)"))))

(after! undohist
  (setq undohist-ignored-files '("\\.gpg\\'"
                                 "COMMIT_EDITMSG"
                                 file-remote-p)))

(after! rustic
  ;; workaround from https://github.com/hlissner/doom-emacs/pull/2466
  ;; (require 'smartparens-rust)
  ;; (defun curly-space (&rest _ignored)
  ;;   "Correctly format if you hit space inside of {}"
  ;;   (left-char 1)
  ;;   (insert " "))
  ;; (defun smooth-curly-block (&rest _ignored)
  ;;   "Correctly format if you hit enter inside of ({})"
  ;;   (newline)
  ;;   (indent-according-to-mode)
  ;;   (forward-line -1)
  ;;   (indent-according-to-mode))
  ;; (sp-local-pair 'rustic-mode "({" "})" :post-handlers '((smooth-curly-block "RET")))
  ;; (sp-local-pair 'rustic-mode "{" "}" :post-handlers '((curly-space "SPC") (smooth-curly-block "RET")))
  (setq rustic-format-on-save t
        rustic-lsp-server 'rust-analyzer)
  (setq-local fill-column 100))

(after! smartparens
  (smartparens-global-mode -1))

(after! base16-theme
  ;; I don't want any italics/slanted characters in my modeline
  (custom-set-faces! '(mode-line-emphasis :slant normal)))

(after! magit-todos
  (cl-defun magit-todos-jump-to-item (&key peek (item (oref (magit-current-section) value)))
    "Show current item.
If PEEK is non-nil, keep focus in status buffer window."
    (interactive)
    (let* ((status-window (selected-window))
           (buffer (magit-todos--item-buffer item)))
      (ace-window 1)
      (switch-to-buffer buffer)
      (magit-todos--goto-item item)
      (when (derived-mode-p 'org-mode)
        (org-show-entry))
      (when peek
        (select-window status-window)))))

(after! prescient
  (setq ivy-posframe-border-width 1))

(after! nix-mode
  (setq nix-nixfmt-bin "nixpkgs-fmt")
  (set-formatter! 'nixpkgs-fmt "nixpkgs-fmt" :modes '(nix-mode)))

(after! centaur-tabs
  (setq centaur-tabs-cycle-scope 'tabs))

;; map! and friends
(map! :g "M-<up>" #'drag-stuff-up)
(map! :g "M-<down>" #'drag-stuff-down)
(map! :n "j" #'evil-next-visual-line)
(map! :n "k" #'evil-previous-visual-line)
(map! :n "<down>" #'evil-next-visual-line)
(map! :n "<up>" #'evil-previous-visual-line)
(map! :v "s" #'evil-surround-region)
(map! (:after company :map company-active-map
        "<tab>" #'company-complete-selection
        "<ret>" nil))
(map! (:after ivy :map ivy-minibuffer-map
        "<tab>" #'ivy-alt-done
        "<left>" #'ivy-backward-delete-char
        "<right>" #'ivy-alt-done))
(map! :leader :desc "Kill Emacs" :n "qQ" #'save-buffers-kill-emacs)
(map! :leader :desc "Switch to alternate buffer" :n "," #'vin/alternate-buffer)

;; SPC f p c -> config, SPC f p i -> init, SPC f p p -> packages, SPC f p f -> funcs
(map! :leader "fp" nil
      (:prefix ("fp" . "private")
        :desc "Go to private init.el" :g "i" #'vin/find-init
        :desc "Go to private config.el" :g "c" #'vin/find-config
        :desc "Go to private packages.el" :g "p" #'vin/find-packages
        :desc "Go to private funcs.el" :g "f" #'vin/find-funcs))

;; add-hook! and friends
;; TODO: https://with-emacs.com/posts/ui-hacks/show-matching-lines-when-parentheses-go-off-screen/
(add-hook! 'ediff-cleanup-hook #'vin/ediff-janitor)
;; (add-hook! 'emacs-lisp-mode-hook #'aggressive-indent-mode)
(add-hook! 'text-mode-hook (visual-line-mode 1))
;; (add-hook! 'rustic-mode-hook #'( ;(rainbow-delimiters-mode 1)
;;                       (#'adjust-rust-company-backends)))
(add-hook! 'focus-out-hook 'save-buffer)

;; advice-add and friends
(advice-add 'evil-ex-search-next :after #'vin/center-on-search)
(advice-add 'evil-ex-search-previous :after #'vin/center-on-search)
(advice-add #'lsp--lv-message :override #'ignore)

(defadvice! let-semi-white (orig-fn &rest args)
  :around #'evil-forward-word-begin
  :around #'evil-forward-word-end
  :around #'evil-backward-word-begin
  :around #'evil-backward-word-end
  (let ((table (copy-syntax-table (syntax-table))))
    (modify-syntax-entry ?_ "w" table)
    (with-syntax-table table
      (apply orig-fn args))))
;; Thanks Henrik :-) https://github.com/hlissner/doom-emacs/commit/c6ebf4b4be9d555fb2ae71143a71444b0fa7fe11
