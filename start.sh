#!/bin/bash

if [[ ! -f start.pro ]]
then
    cp start.default.pro start.pro
fi

./sswstart.sh <<EOF
.r setup
print,'Setup complete'
wait,1.
.r start
EOF
