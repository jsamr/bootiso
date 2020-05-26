#!/bin/bash

typeset dependenciesFieldName='asrt_commandDependencies'

shfmt -tojson < "$1" | jq --raw-output '[(.. | if type == "object" and has("Type") and .Type == "DeclClause" and (.Args[1].Name.Value == "'"$dependenciesFieldName"'") then (.Args[1].Array.Elems)  else null end)] | map(select(. != null)) | flatten | map(.Value.Parts) | flatten |  map(.Value) | .[]' | sort
