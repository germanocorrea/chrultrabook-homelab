;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, y sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Germano Bruscato Corrêa"
      user-mail-address "germanobruscato@gmail.com")

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
(setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-rose-pine)
;; (setq doom-theme 'doom-laserwave)
;; (setq doom-theme 'doom-horizon)
;;(setq doom-theme 'doom-manegarm)
;;(setq doom-theme 'doom-opera)
;; (setq doom-theme 'doom-sourcerer)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "/mnt/Storage/org/")
(setq org-roam-directory "/mnt/Storage/org/roam")
(org-roam-db-autosync-mode)
(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer)))
(require 'org-roam-protocol)

(add-to-list 'default-frame-alist '(alpha-background . 60))

;; (setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14))
;; (setq doom-variable-pitch-font (font-spec :family "Faculty Glyphic" :size 16))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
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

(setq org-log-done 'note)
(setq org-icalendar-include-todo 'y)
(setq org-agenda-files (directory-files-recursively org-directory "org$"))
(setq org-icalendar-combined-agenda-file (concat org-directory "public/orgmode.ics"))
(setq org-icalendar-use-deadline '(event-if-todo-not-done))
(setq org-icalendar-use-scheduled '(event-if-todo-not-done))
;;(setq org-icalendar-after-save-hook )
(setq org-agenda-span 30)


(defun org-summary-todo (n-done n-not-done)
  "Switch entry to DONE when all subentries are done, to TODO otherwise."
  (let (org-log-done org-log-states)   ; turn off logging
    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

;;(setq org-latex-image-default-scale 0.5)
;; (setq org-format-latex-options '(:foreground default :background "Transparent" :scale 1))
(setq org-export-with-broken-links 'y)

;; (setq org-pad-client 'web)

;; SPELLCHECK
;; (setq ispell-program-name "hunspell")
;; (setq ispell-dictionary "pt_BR,en_US")
;; (with-eval-after-load "ispell"
;;   (setq ispell-hunspell-dict-map-alist nil)
;;   (setq ispell-local-dictionary "pt_BR,en_US")
;;   (add-to-list 'ispell-local-dictionary-alist
;;                '("pt_BR,en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "pt_BR,en_US") nil utf-8)))

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam ;; or :after org
  ;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
  ;;         a hookable mode anymore, you're advised to pick something yourself
  ;;         if you don't care about startup time, use
  ;;  :hook (after-init . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))
