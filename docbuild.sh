#!/bin/sh
set -e
set -u

mandoc -Thtml -Ostyle=mandoc.css bootiso.1 > docs/index.html
