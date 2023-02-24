;; Source:
;; - https://www.youtube.com/watch?v=AfkrzFodoNw
;; - https://systemcrafters.net/publishing-websites-with-org-mode/building-the-site/

;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))


;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))


;; Install dependencies
(package-install 'htmlize)


;; Load the publishing system
(require 'ox-publish)

;; move the timestamps directory when running this script on my
;; personal machine
(setq org-publish-timestamp-directory
	  (let ((my-project-dir (getenv "MY_PROJECTS_DIR")))
		(if my-project-dir
			(concat my-project-dir "/website/.org-timestamps/")
		  "~/.org-timestamps/")))


;; load some programming languages for syntax highlighting
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (shell . t)
   (python . t)))


;; hardcoded html definitions for the navigation bar and footer
(defvar html-head-css
  "<link rel='stylesheet' href='/website/css/default.css' />
<link rel='stylesheet' href='/website/css/source-code.css' />")

(defvar nav-bar
  "<h1 id='site-name'>Bryan Rinders</h1>
<div id='menu'>
  <a href='/website/'>Home</a>
  <a href='/website/ctf-index.html'>CTF WriteUps</a>
  <a href='/website/emacs-index.html'>Emacs</a>
  <a href='/website/linux-index.html'>Linux Tutorials</a>
  <a href='https://gitlab.com/bryos/dotfiles' target='_blank'>Dotfiles</a>
  <a href='/website/other-index.html'>Other</a>
  <span class='right'>
    <a href='/website/sitemap.html'>Sitemap</a>
  </span>
</div>
<br><hr>")

(defvar footer
  "<br><hr/>
<footer>
  <div class='copyright-container'>
    <div class='copyright'>
      Copyright &copy; 2022-2023 Bryan Rinders some rights reserved
      <br><br>
      This page is available under a
      <a rel='license' href='http://creativecommons.org/licenses/by/4.0/'>
        CC-BY 4.0
      </a> licence.
    </div>
  </div>
  <br>
  <div class='generated'>
    Created with %c on <a href='https://www.gnu.org'>GNU</a>/<a href='https://www.kernel.org/'>Linux</a>
  </div>
</footer>")


;; Defining a custom face
;; that will define my shell prompt
(defface br-prompt-face '() "Face to highlight the shell prompt in code blocks")

;; Everytime the shell prompt appears,
;; Emacs applies the br-prompt-face to display it
(add-hook 'prog-mode-hook
          (lambda ()
            (font-lock-add-keywords nil
                                    '(("\\(^\\[?[[:alnum:]]+@[^\\$]*\\$\\)" 1
                                       'br-prompt-face t)))))


;; Configurations for the sitemap
(defun br/org-sitemap-date-entry-format (entry style project)
  "Format ENTRY in org-publish PROJECT Sitemap format ENTRY ENTRY STYLE format that includes date."
  (let ((filename (org-publish-find-title entry project)))
    (if (= (length filename) 0)
        (format "*%s*" entry)
      (format "{{{timestamp(%s)}}} [[./%s/%s][%s]]"
      ;(format "{{{timestamp(%s)}}} [[./%s][%s]]"
              (format-time-string "%Y-%m-%d"
                                  (org-publish-find-date entry project))
              (car project)
              entry
              filename))))

(setq org-export-global-macros
      '(("timestamp" . "@@html:<span class=\"timestamp\">[$1]</span>@@")))


;; Customize the HTML output
(setq org-html-validation-link            nil   ;; Don't show validation link
      org-html-head-include-scripts       nil   ;; Use our own scripts
      org-html-head-include-default-style nil   ;; Use our own styles
      org-src-fontify-natively            t
      org-html-htmlize-output-type        'css  ;; use css for syntax highlighting code blocks
      org-html-head                       html-head-css
	  org-export-with-sub-superscripts    '{}    ;; sub/superscripts must be surrounded with {}
      )

(defun br/define-website-component(id)
  "Create a list of all the settings for the website component ID."
  (list id
        :recursive             t
        :base-directory        (concat "./org/" id)
        :publishing-function   'org-html-publish-to-html
        :publishing-directory  (concat "./website/" id)
        :auto-sitemap          t
        :sitemap-filename      (concat id "-sitemap.org")
        :sitemap-title         nil
        :sitemap-style         'list
        :sitemap-sort-folders  'ignore
        :sitemap-sort-files    'anti-chronologically
        :sitemap-format-entry  'br/org-sitemap-date-entry-format
        :with-author           nil
        :with-creator          t
        :with-toc              1
        :section-numbers       t
        :html-preamble         nav-bar
        :html-postamble        footer
        :htmlized-source       t
        :time-stamp-file       nil))

;; Define the publishing project
(setq org-publish-project-alist
      (list
        (list "css"
              :base-directory       "./org/css"
              :base-extension       "css"
              :recursive            nil
              :publishing-directory "./website/css"
              :publishing-function  'org-publish-attachment)
        (list "home"                ;; unique string that identifies the project/website
              :recursive            nil
              :base-directory       "./org"
              :publishing-function  'org-html-publish-to-html
              :publishing-directory "./website"
              :with-author          nil         ;; Don't include author name
              :with-title           nil
              :with-creator         t           ;; Include Emacs and Org versions in footer
              :with-toc             nil         ;; Include a table of contents
              :section-numbers      nil         ;; Don't include section numbers
              :html-preamble        nav-bar
              :html-postamble       footer
              :time-stamp-file      nil)        ;; Don't include time stamp in file
        (br/define-website-component "ctf")
        (br/define-website-component "emacs")
        (br/define-website-component "linux")
        (br/define-website-component "other")
        (list "website" :components '("css" "ctf" "emacs" "linux" "other" "home"))))


;; Generate the site output
;(org-publish "blog")  ;; publish only those files that are modified/new
;(org-publish-all t)   ;; regenerates every html page, consider only updating a single one
