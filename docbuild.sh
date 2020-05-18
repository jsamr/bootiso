#!/bin/sh
set -e
set -u

mandoc -Thtml -Ostyle=mandoc.css,toc,man=https://manned.org/%N.%S extra/man/bootiso.1 > docs/index.html
