#!/bin/bash
# Utility to list external command calls
set -o pipefail
set -e

typeset -a dependencies=('comm' 'jq' 'shfmt' 'mktemp' 'rm' 'sort')

typeset queryCallExpressions='[(.. | if type == "object" and has("Type") and .Type == "CallExpr" then .Args[0].Parts[0].Value else null end)] | map(select( . != null )) | unique | .[]'
typeset queryFunctionDeclarations='[(.. | if type == "object" and has("Type") and .Type == "FuncDecl" then .Name.Value else null end)] | map(select( . != null )) | unique | .[]'

typeset scriptName=$(basename "$0")
typeset syntaxTree=$(mktemp "/tmp/$scriptName-syntaxtree-XXX")
typeset externalAndBuiltinCommands=$(mktemp "/tmp/$scriptName-expr-XXX")
typeset callExpressionsFile=$(mktemp "/tmp/$scriptName-expr-XXX")
typeset functionDeclarationsFile=$(mktemp "/tmp/$scriptName-fn-dec-XXX")
typeset bashBuiltinFile=$(mktemp "/tmp/$scriptName-bn-XXX")

checkDependencies() {
    local _dep
    for _dep in "${dependencies[@]}"; do
        if ! command -v "$_dep" &> /dev/null; then
            echo "Missing dependency $_dep. Exiting..."
            exit 1
        fi
    done
}

checkArgs() {
    if [[ -z "$1" ]]; then
        echo "Missing file argument"
        exit 2
    fi
    if [[ ! -f "$1" ]]; then
        echo "$1 is not a file"
        exit 2
    fi
}

safeDelete() {
    [[ -f "$1" ]] && rm "$1"
}

cleanup() {
    safeDelete "$syntaxTree"
    safeDelete "$externalAndBuiltinCommands"
    safeDelete "$callExpressionsFile"
    safeDelete "$functionDeclarationsFile"
    safeDelete "$bashBuiltinFile"
}

main() {
    shfmt -tojson >"$syntaxTree" <"$1"

    jq --raw-output "$queryCallExpressions" "$syntaxTree" | sort >"$callExpressionsFile"
    jq --raw-output "$queryFunctionDeclarations" "$syntaxTree" | sort >"$functionDeclarationsFile"

    compgen -b >"$bashBuiltinFile"

    # External commands + builtins
    comm -32 "$callExpressionsFile" "$functionDeclarationsFile" >"$externalAndBuiltinCommands"
    comm -32 "$externalAndBuiltinCommands" "$bashBuiltinFile"

    # Dead functions
    # comm -31 "$callExpressionsFile" "$functionDeclarationsFile"
}

trap cleanup EXIT INT TERM
checkDependencies
checkArgs "$@"
main "$@"
