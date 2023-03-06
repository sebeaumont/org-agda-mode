;;; org-agda-mode.el --- Major mode for working with literate Org Agda files
;;; -*- lexical-binding: t

;;; Commentary:

;; A Major mode for editing Agda code embedded in Org files (.lagda.org files.)
;; See the Agda manual for more information:
;; https://agda.readthedocs.io/en/v2.6.1/tools/literate-programming.html#literate-org

;;; Code:

(require 'polymode)
(require 'agda2-mode)

(defgroup org-agda-mode nil
  "Some org-agda-mode customisations."
  :group 'languages)

(defcustom use-agda-input t
  "Whether to use Agda input mode in non-Agda parts of the file."
  :group 'org-agda-mode
  :type 'boolean)

(define-hostmode poly-org-agda-hostmode
  :mode 'org-mode
  :keep-in-mode 'host)

(define-innermode poly-org-agda-innermode
  :mode 'agda2-mode
  :head-matcher "#\\+begin_src agda2"
  :tail-matcher "#\\+end_src"
  ;; Keep the code block wrappers in Org mode, so they can be folded, etc.
  :head-mode 'org-mode
  :tail-mode 'org-mode
                             
  ;; Disable font-lock-mode, which interferes with Agda annotations,
  ;; and undo the change to indent-line-function Polymode makes.
  :init-functions
  '((lambda (_) (font-lock-mode 0))
    (lambda (_) (setq indent-line-function #'indent-relative))))

(define-polymode org-agda-mode
  :hostmode 'poly-org-agda-hostmode
  :innermodes '(poly-org-agda-innermode)
  (setq-local org-src-fontify-natively t)
  (setq-local polymode-after-switch-buffer-hook
              (append '(after-switch-hook) polymode-after-switch-buffer-hook))
  (when use-agda-input (set-input-method "Agda")))

(defun after-switch-hook (_ new)
  "The after buffer switch hook run with NEW buffer."
  (when (bufferp new)
    (let ((new-mode (buffer-local-value 'major-mode new)))
      ;;(message "switch to: %s" new-mode)
      (cond ((eq new-mode 'agda2-mode) (agda2-mode-hook new))
            ((eq new-mode 'org-mode) (org-mode-hook new))))))
        
(defun org-mode-hook (buf)
  "Hook run after entering `org-mode` with BUF."
  (font-lock-update)
  (if (buffer-modified-p buf)
      (message "dirty-org")
    (message "clean-org")))

(defun agda2-mode-hook (buf)
  "Hook run after entering `agda2-mode` with BUF."
  (agda2-highlight-reload ))

         
(assq-delete-all 'background agda2-highlight-faces)

;;;###autoload
;;(add-to-list 'auto-mode-alist '("\\.lagda.org" . org-agda-mode))

(provide 'org-agda-mode)
;;; org-agda-mode.el ends here
