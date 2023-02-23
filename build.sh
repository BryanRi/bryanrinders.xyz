#!/bin/sh

rename_dir() {
    if [ "${USER}" = "br" ]; then
        [ -d "website" ] && rm -rf website
        mv -f html website
    fi
}

build_website() {
    emacs -Q --script build-site.el --eval "$1" \
        && rename_dir \
        && echo "Build successful." \
        || echo "Something failed."
}

case "$1" in
    # debug mode, load emacs session loading only the website settings
    d|dbg) emacs -Q -l build-site.el --eval "(load-theme 'modus-vivendi)" ;;
    # build the entire website
    a|all) build_website '(org-publish-all t)' ;;
    # build the website by only updating changed files
    *  ) mv -f website html && build_website '(org-publish "website")' ;;
esac
