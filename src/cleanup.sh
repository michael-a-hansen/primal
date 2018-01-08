#!/bin/bash

mainname=$1
pdfinsrc=$2
outdir=$3
logdir=$4
tmpdir=$5
tmpexts=$6
preremoval=$7
if [ -z $preremoval ]; then
    preremoval=0
fi

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
    find . -type f -name "*.log" -exec mv {} "$logdir" \;
    echo "-- primal: done moving log to $logdir"


    echo "-- primal: moving temporaries to $tmpdir..."
    # move tmp
    for ext in "${tmpexts[@]}"
    do
        count=`ls -1 *.$ext 2>/dev/null | wc -l`
        echo "-- primal: $count .$ext files found"
        if [ $count != 0 ]; then
            find . -type f -name "*.$ext" -exec mv {} "$tmpdir" \;
            echo " -- primal: .$ext files moved to $tmpdir"
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
            echo "-- primal: .$ext files removed"
            find . -type f -name "$.$ext" -exec rm {} \;
        fi
    done
    echo "-- primal: done purging temporaries"

fi