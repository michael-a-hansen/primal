#!/bin/bash

projectdir="unspecified"

if [ $# -eq 0 ]; then
    echo " ==> ERROR in primal::assemble_project.sh - Project name unspecified! Use --name=[...] to specify the name of the primal project. Stopping."
    exit 1
fi

# parse arguments
for i in "$@"
do
    case $i in
        --name=*)
        projectdir="${i#*=}"
        shift
    ;;
        *)
        echo " ==> ERROR in primal::primal_assemble.sh - unexpected argument encounted."
        echo "  - Allowable arguments are:"
        echo "  --name=[]"
        echo "  --"
        exit 1
    ;;
    esac
done

if [ "$projectdir" = "unspecified" ]; then
    echo " ==> ERROR in primal::assemble_project.sh - Project name unspecified! Use --name=[...] to specify the name of the primal project. Stopping."
    exit 1
fi

if [ -d "$projectdir" ]; then
    echo " ==> ERROR in primal::assemble_project.sh - a directory $projectdir already exists! Stopping."
    exit 1
fi

mkdir $projectdir

primalbase="configureprimalbasehere" # configuration sets this variable

# parse global config and build project config
globalconfig="$primalbase/configured/primal-global-config"
texdir=$(awk -F\= '/^texdir=/{print $2}' $globalconfig)
texer=$(awk -F\= '/^texer=/{print $2}' $globalconfig)

if [ "$texdir" = "" ]; then
    echo " ==> ERROR in primal::assemble_project.sh - texdir was not provided in the project configuration."
    exit 1
fi
if [ "$texer" = "" ]; then
    echo " ==> ERROR in primal::assemble_project.sh - texer was not provided in the project configuration."
    exit 1
fi
if [ "$texer" != "pdflatex" ] && [ "$texer" != "latex" ]; then
    echo " ==> ERROR in primal::write_project.sh - the provided 'texer' did not match an acceptable value, pdflatex or latex."
    exit 1
fi

projectconfig="$projectdir/primal-project-config"

touch $projectconfig
echo "mainname=$projectdir" >> $projectconfig
echo "texdir=$texdir" >> $projectconfig
echo "texer=$texer" >> $projectconfig
echo "pdfinsrc=y" >> $projectconfig

# build project directories
mkdir "$projectdir/src"
mkdir "$projectdir/output"
mkdir "$projectdir/log"
mkdir "$projectdir/tmp"

# add templates
touch "$projectdir/src/$projectdir.tex"

# done
echo "- Project assembled in $projectdir"