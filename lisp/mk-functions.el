(defun consult-ripgrep-at-point ()
  (interactive)
  (consult-ripgrep (projectile-project-root) (thing-at-point 'symbol)))

(provide 'mk-functions)
