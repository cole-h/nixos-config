;;; ~/.doom.d/funcs.el -*- lexical-binding: t; -*-

(defun vin/alternate-buffer (&optional window)
  "Switch back and forth between current and last buffer in the
current window."
  (interactive)
  (let ((current-buffer (window-buffer window)))
    ;; if no window is found in the windows history, `switch-to-buffer' will
    ;; default to calling `other-buffer'.
    (switch-to-buffer
     (cl-find-if (lambda (buffer)
                   (not (eq buffer current-buffer)))
                 (mapcar #'car (window-prev-buffers window)))
     nil t)))

(defun vin/center-on-search (&rest x)
  "Center the buffer on current search."
  (evil-scroll-line-to-center (line-number-at-pos)))

(defun vin/triple-braces-on-buffer ()
  "Set vim-like folding method."
  (progn
    (setq-local origami-fold-style 'triple-braces)
    (origami-mode)))

(defun vin/disable-mouse ()
  "http://endlessparentheses.com/disable-mouse-only-inside-emacs.html
   Thanks to Artur Malabarba
   Allows left clicking and scrolling, but no other mouse interactions"
  (dolist (type '(mouse down-mouse drag-mouse
                        double-mouse triple-mouse))
    (dolist (prefix '("" C- M- S- M-S- C-M- C-S- C-M-S-))
      (dotimes (n 10) ;; 10 possible mouse buttons
        ;; mouse-4 is scroll up, mouse-5 is scroll down
        (unless (or (eq n 4) (eq n 5) (eq n 1))
          (let ((k (format "%s%s-%s" prefix type n)))
            (define-key evil-normal-state-map
              (vector (intern k)) #'ignore)));;)
        (when (eq n 1) ;; don't want to disable mouse clicking
          (unless (eq type 'mouse)
            (let ((k (format "%s%s-%s" prefix type n)))
              (define-key evil-normal-state-map
                (vector (intern k)) #'ignore))))))))

(defun vin/replace-or-delete-pair (open)
  "Replace pair at point by OPEN and its corresponding closing character.
The closing character is lookup in the syntax table or asked to
the user if not found."
  (interactive
   (list
    (read-char
     (format "Replacing pair %c%c by (or hit RET to delete pair):"
             (char-after)
             (save-excursion
               (forward-sexp 1)
               ;; (char-after))))))
               (char-before))))))
  (if (memq open '(?\n ?\r))
      (delete-pair)
    (let ((close (cdr (aref (syntax-table) open))))
      (when (not close)
        (setq close
              (read-char
               (format "Don't know how to close character %s (#%d) ; please provide a closing character: "
                       (single-key-description open 'no-angles)
                       open))))
      (vin/replace-pair open close))))

(defun vin/replace-pair (open close)
  "Replace pair at point by respective chars OPEN and CLOSE.
If CLOSE is nil, lookup the syntax table. If that fails, signal
an error."
  (let ((close (or close
                   (cdr-safe (aref (syntax-table) open))
                   (error "No matching closing char for character %s (#%d)"
                          (single-key-description open t)
                          open)))
        (parens-require-spaces))
    (insert-pair 1 open close))
  (delete-pair)
  (backward-char 1))

(defun vin/frame-killer ()
  "Kill server buffer and hide the main Emacs window"
  (interactive)
  (condition-case nil
      (delete-frame nil 1)
    (error
     (make-frame-invisible nil 1))))

(defun vin/ediff-janitor ()
  (ediff-janitor nil nil))

(defun vin/find-init ()
  (interactive)
  (find-file-existing (concat doom-private-dir "init.el")))

(defun vin/find-config ()
  (interactive)
  (find-file-existing (concat doom-private-dir "config.el")))

(defun vin/find-packages ()
  (interactive)
  (find-file-existing (concat doom-private-dir "packages.el")))

(defun vin/find-funcs ()
  (interactive)
  (find-file-existing (concat doom-private-dir "funcs.el")))

(defun vin/toggle-maximize-buffer ()
  "Maximize buffer"
  (interactive)
  (save-excursion
    (if (and (= 1 (length (window-list)))
             (assoc ?_ register-alist))
        (jump-to-register ?_)
      (progn
        (window-configuration-to-register ?_)
        (delete-other-windows)))))

(defun vin/backward-delete-char ()
  (interactive)
  (cond ((bolp)
         (delete-char -1)
         (indent-according-to-mode)
         (when (looking-at "\\([ \t]+\\)[^ \t]")
           (delete-region (point) (match-end 1))))
        ((<= (point) (save-excursion (back-to-indentation) (point)))
         (let ((backward-delete-char-untabify-method 'hungry))
           (call-interactively 'backward-delete-char-untabify)
           (delete-char -1))
         (indent-according-to-mode))
        (t
         (let ((backward-delete-char-untabify-method 'hungry))
           (call-interactively 'backward-delete-char-untabify)))))

(defun vin/replace-fancy-quotes ()
  (interactive)
  (cl-destructuring-bind (_ _ _ beg end &optional _)
      evil-last-paste
    (replace-regexp "[‘’]" "'" nil beg end)
    (replace-regexp "[“”]" "\"" nil beg end)))

;; (defun vin/switch-to-messages-buffer (&optional arg)
;;   "Switch to the `*Messages*' buffer.
;; if prefix argument ARG is given, switch to it in an other, possibly new window."
;;   (interactive "P")
;;   (with-current-buffer (messages-buffer)
;;     (goto-char (point-max))
;;     (if arg
;;         (switch-to-buffer-other-window (current-buffer))
;;       (switch-to-buffer (current-buffer)))))

(defun vin/get-contents ()
  "Return the contents of the system clipboard as a string."
  (shell-command-to-string "/usr/bin/wl-paste -pn"))

(defun vin/set-contents (str-val)
  "Set the contents of the system clipboard to STR-VAL."
  (callf or str-val "")
  (assert (stringp str-val) nil "STR-VAL must be a string or nil")
  (message (concat "xclip " str-val))
  (shell-command-to-string (concat "xclip " str-val)))

(defun adjust-rust-company-backends ()
  (remove-hook 'after-change-major-mode-hook #'+company|init-backends 'local)
  (setq-local company-backends
              '((company-dabbrev-code company-gtags company-etags company-lsp)
                company-files)))
