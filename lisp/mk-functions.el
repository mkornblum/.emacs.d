(defun consult-ripgrep-at-point ()
  (interactive)
  (consult-ripgrep (projectile-project-root) (thing-at-point 'symbol)))

(defun find-file-or-projectile ()
  (interactive)
  (if (projectile-project-p)
      (call-interactively #'projectile-find-file)
    (call-interactively #'find-file)))

(provide 'mk-functions)
