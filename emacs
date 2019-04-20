; .emacs

;;; This file, which must be called '.emacs' and must reside in your
;;; home directory, is automatically read in by GNU Emacs as it is
;;; invoked. If you want to understand what is going on here, try
;;; using the excellent help facility built into the editor.

;;; These are just suggestions for an init file.  Feel free to remove or 
;;; add as you wish.  Note that a number of suggestions are commented out.

;;; PLEASE check to see what is in your .emacs file before replacing
;;; it with this.  Some commands write out info into your .emacs file
;;; and you will lose this if you copy this file over it.


;; (setq homedir "/Users/sef")


;;; Just some randoms.
(put 'eval-expression 'disabled nil) ; don't disable this
(setq inhibit-startup-message t)     ; don't show me the startup message

;;; This line was probably in a .emacs file that emacs created for
;;; you.  I'm putting it in here since you might have overwritten your
;;; old .emacs file.  If you set it up to not suspend emacs set the
;;; last value to "t" (instead of "nil").

;;; Make the mode line a little more useful.
(setq-default mode-line-buffer-identification '("Buffer: %b"))
(setq-default mode-line-format
	      '("%[" mode-line-buffer-identification
	        "%* " global-mode-string "(" mode-name
	        minor-mode-alist "%n" mode-line-process ") File: %f [%p]%]"))

;;; If you want this instead of "lisp-buffers" (which is on C-x C-b now),
;;; uncomment the next line.
;(define-key ctl-x-map "\C-b" 'buffer-menu)

;;; Run rmail on C-x r.  (instead of find-file-read-only).
;(define-key ctl-x-map "r" 'vm)
;;;(define-key ctl-x-map "i" 'vm-visit-folder)

;;; Change the behaviour of "reply" in Rmail to only reply to the sender
;;; instead of the sender and all other recipients.
(defun rmail-reply-just-sender (everyone)
  "Reply to the current message.
Reply just to the sender, prefix argument means to include all other
recipients. 
While composing the reply, use \\[mail-yank-original] to yank the
original message into it."
  (interactive "P")
  (if everyone
      (rmail-reply nil)
    (rmail-reply 1)))
(setq rmail-mode-hook
      '(lambda () (define-key rmail-mode-map "r" 'rmail-reply-just-sender)))

;;; turn on auto-fill sometimes
(defun my-auto-fill-mode nil (auto-fill-mode 1))
(setq text-mode-hook 'my-auto-fill-mode)
(setq mail-mode-hook 'my-auto-fill-mode)
(setq text-mode-hook 'my-auto-fill-mode)
(setq html-helper-mode-hook 'my-auto-fill-mode)

;;; If auto-mode-alist can't determine what mode the latest file
;;; needs, the default should be text-mode...
;;; Uncomment this is you want the default to be text mode 
;;; instead of fundamental.
;(setq-default major-mode 'text-mode)


;;; Want all mail to Bcc to yourself.  The second line says don't Cc to 
;;; yourself (since you are already Bcc'ing yourself).
;(setq mail-self-blind t)
;(setq rmail-dont-reply-to-names (getenv "USER"))

;;; Display time and load averages on the mode line.  (Used with the setting
;;; of the mode line above.)
;;; (load "time" t t)

;;; (display-time)

;;; Exchange behaviour of ESC and TAB in the minibuffer.
;;; Uncomment if you want.
;(define-key minibuffer-local-completion-map "\t" 'ESC-prefix)
;(define-key minibuffer-local-completion-map "\e" 'minibuffer-complete)
;(define-key minibuffer-local-must-match-map "\t" 'ESC-prefix)
;(define-key minibuffer-local-must-match-map "\e" 'minibuffer-complete)

;;; /usr/local/gnuemacs/lisp/default.el is loaded after this file so you
;;; should look there to make sure you aren't doing something twice.

(put 'suspend-emacs 'disabled nil)

;;; Here are Ingemar's fixes to make backspace into delete, etc.


; SEF - KEYMAPPING
(global-set-key "\M-s" 'save-buffer)
; now handled by xmodmap directly
(global-set-key [?\A-x] 'execute-extended-command)
(global-set-key [?\A-w] 'copy-region-as-kill)
; don't like home/end moving to top/bottom of buffer
(global-set-key [end] 'end-of-line)
(global-set-key [home] 'beginning-of-line)
(global-set-key [f5] 'font-lock-fontify-buffer)


;; C-h will be our backwards delete
;(global-set-key "\C-?" 'delete-char)
;(global-set-key "\C-h" 'delete-backward-char)

;; either of these will work, but Lisp Interaction mode (*scratch*)
;; has its own binding for del

;(global-set-key [?\C-?] 'delete-char)

;;(global-set-key "\177" 'delete-char)
;;(global-unset-key [?\C-?])

;;(global-set-key "\M-h" 'help-for-help)
;;(global-set-key "\M-\C-h" 'backward-kill-word)

(global-unset-key "\M-[")
(global-unset-key "\M-O")

;;; Mapping PC keys to be useful
;;; (global-set-key "\M-d" 'scroll-up)
;;; (global-set-key "\M-m" 'scroll-down)
;;; (global-set-key "\M-[H" 'beginning-of-line)
;;; (global-set-key "\M-[24;1H" 'end-of-line)

;;; M      (pgup)
;;; D      (pgdn)
;;; [H     (home)
;;; [24;1H (end)
;;; OC (c-right)
;;; OD (c-left)


(setq mail-archive-file-name "~/OUTSAVE")
(setq mail-default-reply-to "sef@akamai.com")

; this won't work when I dial up

; (set-default-font "courier-15")

     
;(setq gnus-subscribe-newsgroup-method 
;      '(lambda (newsgroup) nil))        ;Do nothing.

(setq 
 load-path (cons
	    "/home/sef/emacs"
	    load-path))

(if (not (string-match "XEmacs" (emacs-version)))
    (progn 
      (autoload 'vm "vm" "Start VM on your primary inbox." t)
      (autoload 'vm-visit-folder "vm" "Start VM on an arbitrary folder." t)
      (autoload 'vm-visit-virtual-folder "vm" "Visit a VM virtual folder." t)
      (autoload 'vm-mode "vm" "Run VM major mode on a buffer" t)
      (autoload 'vm-mail "vm" "Send a mail message using VM." t)
      (autoload 'vm-submit-bug-report "vm" "Send a bug report about VM." t)))


;; Prefix region (for rmail, in particular) -- simple & robust.
;; Christopher North-Keys, 1989
(defun prefix-region (start end string)
  "Insert STRING, default '> ', at the start of each line
in or intersecting region while preserving indentation.
Called from a program, takes three arguments,START, END and STRING."
  (interactive "r\nsString:  ")
  (if (or (equal string "") (equal string nil))
      (setq string "> "))
  ;; Adjust start and end to extremes of



  ;; lines so lines don't get broken.
  (goto-char end)
  (end-of-line)
  (setq end (point))
  (goto-char start)
  (beginning-of-line)
  (setq start (point))
  ;; There is another command, replace-regexp, that did not work well.
  ;; If you narrowed as one would expect, you could not widen to the
  ;; previous narrow.  Saving the old narrow extremes failed, as this
  ;; routine expands the region.  Sadmaking.
  (let (line)
    (setq lines (count-lines start end))
    (while (> lines 0)
      (insert string)
      (search-forward "\n")
      (setq lines (- lines 1))
      )))

(custom-set-variables
 '(c-default-style "k&r")
 '(c-basic-offset 4)
 '(adaptive-fill-first-line-regexp "\\`[- 	]*\\'")
 '(viper-want-ctl-h-help t)
 '(outline-regexp "[-]+" t)
 '(query-user-mail-address nil)
 '(frame-background-mode nil)
 '(user-mail-address "sef@akamai.com")
 '(fill-column 72))
(custom-set-faces
 '(viper-minibuffer-insert-face ((((class color)) (:foreground "gold"))))
 '(viper-replace-overlay-face ((((class color)) (:background "grey30"))))
 '(font-lock-comment-face ((((class color) (background dark)) (:foreground "OrangeRed"))))
 '(font-lock-string-face ((((class color) (background light)) (:foreground "gold"))))
 '(viper-minibuffer-vi-face ((((class color)) (:foreground "salmon"))))
 '(font-lock-keyword-face ((((class color) (background dark)) (:foreground "green"))))
 '(show-paren-mismatch-face ((((class color)) (:background "red"))))
 '(font-lock-warning-face ((((class color) (background dark)) (:bold t :foreground "Red"))))
 '(modeline-buffer-id ((t (:foreground "skyblue"))) t)
 '(font-lock-type-face ((((class color) (background dark)) (:foreground "LightSkyBlue"))))
 '(show-paren-match-face ((((class color)) (:background "blue"))))
 '(font-lock-variable-name-face ((((class color) (background dark)) (:foreground "green"))))
 '(font-lock-function-name-face ((((class color) (background dark)) (:foreground "LightSkyBlue"))))
 '(font-lock-builtin-face ((((class color) (background dark)) (:foreground "LightSkyBlue")))))

;; Options Menu Settings
;; =====================
(cond
 ((and (string-match "XEmacs" emacs-version)
       (boundp 'emacs-major-version)
       (or (and
            (= emacs-major-version 19)
            (>= emacs-minor-version 14))
           (= emacs-major-version 20))
       (fboundp 'load-options-file))
  (load-options-file "/home/sefl/.xemacs-options")))
;; ============================
;; End of Options Menu Settings


;; SEF

(autoload 'html-helper-mode "html-helper-mode" "Yay HTML" t)
(autoload 'c++-mode  "cc-mode" "C++ Editing Mode" t)
(autoload 'c-mode    "cc-mode" "C Editing Mode" t)
(autoload 'objc-mode "cc-mode" "Objective-C Editing Mode" t)
(autoload 'java-mode "cc-mode" "Java Editing Mode" t)
(autoload 'sgml-mode "psgml" "Major mode to edit SGML files." t)
(autoload 'xml-mode "psgml" "Major mode to edit XML files." t)

(setq auto-mode-alist
(append
'(("\\.C$"    . c++-mode)
  ("\\.H$"    . c++-mode)
  ("\\.cc$"   . c++-mode)
  ("\\.cpp$"  . c++-mode)
  ("\\.hh$"   . c++-mode)
  ("\\.c$"    . c-mode)
  ("\\.h$"    . c++-mode)
  ("\\.m$"    . objc-mode)
  ("\\.java$" . java-mode)
  ("\\.mak$"  . makefile-mode)
  ("\\.pl$"   . perl-mode)
  ("\\.perl$" . perl-mode)
;  ("\\.sh$"   . shell-script-mode)
;  ("\\.ksh$"  . shell-script-mode)
  ("\\.sh$"   . fundamental-mode)
  ("\\.ksh$"  . fundamental-mode)
  ("\\.htm$"  . html-helper-mode)
  ("\\.html$" . html-helper-mode)
  ("\\.css$" . html-helper-mode)
  ("\\.spr"   . lisp-mode)
  ("\\.xml"   . xml-mode)
 ) auto-mode-alist))



(add-hook 'c-mode-common-hook '(lambda () (c-toggle-auto-state -1)
				 (c-set-style "bsd")
				 ))

;; mouse wheel scrolling
;; from http://www.inria.fr/koala/colas/mouse-wheel-scroll


;; display file names all the time
(setq frame-title-format "%b") 


;; HTML mode support

(add-hook 'html-helper-load-hook '(lambda () (require 'html-font)))
(setq html-helper-do-write-file-hooks t)
(setq html-helper-build-new-buffer t)


;; Viper Stuff
(setq viper-mode t)
(require 'viper)

;; c mode settings
(setq c-tab-always-indent t)      ;; indent when TAB no matter where
(setq-default c-auto-newline nil)         ;; don't insert newlines for me

;; Gnus stuff
(setq user-mail-address "sef@akamai.com")
(defun auto-fill-hook ()
  (turn-on-auto-fill))

;;; syntax hiliting
(cond (window-system
       (require 'paren)
       (require 'font-lock)
       (transient-mark-mode t)
       (show-paren-mode t)
       (global-font-lock-mode t)
       (setq font-lock-maximum-decoration t)
))

(put 'upcase-region 'disabled nil)

(put 'downcase-region 'disabled nil)

(menu-bar-mode -1)


;; To see the font name corresponding to a font chosen using the 
;; font selection dialog, execute the following elisp code in the 
;; *scratch* buffer: 
;; (insert (prin1-to-string (w32-select-font))) 

;; (set-default-font "-*-Lucida Console-normal-r-*-*-12-112-96-96-c-*-iso8859-1")
(set-default-font "-outline-Lucida Console-normal-r-normal-normal-12-90-96-96-c-*-iso10646-1")

(set-background-color "black")
(set-foreground-color "white")
(set-cursor-color "green")
(set-face-foreground 'modeline "black")
(set-face-background 'modeline "gold")





;; CYGWIN INTEGRATION
;; FROM http://www.khngai.com/emacs/cygwin.php


(require 'cygwin-mount)
(cygwin-mount-activate)

(add-hook 'comint-output-filter-functions
    'shell-strip-ctrl-m nil t)
(add-hook 'comint-output-filter-functions
    'comint-watch-for-password-prompt nil t)
(setq explicit-shell-file-name "bash.exe")
;; For subprocesses invoked via the shell
;; (e.g., "shell -c command")
(setq shell-file-name explicit-shell-file-name)



;; Have "clear" work

(add-hook 'shell-mode-hook 'n-shell-mode-hook)
(defun n-shell-mode-hook ()
  "12Jan2002 - sailor, shell mode customizations."
  (local-set-key '[up] 'comint-previous-input)
  (local-set-key '[down] 'comint-next-input)
  (local-set-key '[(shift tab)] 'comint-next-matching-input-from-input)
  (setq comint-input-sender 'n-shell-simple-send)
  )

(defun n-shell-simple-send (proc command)
  "17Jan02 - sailor. Various commands pre-processing before sending to shell."
  (cond
   ;; Checking for clear command and execute it.
   ((string-match "^[ \t]*clear[ \t]*$" command)
    (comint-send-string proc "\n")
    (erase-buffer)
    )
   ;; Checking for man command and execute it.
   ((string-match "^[ \t]*man[ \t]*" command)
    (comint-send-string proc "\n")
    (setq command (replace-regexp-in-string "^[ \t]*man[ \t]*" "" command))
    (setq command (replace-regexp-in-string "[ \t]+$" "" command))
    ;;(message (format "command %s command" command))
    (funcall 'man command)
    )
   ;; Send other commands to the default handler.
   (t (comint-simple-send proc command))
   )
  )

; have error keys do next/previous in shell

(add-hook 'shell-mode-hook 'n-shell-mode-hook)
(defun n-shell-mode-hook ()
  "12Jan2002 - sailor, shell mode customizations."
  (local-set-key '[up] 'comint-previous-input)
  (local-set-key '[down] 'comint-next-input)
  (local-set-key '[(shift tab)] 'comint-next-matching-input-from-input)
  )


(load "~/emacs/sql-functions")

;; filladapt mode tries to fix hanging paragraphs, bullets, and such,
;; but I found it to be pretty slow
;;      - Sef 9/20/05
;;
(require 'filladapt)
(add-hook 'text-mode-hook 'turn-on-filladapt-mode)

;; from Kretch
(defun timestamp ()
  (interactive)
  (insert (format-time-string "%Y-%m-%d %H:%M%Z " 'nil 1))
  (insert (format-time-string "%H:%M%Z %s: ")))
(global-set-key "\M-t" 'timestamp)


;; Count the words in the entire document
(defun count-words-buffer ()
  "Count all the words in the buffer"
  (interactive)
  (count-words-region (point-min) (point-max) )
)
