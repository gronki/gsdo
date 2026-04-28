#!/bin/bash

./sswstart.sh <<EOF
.r setup
print,'Setup complete'
wait,1.
.r start
EOF 

