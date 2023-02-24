(setq initial-buffer-choice (concat (getenv "MY_PROJECTS_DIR") "/website/build-site.el"))

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(menu-bar-mode -1)          ; Disable the menu bar

(global-display-line-numbers-mode t)

(load-theme 'modus-vivendi)

(defalias 'yes-or-no-p 'y-or-n-p)

(fido-mode 1)
