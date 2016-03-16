#!/bin/csh
setenv SSW /home/$USER/.local/ssw
setenv SSW_INSTR "gen vso ontology aia"
source $SSW/gen/setup/setup.ssw 

if ! $?EXEC then
    sswidl
else
    sswidl <<EOF
$EXEC
EOF
endif
