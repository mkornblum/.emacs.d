(defun consult-ripgrep-at-point ()
  (interactive)
  (let* ((default-directory (or (projectile-project-root) default-directory))
     (directory (read-directory-name "Search in directory: " default-directory))
     (thing (thing-at-point 'symbol)))
  (consult-ripgrep directory thing)))


(defun find-file-or-projectile ()
  (interactive)
  (if (projectile-project-p)
      (call-interactively #'projectile-find-file)
    (call-interactively #'find-file)))

(provide 'mk-functions)
