#!/bin/bash

texshopdir="n"
profilepath="n"
defaulttexer="pdflatex"

# parse arguments
for i in "$@"
do
    case $i in
        --texshop=*)
        texshopdir="${i#*=}"
        shift
    ;;
        --profile=*)
        profilepath="${i#*=}"
        shift
    ;;
        --default-texer=*)
        defaulttexer="${i#*=}"
        if [ ! "$defaulttexer" = "pdflatex" ] && [ ! "$defaulttexer" = "latex" ]; then
            echo " ==> ERROR in primal::primal_configure.sh - the provided 'default-texer' did not match an acceptable value, pdflatex or latex."
            exit 1
        fi
        shift
    ;;
        *)
        echo " ==> ERROR in primal::primal_configure.sh - unexpected argument encounted."
        echo "  - Allowable arguments are:"
        echo "  --texshop=[]"
        echo "  --profile=[]"
        echo "  --default-texer=[]"
        exit 1
    ;;
    esac
done

if [ -d "configured" ]; then
    rm -R configured
fi

mkdir configured

# configure assemble script
primalbase=$(pwd)

cp "src/pre-configured-assemble-project.sh" "configured/assemble-project.sh"
sed -i .bak "s|configureprimalbasehere|$primalbase|" "configured/assemble-project.sh"

cp "src/write-project.sh" "configured/write-project.sh"

# build the global configuration script
globalconfig="configured/primal-global-config"
touch $globalconfig

pdflatexexecutable=$(which pdflatex)
texdir=$(echo $pdflatexexecutable | rev | cut -c 9- | rev)
echo "texdir=$texdir" >> $globalconfig

echo "texer=$defaulttexer" >> $globalconfig
echo "pdfinsrc=y" >> $globalconfig

# integrate with texshop
if [ ! "$texshopdir" = "n" ]; then
    if [ ! -e $texshopdir ]; then
        echo " ==> ERROR in primal::primal_configure.sh - provided TeXShop engine folder does not exist!"
        exit 1
    fi
    primalengine="$texshopdir/primal.engine"
    if [ -e $primalengine ]; then
        rm $primalengine
    fi
    ln -s "$primalbase/configured/write-project.sh" $primalengine
fi

# add aliases
if [ ! "$profilepath" = "n" ]; then
    if [ ! -e $profilepath ]; then
        echo " ==> ERROR in primal::primal_configure.sh - provided profile/aliases does not exist!"
        exit 1
    fi
    if ! grep -q "PRIMAL ALIASES" "$profilepath" ; then
        echo "" >> $profilepath
        echo "" >> $profilepath
        echo "#vvvv PRIMAL ALIASES vvvv" >> $profilepath
        echo "alias pa='$primalbase/configured/assemble-project.sh' # primal assemble" >> $profilepath
        echo "alias pw='$primalbase/configured/write-project.sh' # primal write" >> $profilepath
        echo "#^^^^ PRIMAL ALIASES ^^^^" >> $profilepath
        echo "" >> $profilepath
    fi
fi
