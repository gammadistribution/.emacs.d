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
(add-to-list 'load-path "~/.emacs.d/elpa/auctex-11.87.7")

(setq
 el-get-sources
 '(el-get                ;el-get is self-hosting
   package               ;install emacs packages from elpa
   fill-column-indicator ;fill line for maximum character guide line
   ace-jump-mode         ;jump to anywhere in a buffer
   color-theme           ;need my colors
   emmet-mode            ;for html parsing
   cl-lib                ;pacakage needed for dependencies
   auto-complete         ;completes any word
   autopair              ;pairs up parentheses
   jedi                  ;python auto-completion
   ))

(el-get 'sync el-get-sources)



;;;;;;;;;;;
;; Emacs ;;
;;;;;;;;;;;


;; starts emacs in full screen mode
(defun toggle-fullscreen ()
  (interactive)
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
)
(toggle-fullscreen)


;; Disable splash screen
(setq inhibit-splash-screen t)


;; Enables column number counter.
(setq column-number-mode t)


;; Do not indent with tabs.
(setq-default indent-tabs-mode nil)


;; Indents should be of length 4.
(setq-default tab-width 4)


;; Deletes trailing spaces when saving file.
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;; shows parens
(show-paren-mode t)


;; Turn off tool bar mode
(setq-default tool-bar-mode nil)


;; Set default font to 10pt
(set-face-attribute 'default nil :height 100)


;; stops making backup files
(setq make-backup-files nil)


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


;; sets M-Y to move backwards through kill ring.
(defun yank-pop-forwards (arg)
  (interactive "p")
  (yank-pop (- arg)))

(global-set-key "\M-Y" 'yank-pop-forwards)


;; Enable fill column indicator
(require 'fill-column-indicator)
(define-globalized-minor-mode global-fci-mode fci-mode (lambda () (fci-mode t)))
(global-fci-mode t)
(setq fci-rule-column 80)
(setq fci-rule-color "aquamarine4")


;; Adds color-theme and loads color-theme-gnome2 as default.
(require 'color-theme)
(eval-after-load "color-theme"
  '(progn
     (color-theme-initialize)
     (color-theme-gnome2)))


;;turn on ido mode
(require 'ido)
(ido-mode t)


;; Enable cl-lib to be used with other packages.
(require 'cl-lib)


;; enables ace-jump-mode
(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)


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


;;;;;;;;;;;;;;
;; Org mode ;;
;;;;;;;;;;;;;;


;; org-mode todo keywords
(setq org-todo-keywords
  '((sequence "TODO" "IN-PROGRESS" "DONE")))


;; enables timestamps and notes when items marked as done in org-mode
(setq org-log-done 'time)
(setq org-log-done 'note)



;;;;;;;;;;;;
;; Python ;;
;;;;;;;;;;;;


;; python auto-complete with jedi
;; requires python-virtualenv to be installed
(require 'auto-complete)
(setq jedi:environment-root "python3.4")
(setq jedi:environment-virtualenv
      (list "virtualenv" "--python=/usr/bin/python3.4" "--system-site-packages"))
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


;; Load flymake with pyflakes as minor mode whenever python files are launched.
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
               'flymake-create-temp-inplace))
       (local-file (file-relative-name
            temp-file
            (file-name-directory buffer-file-name))))
      (list "~/.emacs.d/bin/pycheckers" (list local-file))))
   (add-to-list 'flymake-allowed-file-name-masks
             '("\\.py\\'" flymake-pyflakes-init)))
(delete '("\\.html?\\'" flymake-xml-init) flymake-allowed-file-name-masks)
(add-hook 'find-file-hook 'flymake-find-file-hook)


;; Show errors in minibuffer when cursor is on flymake error
(defun show-fly-err-at-point ()
  "If the cursor is sitting on a flymake error, display the message in the minibuffer"
  (require 'cl)
  (interactive)
  (let ((line-no (line-number-at-pos)))
    (dolist (elem flymake-err-info)
      (if (eq (car elem) line-no)
      (let ((err (car (second elem))))
        (message "%s" (flymake-ler-text err)))))))

(add-hook 'post-command-hook 'show-fly-err-at-point)


;; Configure to wait a bit longer after edits before starting
(setq-default flymake-no-changes-timeout '3)


;; Keymaps to navigate to the errors
(add-hook 'python-mode-hook '(lambda () (define-key python-mode-map "\C-cn" 'flymake-goto-next-error)))
(add-hook 'python-mode-hook '(lambda () (define-key python-mode-map "\C-cp" 'flymake-goto-prev-error)))


;; use IPython
(setq-default py-shell-name "ipython")
(setq-default py-which-bufname "IPython")



;;;;;;;;;;
;; HTML ;;
;;;;;;;;;;


;; enables emmet-mode for html authoring
(require 'emmet-mode)
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook 'emmet-mode) ;; Enable Emmet's css abbreviation
;; Indent 2 spaces
(add-hook 'emmet-mode-hook (lambda () (setq emmet-indentation 2)))



;;;;;;;;;;;
;; LaTeX ;;
;;;;;;;;;;;


;; requires texlive-full, texify, auctex, preview-latex on system.
(load "auctex.el" nil t t)

;; Turn on flyspell mode
(add-hook 'LaTeX-mode-hook #'turn-on-flyspell)

;; Turn on pdflatex by default
(setq TeX-PDF-mode t)


;;;;;;;
;; C ;;
;;;;;;;


;; Set default indent level to 4 spaces
(setq-default c-basic-offset 4)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   (quote
    ("~/Documents/mathematics/statistics/statistics.org" "~/Documents/education.org")))
 '(org-support-shift-select t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
