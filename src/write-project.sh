#!/bin/bash

if [ $# -ne 0 ] && [ $# -ne 1 ]; then
    echo "-- primal: error in write_project.sh! expected 0 or 1 arguments but received $#."
    exit 1
fi

# parse project config file, check for errors
config="../primal-project-config"
mainname=$(awk -F\= '/^mainname=/{print $2}' $config)
texdir=$(awk -F\= '/^texdir=/{print $2}' $config)
texer=$(awk -F\= '/^texer=/{print $2}' $config)
pdfinsrc=$(awk -F\= '/^pdfinsrc=/{print $2}' $config)
primalbasedir=$(awk -F\= '/^primalbasedir=/{print $2}' $config)
tmpextsstr=$(awk -F\= '/^tmpexts=/{print $2}' $config)

echo "-- primal: parsing project configuration file"
echo "   -- mainname      = $mainname"
echo "   -- texdir        = $texdir"
echo "   -- texer         = $texer"
echo "   -- pdfinsrc      = $pdfinsrc"
echo "   -- primalbasedir = $primalbasedir"

if [ "$mainname" = "" ]; then
    echo "-- primal: error in write_project.sh! mainname was not provided in the project configuration."
    exit 1
fi
if [ "$texdir" = "" ]; then
    echo "-- primal: error in write_project.sh! texdir was not provided in the project configuration."
    exit 1
fi
if [ "$texer" = "" ]; then
    echo "-- primal: error in write_project.sh! texer was not provided in the project configuration."
    exit 1
fi
if [ "$texer" != "pdflatex" ] && [ "$texer" != "latex" ]; then
    echo "-- primal: error in write_project.sh! the provided 'texer' did not match the acceptable values, pdflatex or latex."
    exit 1
fi
if [ "$pdfinsrc" = "" ]; then
    echo "-- primal: error in write_project.sh! pdfinsrc was not provided in the project configuration."
    exit 1
fi
if [ "$primalbasedir" = "" ]; then
    echo "-- primal: error in write_project.sh! primalbasedir was not provided in the project configuration."
    exit 1
fi

if [ ! -f "$mainname.tex" ]; then
    echo "-- primal: error in write_project.sh! the main tex file, $mainname.tex, does not exist."
    echo "   - Be sure you are in the src directory of the project."
    echo "   - Perhaps you renamed your main tex file without telling primal."
    echo "   - If so, simply change the mainname entry in the primal_config file in the base directory of the project."
    echo "   - The current directory is $(pwd)"
    echo "   - tex files in the current directory:"
    echo ""
    ls | grep tex
    echo ""
    exit 1
fi


# set some directories, these must be relative to the primal project src directory
tmpdir="../tmp"
logdir="../log"
outdir="../output"

# build document
source "$primalbasedir/configured/generate-pdf.sh" "$mainname" "$texer"

# cleanup

# get the extensions of temporaries
IFS=',' read -r -a tmpexts <<< "$tmpextsstr"

source "$primalbasedir/configured/cleanup.sh" "$mainname" "$pdfinsrc" "$outdir" "$logdir" "$tmpdir" "$tmpexts"
