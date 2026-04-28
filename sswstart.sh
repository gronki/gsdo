#!/bin/tcsh

unsetenv IDL_STARTUP
unsetenv IDL_DIR
unsetenv IDL_PATH

setenv SSW /usr/local/ssw

# gen vso ontology aia goes_sxig12 goes_sxig13 chianti xray hessi spex
setenv SSW_INSTR "gen vso ontology aia chianti xray hessi spex"

source $SSW/gen/setup/setup.ssw /loud

sswidl
