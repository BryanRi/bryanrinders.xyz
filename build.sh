#!/bin/sh

build_website() {
    emacs -Q --script build-site.el --eval "$1" \
        && echo "Build successful." \
        || echo "Something failed."
}

case "$1" in
    # debug mode, load emacs session loading only the website settings
    d|dbg) emacs -Q -l build-site.el -l build-site-debug.el ;;
    # build the entire website
    a|all) build_website '(org-publish-all t)' ;;
    # build the website by only updating changed files
    *  ) build_website '(org-publish "website")' ;;
esac
