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
    emacsclient --socket-name="${DAEMON}" --eval '(message "I exist")' \
        || SHELL=/bin/bash \
               emacs  --daemon="${DAEMON}" --quick --load=build-site-debug.el --load=build-site.el \
        && emacsclient --socket-name="${DAEMON}" --no-wait --create-frame
    return
}

vc_root="$(git rev-parse --show-toplevel)"
cd "${vc_root}" || exit 1

case "$1" in
    d|dbg) fork_emacs ;;
    a|all) build_website "all" ;;
    *    ) build_website ;;
esac

exit
