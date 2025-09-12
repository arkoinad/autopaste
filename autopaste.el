;;; autopaste.el --- Short description -*- lexical-binding: t; -*-

;; Author: Abhinav Gopalakrishnan <arkoinad@gmail.com>
;; Maintainer: Abhinav <arkoinad@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Homepage: https://github.com/arkoinad/autopaste
;; Keywords: convenience,autopaste,macos
;; Author: Abhinav
;; FileName: autopaste.el


;;; Commentary:
;; This package provides a simple way to poll the macOS clipboard
;; and automatically insert new clipboard contents into the current buffer.
;;
;; Usage:
;;
;;   (require 'autopaste)
;;   (start-macos-clipboard-listener 2) ;; poll every 2 seconds
;;
;; Stop the listener with:
;;
;;   (stop-macos-clipboard-listener)
;;
;; You can customize how and where the clipboard content is inserted
;; by editing `macos-clipboard-check-and-paste`.



(defvar macos-clipboard-last ""
  "Holds the last known value of the macOS clipboard.")

(defvar macos-clipboard-poll-timer nil
  "Timer for polling the macOS clipboard.")

(defun macos-clipboard-get ()
  "Get the current content of the macOS clipboard."
  (shell-command-to-string "pbpaste"))

(defun macos-clipboard-check-and-paste ()
  "Check the macOS clipboard and insert new content if it has changed."
  (let ((current (macos-clipboard-get)))
    (unless (string= current macos-clipboard-last)
      (setq macos-clipboard-last current)
      ;; Insert into current buffer at point (optional: change target)
      ;;(with-current-buffer (get-buffer-create "*Clipboard-Paste*")
      (with-current-buffer (current-buffer)
        (goto-char (point-max)) ;; point if you want to paste in the current point
	(insert "* ") ;;org header remove if you don't use org
	(insert current "\n")))))

;;;###autoload
(defun start-macos-clipboard-listener (&optional interval)
  "Start polling the macOS clipboard every 'x' seconds.
Default interval is 1 second."
  (interactive (list (read-number "nPolling interval (seconds):" 1)))
  (setq interval (or interval 1))
  (when macos-clipboard-poll-timer
    (cancel-timer macos-clipboard-poll-timer))
  (setq macos-clipboard-last (macos-clipboard-get))
  (setq macos-clipboard-poll-timer
        (run-at-time t interval #'macos-clipboard-check-and-paste))
  (message "Started macOS clipboard listener every %s second(s)" interval))

;;;###autoload
(defun stop-macos-clipboard-listener ()
  "Stop polling the macOS clipboard."
  (interactive)
  (when macos-clipboard-poll-timer
    (cancel-timer macos-clipboard-poll-timer)
    (setq macos-clipboard-poll-timer nil)
    (message "Stopped macOS clipboard listener.")))


(provide 'autopaste)

;; autopaste.el ends
