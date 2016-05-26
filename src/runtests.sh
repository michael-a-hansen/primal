#!/bin/bash
#
# this file iterates over every non-blank template in primal, assembles a project, and writes it.
#
# success is counted if the project is assembled and a PDF is built
#


config="primal-config"
primalbasedir=$(awk -F\= '/^primalbasedir=/{print $2}' $config)

configureddir="$primalbasedir/configured"
assemble="$configureddir/assemble-project.sh"
write="$configureddir/write-project.sh"

name="test"

templates=($(ls "$primalbasedir/templates"))

total=0
pass=0
failing=""

for t in "${templates[@]}"
do
    total=$((total+1))
    if source test.sh $t ; then
        if [ -e "$name/output/$name.pdf" ]; then
            pass=$((pass+1))
        else
            failing="$failing $t"
        fi
    else
        failing="$failing $t"
    fi
done

echo ""
echo ""
echo "---------------------------------------"
echo "-- primal: $pass of $total tests passed"
echo "---------------------------------------"
echo ""
if [ "$pass" != "$total" ]; then
    echo "-- primal: failed templates: $failing"
    echo ""
    echo "---------------------------------------"
fi
echo ""
echo ""
echo ""