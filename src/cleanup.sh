#!/bin/bash

mainname=$1
pdfinsrc=$2
outdir=$3
logdir=$4
tmpdir=$5
preremoval=$6
if [ -z $preremoval ]; then
    preremoval=0
fi

# get the extensions of temporaries
tmpexts=(aux bbl blg spl toc lot lof nlo ist nls ilg out glo gls snm nav acn glsdefs gsyi gsyo rsyi rsyo acn acr alg grk rmn)

if [ "$preremoval" = "0" ] ; then

    # output
    echo "-- primal: moving output to $outdir..."
    outexts=(ps dvi)
    for ext in "${outexts[@]}"
    do
        if [ -e "$mainname.$ext" ]; then
            mv "$mainname.$ext" "$outdir"
        fi
    done
    # handle pdf separately for integration with frontends (e.g. TeXShop)
    # frontends that display the document need the pdf to stay in the src directory
    if [ -e "$mainname.pdf" ]; then
        if [ "$pdfinsrc" = "y" ] || [ "$pdfinsrc" = "t" ] || [ "$pdfinsrc" = "yes" ] || [ "$pdfinsrc" = "true" ];then
            cp "$mainname.pdf" "$outdir"
        else
            mv "$mainname.pdf" "$outdir"
        fi
    fi
    echo "-- primal: done moving output to $outdir"

    # move log
    echo "-- primal: moving log to $logdir..."
    mv *.log $logdir
    echo "-- primal: done moving log to $logdir"


    echo "-- primal: moving temporaries to $tmpdir..."
    # move tmp
    for ext in "${tmpexts[@]}"
    do
        count=`ls -1 *.$ext 2>/dev/null | wc -l`
        echo "-- primal: $count .$ext files found"
        if [ $count != 0 ]; then
            echo " -- primal: .$ext files moved to $tmpdir"
            mv *.$ext $tmpdir
        fi
    done
    echo "-- primal: done moving temporaries to $tmpdir"

else

    echo "-- primal: purging temporaries..."
    for ext in "${tmpexts[@]}"
    do
        count=`ls -1 *.$ext 2>/dev/null | wc -l`
        echo " -- primal: $count .$ext files found"
        if [ $count != 0 ]; then
            echo " -- primal: .$ext files removed"
            rm *.$ext
        fi
    done
    echo "-- primal: done purging temporaries"

fi