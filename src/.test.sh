#!/bin/bash

t=$1

if [ $t != "blank" ]; then
    echo "                                -------- PRIMAL TESTING --------"
    echo "                                         template: $t"
    echo "                                -------- PRIMAL TESTING --------"
    rm -R $name
    source $assemble --name=$name --template=$t
    cd "$name/src"
    source $write
    cd ..
    cd ..
fi