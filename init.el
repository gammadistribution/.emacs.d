;; Initialize el-get and all packages
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(unless (require 'el-get nil 'noerror)
  (setq el-get-install-branch "master")
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp))
  (el-get-emacswiki-refresh el-get-recipe-path-emacswiki t)
)

;; el-get installs cl-lib, a library other packages depend on in package.
;; load cl-lib from place it installs.
(add-to-list 'load-path "~/.emacs.d/el-get/package/elpa/cl-lib-0.5")

(setq
 el-get-sources
 '(el-get            ;el-get is self-hosting
   package           ;install emacs packages from elpa
   ace-jump-mode     ;jump to anywhere in a buffer
   color-theme       ;need my colors
   emmet-mode        ;for html parsing
   cl-lib            ;pacakage needed for dependencies
   auto-complete     ;completes any word
   autopair          ;pairs up parentheses
   jedi              ;python auto-completion
   ))

(el-get 'sync el-get-sources)

;; Disable splash screen
(setq inhibit-splash-screen t)


;; Enables column number counter.
(setq column-number-mode t)


;; Deletes trailing spaces when saving file.
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;; shows parens
(show-paren-mode t)


;; stops making backup files
(setq make-backup-files nil)


;; starts emacs in full screen mode
(defun toggle-fullscreen ()
  (interactive)
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
)
(toggle-fullscreen)


;; save buffers on exit.
(require 'desktop)
  (desktop-save-mode 1)
  (defun my-desktop-save ()
    (interactive)
    ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
    (if (eq (desktop-owner) (emacs-pid))
        (desktop-save desktop-dirname)))
  (add-hook 'auto-save-hook 'my-desktop-save)


;; Keep path synced with shell
(defun set-exec-path-from-shell-PATH ()
    (let ((path-from-shell (shell-command-to-string "$SHELL -c 'echo $PATH'")))
      (setenv "PATH" path-from-shell)
      (setq exec-path (split-string path-from-shell path-separator))))
(when window-system (set-exec-path-from-shell-PATH))


;; org-mode todo keywords
(setq org-todo-keywords
  '((sequence "TODO" "IN-PROGRESS" "DONE")))


;; enables timestamps and notes when items marked as done in org-mode
(setq org-log-done 'time)
(setq org-log-done 'note)


;; Shortcut for python-shell.
(global-set-key (kbd "C-c C-z") 'python-shell)


;; sets M-Y to move backwards through kill ring.
(defun yank-pop-forwards (arg)
  (interactive "p")
  (yank-pop (- arg)))

(global-set-key "\M-Y" 'yank-pop-forwards)


;; enables google voodoo
(defun google ()
  "Google the selected region if any, display a query prompt otherwise."
  (interactive)
  (browse-url
   (concat
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q="
    (url-hexify-string (if mark-active
         (buffer-substring (region-beginning) (region-end))
       (read-string "Search Google: "))))))
(global-set-key (kbd "C-x g") 'google)


;; Enable cl-lib to be used with other packages.
(require 'cl-lib)


;; Adds color-theme and loads color-theme-gnome2 as default.
(require 'color-theme)
(eval-after-load "color-theme"
  '(progn
     (color-theme-initialize)
     (color-theme-gnome2)))


;; enables ace-jump-mode
(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)


;; python auto-complete with jedi
;; requires python-virtualenv to be installed
(require 'auto-complete)
(auto-complete-mode t)
(global-auto-complete-mode t)
(add-hook 'python-mode-hook 'global-auto-complete-mode t)
(add-hook 'python-mode-hook 'jedi:ac-setup t)


;; Install package using el-get
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))


;; automatically pairs up quotes and braces.
(require 'autopair)
(autopair-global-mode) ;; to enable in all buffers


;; enables emmet-mode for html authoring
(require 'emmet-mode)
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook 'emmet-mode) ;; Enable Emmet's css abbreviation
(add-hook 'emmet-mode-hook (lambda () (setq emmet-indentation 2))) ;; Indent 2 spaces
