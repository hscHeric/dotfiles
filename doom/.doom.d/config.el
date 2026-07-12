;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-theme 'doom-one)
(setq display-line-numbers-type t)
(setq org-directory "~/org/")

;; Load personal configuration modules.
(load! "hscheric/init")
