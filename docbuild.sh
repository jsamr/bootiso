#!/bin/sh
set -e
set -u

cat > docs/index.html << HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="mandoc.css" type="text/css" media="all"/>
  <title>BOOTISO(1)</title>
</head>
<body>
$(mandoc -Thtml -Otoc,fragment,man=https://manned.org/%N.%S extra/man/bootiso.1)
</body>
HTML
