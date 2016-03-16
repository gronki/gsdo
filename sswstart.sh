#!/bin/csh
setenv SSW /usr/local/ssw
# setenv SSW_INSTR "gen vso ontology aia"
# often used: gen vso ontology aia goes_sxig12 goes_sxig13 chianti xray hessi spex
source $SSW/gen/setup/setup.ssw /loud

if ! $?EXEC then
    sswidl
else
    sswidl <<EOF
$EXEC
EOF
endif
