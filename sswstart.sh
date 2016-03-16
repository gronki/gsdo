#!/bin/csh
setenv SSW /usr/local/ssw
setenv SSW_INSTR "gen vso ontology aia"
source $SSW/gen/setup/setup.ssw /loud

if ! $?EXEC then
    sswidl
else
    sswidl <<EOF
$EXEC
EOF
endif
