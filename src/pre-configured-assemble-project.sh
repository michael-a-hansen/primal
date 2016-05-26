#!/bin/bash

echo "-- primal: project assembly in progress..."

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
        echo "-- primal: error in assemble_project.sh! unexpected argument encounted."
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
    echo "-- primal: error in assemble_project.sh! Project name unspecified! Use --name=[...] to specify the name of the primal project. Stopping."
    exit 1
fi

if [ -d "$projectdir" ]; then
    replace="n"
    echo "-- primal: error in assemble_project.sh! a directory $projectdir already exists! Enter yes to replace the project, any other key to stop."
    read replace
    if [ "$replace" = "yes" ]; then
        rm -R "$projectdir"
        echo "primal: deleted $projectdir"
    else
        echo "primal: $projectdir exists and you did not say to overwrite - stopping."
        exit 1
    fi
fi

mkdir $projectdir

isInArray () {
    local element
    for element in "${@:2}"; do [[ "$element" == "$1" ]] && return 0; done
    return 1
}
supported=$(isInArray "$template" "${templates[@]}")
if [ ! supported ] && [ ! "$template" = "blank" ]; then
    echo "-- primal: error in assemble_project.sh! the specified template is not supported! Stopping."
    echo "  - Supported templates:"
    for t in "${templates[@]}"
    do
        echo "    - $t"
    done
    exit 1
fi

# parse global config and build project config
echo "-- primal: parsing global config..."
globalconfig="$primalbase/configured/primal-global-config"
texdir=$(awk -F\= '/^texdir=/{print $2}' $globalconfig)
texer=$(awk -F\= '/^texer=/{print $2}' $globalconfig)
primalbasedir=$(awk -F\= '/^primalbasedir=/{print $2}' $globalconfig)

if [ "$texdir" = "" ]; then
    echo "-- primal: error in assemble_project.sh! texdir was not provided in the project configuration."
    exit 1
fi
if [ "$texer" = "" ]; then
    echo "-- primal: error in assemble_project.sh! texer was not provided in the project configuration."
    exit 1
fi
if [ "$texer" != "pdflatex" ] && [ "$texer" != "latex" ]; then
    echo "-- primal: error in assemble_project.sh! the provided 'texer' did not match an acceptable value, pdflatex or latex."
    exit 1
fi
echo "-- primal: done parsing global config"

projectconfig="$projectdir/primal-project-config"

echo "-- primal: building local config..."
touch $projectconfig
echo "mainname=$projectdir" >> $projectconfig
echo "texdir=$texdir" >> $projectconfig
echo "primalbasedir=$primalbasedir" >> $projectconfig

if [ "$template" = "siam" ]; then
    texer="latex"
    echo "-- primal: specified template ($template) requires latex->dvi->pdf instead of pdflatex - builder is set to latex->dvi->pdf"
fi
echo "texer=$texer" >> $projectconfig
echo "pdfinsrc=y" >> $projectconfig
echo "tmpexts=aux,bbl,blg,spl,toc,lot,lof,nlo,ist,nls,ilg,out,glo,gls,snm,nav,acn,glsdefs,gsyi,gsyo,rsyi,rsyo,acn,acr,alg,grk,rmn" >> $projectconfig
echo "-- primal: done building local config"

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
echo "-- primal: project assembled in $projectdir"







