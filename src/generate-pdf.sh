#!/bin/bash

mainname=$1 # arg 1 is the name of the main tex file, no .extension
texer=$2    # arg 2 is the program to be used (default pdflatex)

if [ -z "$mainname" ]; then
    echo "-- primal: error in generate-pdf.sh! you must provide the name of the main tex file as the first argument (no .extension)"
    echo "build stopped"
    exit 1
fi

if [ -z "$texer" ]; then
    echo "-- primal: you provided no second argument, so pdflatex (path below) will be used to compile"
    which pdflatex
    texer="pdflatex"
fi

echo "-- primal: compilation in progress..."

texline="$texer -halt-on-error -file-line-error -shell-escape $mainname.tex"
indexline="makeglossaries $mainname"
bibtexline="find . -name '*.aux' -print0 | xargs -0 -n 1 bibtex"
eval $texline
eval $indexline
eval $texline
eval $bibtexline
eval $texline
eval $texline

if [ "$texer" = "latex" ]; then
    which dvips
    which ps2pdf
    dvips "$mainname.dvi"
    ps2pdf "$mainname.ps"
fi

echo "-- primal: compilation finished!"