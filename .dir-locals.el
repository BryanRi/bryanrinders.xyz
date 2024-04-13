;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((eval . (setq projectile-project-compilation-cmd
					   (file-name-concat (projectile-project-root) "build.sh ")))))
 (org-mode . ((eval . (defun br/org-custom-id-get-create (&optional force)
                        "Create an ID for the current entry and return it.
If the entry already has an ID, just return it.
With optional argument FORCE, force the creation of a new ID."
                        (interactive "P")
                        (when force
                          (org-entry-put (point) "CUSTOM_ID" nil))
                        (br/org-custom-id-get (point) 'create)))

              (eval . (defun br/org-custom-id-new (&optional prefix)
                        "Create a CUSTOM_ID that looks similar to the headline it
represents. PREFIX will be prefixed to the CUSTOM_ID."
                        (let ((id
                               (replace-regexp-in-string ; remove pre/suffix dashes
                                "^-+\\|-+$" ""
                                (replace-regexp-in-string ; remove all special characters
                                 "\\$\\|&\\|+\\|,\\|/\\|:\\|;\\|\"\\|=\\|\\?\\|@\\|'\\|<\\|>\\|#\\|%\\|{\\|}\\||\\|\\\\\\|\\^\\|~\\|\\[\\|\\]\\|`"
                                 "" ;"---ni--oa---")
                                 (replace-regexp-in-string
                                  "\s+" "-" ;"--on io a-"))
                                  (substring-no-properties (org-get-heading t t t t)))))))
                          (concat (when prefix (concat prefix "-"))
                                  (downcase id)))
                        ))

              (eval . (defun br/org-custom-id-get (&optional pom create prefix)
                        "Get the ID property of the entry at point-or-marker POM.
If POM is nil, refer to the entry at point.
If the entry does not have an ID, the function returns nil.
However, when CREATE is non-nil, create an ID if none is present already.
PREFIX will be passed through to `org-id-new'.
In any case, the ID of the entry is returned."
                        (org-with-point-at pom
                          (let ((id (org-entry-get nil "CUSTOM_ID")))
                            (cond
                             ((and id (stringp id) (string-match "\\S-" id))
	                          id)
                             (create
	                          (let ((id (br/org-custom-id-new prefix)))
	                            (org-entry-put pom "CUSTOM_ID" id)
	                            (org-id-add-location id
			                                         (or org-id-overriding-file-name
				                                         (buffer-file-name (buffer-base-buffer))))
	                            id)))))))

              (eval . (defun br/org-add-ids-to-headlines-in-file ()
                        "Add the CUSTOM_ID property to all headlines in the current file
which do not already have one."
                        (interactive)
                        (org-map-entries (lambda () (br/org-custom-id-get (point) 'create)))))

              (eval . (add-hook 'before-save-hook
                                #'br/org-add-ids-to-headlines-in-file
                                nil
                                t)))))
