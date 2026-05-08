#!/bin/csh

setenv SSW "/opt/ssw"
setenv SSW_INSTR "gen vobs ontology aia"
source "$SSW/gen/setup/setup.ssw"

Xvfb :99 -screen 0 1920x1080x24 -ac  &
set XVFB_PROC=$!

sleep 3

setenv DISPLAY :99
setenv GSDO_DEVICE "X"

sswidl <<EOF
.r gsdo_setup
.r gsdo_start
EOF

kill $XVFB_PROC
