#!/bin/bash

set -e
set -o pipefail

safeDelete() {
    [[ -f "$1" ]] && rm "$1"
}

cleanup() {
    safeDelete "$externalCallsFile"
    safeDelete "$declaredDepsFile"
    safeDelete "$extraneousCandidatesFile"
}

trap cleanup EXIT INT TERM

typeset scriptName=$(basename "$0")
typeset externalCallsFile=$(mktemp "/tmp/$scriptName-exter-XXX")
typeset declaredDepsFile=$(mktemp "/tmp/$scriptName-dec-XXX")
typeset extraneousCandidatesFile=$(mktemp "/tmp/$scriptName-extra-XXX")
typeset -a missingCommands extraneousCommands
typeset ret=0
typeset sourceDir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

"$sourceDir/eshcalls.sh" "$sourceDir/../bootiso" > "$externalCallsFile"
"$sourceDir/extractdeps.sh" "$sourceDir/../bootiso" > "$declaredDepsFile"

# List commands called but not declared
mapfile -t missingCommands < <(comm -32 "$externalCallsFile" "$declaredDepsFile")

# List commands declared but not called
comm -32 "$declaredDepsFile" "$externalCallsFile" > "$extraneousCandidatesFile"

mapfile -t extraneousCommands < <(comm -32 "$extraneousCandidatesFile" "$sourceDir/whitelist")

if ((${#missingCommands[@]} > 0)); then
    ret=1
    echo "Found ${#missingCommands[@]} missing command declarations: ${missingCommands[*]}"
fi

if ((${#extraneousCommands[@]} > 0)); then
    ret=1
    echo "Found ${#extraneousCommands[@]} extraneous command declarations: ${extraneousCommands[*]}"
fi

exit $ret
