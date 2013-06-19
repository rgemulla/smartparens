;;; smartparens-ruby.el --- Additional configuration for Ruby based modes.

;; Copyright (C) 2013 Jean-Louis Giordano

;; Author: Jean-Louis Giordano <jean-louis@jawaninja.com>
;; Maintainer: Matus Goljer <matus.goljer@gmail.com>
;; Created: 16 June 2013
;; Keywords: abbrev convenience editing
;; URL: https://github.com/Fuco1/smartparens

;; This file is not part of GNU Emacs.

;;; License:

;; This file is part of Smartparens.

;; Smartparens is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; Smartparens is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Smartparens.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file provides some additional configuration for Ruby based
;; modes.  To use it, simply add:
;;
;; (require 'smartparens-ruby)
;;
;; into your configuration.  You can use this in conjunction with the
;; default config or your own configuration.
;;
;; In order to get slurp and barf to work properly, you should
;; consider adding the following:
;;
;; (modify-syntax-entry ?@ "w" ruby-mode-syntax-table)
;; (modify-syntax-entry ?_ "w" ruby-mode-syntax-table)
;; (modify-syntax-entry ?! "w" ruby-mode-syntax-table)
;; (modify-syntax-entry ?? "w" ruby-mode-syntax-table)
;;
;; This will change the word boundaries, so that instance variables
;; and methods are treated as words.

;; If you have good ideas about what should be added please file an
;; issue on the github tracker.

;; For more info, see github readme at
;; https://github.com/Fuco1/smartparens

;;; Code:

(require 'smartparens)

(defun sp-ruby-block-post-handler (id action context)
  "Handler for ruby block-like inserts"
  (when (equal action 'insert)
    (save-excursion
      (newline)
      (indent-according-to-mode))
    (indent-according-to-mode)))

(defun sp-ruby-def-post-handler (id action context)
  "Handler for ruby def-like inserts"
  (when (equal action 'insert)
    (save-excursion
      (insert "x")
      (newline)
      (indent-according-to-mode))
    (kill-forward-chars 1)))

(defun sp-ruby-delete-indentation (&optional arg)
  "Better way of joining ruby lines"
  (delete-indentation arg)
  (when (save-excursion
          (backward-char 2)
          (or (looking-at-p ".[^:] [.([,]")
              (looking-at-p ".. ::")
              (looking-at-p ".[.@$] ")
              (looking-at-p ":: ")))
    (delete-char 1)))

(defun sp-ruby-pre-handler (id action context)
  "Handler for ruby slurp and barf"
  (when (equal action 'slurp-backward)
    (save-excursion
      (sp-forward-sexp)
      (sp-ruby-delete-indentation -1))
    (save-excursion
      (newline))
    (when (not (looking-back " "))
      (insert " ")))

  (when (equal action 'barf-backward)
    (save-excursion
      (sp-backward-sexp)
      (sp-ruby-delete-indentation))
    (save-excursion
      (newline))
    (when (not (looking-back " "))
      (insert " ")))

  (when (equal action 'slurp-forward)
    (save-excursion
      (sp-backward-sexp)
      (sp-ruby-delete-indentation))
    (newline))

  (when (equal action 'barf-forward)
    (save-excursion
      (sp-forward-sexp)
      (sp-ruby-delete-indentation -1))
    (newline)))

(defun sp-ruby-in-string-or-word-p (id action context)
  (or (sp-in-string-p id action context)
      (and (looking-back id)
           (not (looking-back (sp--strict-regexp-quote id))))))

(sp-with-modes '(ruby-mode)

  (sp-local-pair "do" "end"
                 :when '(("SPC" "RET" "<evil-ret>"))
                 :unless '(sp-ruby-in-string-or-word-p)
                 :actions '(insert)
                 :pre-handlers '(sp-ruby-pre-handler)
                 :post-handlers '(sp-ruby-block-post-handler))

  (sp-local-pair "{" "}"
                 :actions '(insert wrap)
                 :pre-handlers '(sp-ruby-pre-handler))

  (sp-local-pair "begin" "end"
                 :when '(("SPC" "RET" "<evil-ret>"))
                 :unless '(sp-ruby-in-string-or-word-p)
                 :actions '(insert)
                 :pre-handlers '(sp-ruby-pre-handler)
                 :post-handlers '(sp-ruby-block-post-handler))

  (sp-local-pair "def" "end"
                 :when '(("SPC" "RET" "<evil-ret>"))
                 :unless '(sp-ruby-in-string-or-word-p)
                 :actions '(insert)
                 :pre-handlers '(sp-ruby-pre-handler)
                 :post-handlers '(sp-ruby-def-post-handler))

  (sp-local-pair "class" "end"
                 :when '(("SPC" "RET" "<evil-ret>"))
                 :unless '(sp-ruby-in-string-or-word-p)
                 :actions '(insert)
                 :pre-handlers '(sp-ruby-pre-handler)
                 :post-handlers '(sp-ruby-def-post-handler))

  (sp-local-pair "module" "end"
                 :when '(("SPC" "RET" "<evil-ret>"))
                 :unless '(sp-ruby-in-string-or-word-p)
                 :actions '(insert)
                 :pre-handlers '(sp-ruby-pre-handler)
                 :post-handlers '(sp-ruby-def-post-handler))

  (sp-local-pair "if" "end"
                 :when '(("SPC" "RET" "<evil-ret>"))
                 :unless '(sp-ruby-in-string-or-word-p)
                 :actions '(insert)
                 :pre-handlers '(sp-ruby-pre-handler)
                 :post-handlers '(sp-ruby-def-post-handler))

  (sp-local-pair "unless" "end"
                 :when '(("SPC" "RET" "<evil-ret>"))
                 :unless '(sp-ruby-in-string-or-word-p)
                 :actions '(insert)
                 :pre-handlers '(sp-ruby-pre-handler)
                 :post-handlers '(sp-ruby-def-post-handler))
  )

(provide 'smartparens-ruby)

;;; smartparens-ruby.el ends here
