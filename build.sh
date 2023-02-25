#!/bin/sh

DAEMON="debug-site"

build_website() {
    # all := forcefully update the whole site
    # *   := update only the changed files
    case "$1" in
        all) emacs -Q --script build-site.el --eval "(org-publish-all t)" ;;
        *  ) emacs -Q --script build-site.el --eval "(org-publish \"website\")" ;;
    esac \
        && echo "Build successful." \
        || echo "Something failed."
    return
}

fork_emacs() {
    # open a new emacsclient frame and fork the process. If no
    # emacsclient exists create one.
    emacsclient -s "${DAEMON}" -e '(message "I exist")' \
        || emacs  --daemon="${DAEMON}" -Q -l build-site-debug.el -l build-site.el \
        && setsid -f emacsclient -s "${DAEMON}" -c
    return
}

case "$1" in
    d|dbg) fork_emacs ;;
    a|all) build_website "all" ;;
    *    ) build_website ;;
esac

exit
