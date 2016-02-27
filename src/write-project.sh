#!/bin/bash

if [ $# -ne 0 ] && [ $# -ne 1 ]; then
    echo " ==> ERROR in primal::write_project.sh - expected 0 or 1 arguments but received $#."
    exit 1
fi

# parse project config file, check for errors
config="../primal-project-config"
mainname=$(awk -F\= '/^mainname=/{print $2}' $config)
texdir=$(awk -F\= '/^texdir=/{print $2}' $config)
texer=$(awk -F\= '/^texer=/{print $2}' $config)
pdfinsrc=$(awk -F\= '/^pdfinsrc=/{print $2}' $config)

echo " - Parsing primal project configuration file"
echo "   -- mainname = $mainname"
echo "   -- texdir = $texdir"
echo "   -- texer = $texer"
echo "   -- pdfinsrc = $pdfinsrc"

if [ "$mainname" = "" ]; then
    echo " ==> ERROR in primal::write_project.sh - mainname was not provided in the project configuration."
    exit 1
fi
if [ "$texdir" = "" ]; then
    echo " ==> ERROR in primal::write_project.sh - texdir was not provided in the project configuration."
    exit 1
fi
if [ "$texer" = "" ]; then
    echo " ==> ERROR in primal::write_project.sh - texer was not provided in the project configuration."
    exit 1
fi
if [ "$texer" != "pdflatex" ] && [ "$texer" != "latex" ]; then
    echo " ==> ERROR in primal::write_project.sh - the provided 'texer' did not match the acceptable values, pdflatex or latex."
    exit 1
fi
if [ "$pdfinsrc" = "" ]; then
    echo " ==> ERROR in primal::write_project.sh - pdfinsrc was not provided in the project configuration."
    exit 1
fi

if [ ! -f "$mainname.tex" ]; then
    echo " ==> ERROR in primal::write_project.sh - the main tex file, $mainname.tex, does not exist."
    echo "   - Be sure you are in the src directory of the project."
    echo "   - The current directory is $(pwd)"
    echo "   - tex files in the current directory:"
    echo ""
    ls | grep tex
    echo ""
    exit 1
fi


# these directories must be relative to the primal project src directory
tmpdir="../tmp"
logdir="../log"
outdir="../output"

# build document
texoptions="-interaction nonstopmode -halt-on-error -file-line-error -shell-escape"
texline="$texdir/$texer $buildoptions $mainname.tex"
indexline="$texdir/makeindex $mainname.nlo -s nomencl.ist -o $mainname.nls"
bibtexline="find . -name '*.aux' -print0 | xargs -0 -n 1 $texdir/bibtex"
eval $texline
eval $indexline
eval $compileline
eval $bibtexline
eval $compileline
eval $compileline

if [ "$texer" = "latex" ]; then
    dvips "$mainname.dvi"
    ps2pdf "$mainname.ps"
fi

# handle failure


# copy output
outexts=(ps dvi) # handle pdf separately for integration with frontends (e.g. TeXShop)
for ext in "${outexts[@]}"
do
    if [ -e "$mainname.$ext" ]; then
        mv "$mainname.$ext" "$outdir"
    fi
done
if [ -e "$mainname.pdf" ]; then
    if [ "$pdfinsrc" = "y" ] || [ "$pdfinsrc" = "t" ] || [ "$pdfinsrc" = "yes" ] || [ "$pdfinsrc" = "true" ];then
        cp "$mainname.pdf" "$outdir"
    else
        mv "$mainname.pdf" "$outdir"
    fi
fi

# move log
mv *.log $logdir

# move temporaries
tmpexts=(aux bbl blg spl toc lot lof nlo ist nls ilg out)
for ext in "${tmpexts[@]}"
do
    count=`ls -1 *.$ext 2>/dev/null | wc -l`
    if [ $count != 0 ]; then
        mv *.$ext $tmpdir
    fi
done