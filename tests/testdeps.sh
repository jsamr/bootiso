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
    safeDelete "$extraneousFile"
    safeDelete "$optionalCmdsFile"
    safeDelete "$requiredCmdsFile"
}

trap cleanup EXIT INT TERM

typeset scriptName=$(basename "$0")
typeset externalCallsFile=$(mktemp "/tmp/$scriptName-exter-XXX")
typeset declaredDepsFile=$(mktemp "/tmp/$scriptName-dec-XXX")
typeset extraneousCandidatesFile=$(mktemp "/tmp/$scriptName-extra-XXX")
typeset extraneousFile=$(mktemp "/tmp/$scriptName-extra-XXX")
typeset optionalCmdsFile=$(mktemp "/tmp/$scriptName-opt-XXX")
typeset requiredCmdsFile=$(mktemp "/tmp/$scriptName-req-XXX")
typeset -a missingCommands extraneousCommands
typeset ret=0
typeset sourceDir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

"$sourceDir/eshcalls.sh" "$sourceDir/../bootiso" > "$externalCallsFile"
"$sourceDir/extractdeps.sh" "$sourceDir/../bootiso" > "$declaredDepsFile"
sort < "$sourceDir/extraneous" > "$extraneousFile"
sort < "$sourceDir/optional" > "$optionalCmdsFile"

# List commands required and called but not declared
comm -32 "$externalCallsFile" "$optionalCmdsFile" > "$requiredCmdsFile"
mapfile -t missingCommands < <(comm -32 "$requiredCmdsFile" "$declaredDepsFile")

# List commands declared but not called
comm -32 "$declaredDepsFile" "$externalCallsFile" > "$extraneousCandidatesFile"
mapfile -t extraneousCommands < <(comm -32 "$extraneousCandidatesFile" "$extraneousFile")

if ((${#missingCommands[@]} > 0)); then
    ret=1
    echo "Found ${#missingCommands[@]} missing command declarations: ${missingCommands[*]}" >&2
fi

if ((${#extraneousCommands[@]} > 0)); then
    ret=1
    echo "Found ${#extraneousCommands[@]} extraneous command declarations: ${extraneousCommands[*]}" >&2
fi

exit $ret
