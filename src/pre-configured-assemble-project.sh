#!/bin/bash

projectdir="unspecified"
template="blank"
help="noshow"

displayArgs () {
echo "  - Supported arguments:"
echo "    --help        : display arguments and templates"
echo "    --name=[]     : set project name - REQUIRED to make a project"
echo "    --template=[] : choose a project template - in absence a blank tex file is created in project/src"
}

# parse arguments
for i in "$@"
do
    case $i in
        --name=*)
        projectdir="${i#*=}"
        shift
;;
        --template=*)
        template="${i#*=}"
        shift
;;
        --help*)
        help="show"
        shift
;;
        *)
        echo " ==> ERROR in primal::primal_assemble.sh - unexpected argument encounted."
        displayArgs
        exit 1
;;
    esac
done

primalbase="configureprimalbasehere" # configuration sets this variable

templates=($(ls "$primalbase/templates"))

if [ "$help" = "show" ]; then
    displayArgs
    echo ""
    echo "  - Supported templates:"
    for t in "${templates[@]}"
    do
        echo "    - $t"
    done
    exit 1
fi

if [ "$projectdir" = "unspecified" ]; then
    echo " ==> ERROR in primal::assemble_project.sh - Project name unspecified! Use --name=[...] to specify the name of the primal project. Stopping."
    exit 1
fi

if [ -d "$projectdir" ]; then
    echo " ==> ERROR in primal::assemble_project.sh - a directory $projectdir already exists! Stopping."
    exit 1
fi

mkdir $projectdir

isInArray () {
    local element
    for element in "${@:2}"; do [[ "$element" == "$1" ]] && return 0; done
    return 1
}
supported=$(isInArray "$template" "${templates[@]}")
if [ ! supported ] && [ ! "$template" = "blank" ]; then
    echo " ==> ERROR in primal::assemble_project.sh - the specified template is not supported! Stopping."
    echo "  - Supported templates:"
    for t in "${templates[@]}"
    do
        echo "    - $t"
    done
    exit 1
fi

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

if [ "$template" = "siam" ]; then
    texer="latex"
fi
echo "texer=$texer" >> $projectconfig
echo "pdfinsrc=y" >> $projectconfig

# build project directories
mkdir "$projectdir/src"
mkdir "$projectdir/output"
mkdir "$projectdir/log"
mkdir "$projectdir/tmp"

# add templates
if [ "$template" = "blank" ]; then
    touch "$projectdir/src/$projectdir.tex"
else
    cp "$primalbase/templates/$template/"* "$projectdir/src"
    mv "$projectdir/src/main.tex" "$projectdir/src/$projectdir.tex"
fi


# done
echo "- Project assembled in $projectdir"







