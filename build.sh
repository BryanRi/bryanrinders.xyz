#!/bin/sh
emacs -Q --script build-site.el

if [ "${USER}" = "br" ]; then
	rm -rf website
	mv -f html website
fi
