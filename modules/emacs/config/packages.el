;; -*- no-byte-compile: t; -*-
;;; packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:host github :repo "username/repo"))
;; (package! builtin-package :disable t)

(package! hl-line :disable t)

(package! drag-stuff)
(package! i3wm-config-mode :recipe (:host github :repo "Alexander-Miller/i3wm-Config-Mode"))
(package! evil-unimpaired :recipe (:host github :repo "zmaas/evil-unimpaired")) ;; gives ]f (next file)
(package! org-web-tools)
(package! org-recent-headings)
