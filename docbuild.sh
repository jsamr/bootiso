#!/bin/sh
set -e
set -u

mandoc -Thtml -Ostyle=mandoc.css extra/man/bootiso.1 > docs/index.html
