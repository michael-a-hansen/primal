#!/bin/bash

if [ $# -ne 0 ] && [ $# -ne 1 ] && [ $# -ne 2 ]; then
    echo " ==> ERROR in primal::configure_primal.sh - expected 0-2 arguments but received $#."
    exit 1
fi

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

executable=$(which pdflatex)
texdir=$(echo $executable | rev | cut -c 9- | rev)
echo "texdir=$texdir" >> $globalconfig

echo "texer=pdflatex" >> $globalconfig
echo "pdfinsrc=y" >> $globalconfig

# integrate with texshop if texshop exists - argument 1 is the TeXShop engine directory (e.g., /Users/mike/Library/TeXShop/Engines)
if [ $# -ne 0 ]; then
    if [ ! "$1" = "n" ]; then
        primalengine="$1/primal.engine"
        if [ -e $primalengine ]; then
            rm $primalengine
        fi
        ln -s "$primalbase/configured/write-project.sh" $primalengine
    fi
fi

# add aliases if specified and not present - to get aliases type the profile path (directory + file) as the second argument
if [ $# -ne 0 ] && [ $# -ne 1 ]; then
    if [ ! "$2" = "n" ]; then
        profile=$2
        if [ ! -e $primalengine ]; then
            echo " ==> ERROR in primal::configure_primal.sh - bash profile provided as 2nd argument does not exist!"
            exit 1
        fi
        if ! grep -q "PRIMAL ALIASES" "$profile" ; then
            echo "" >> $profile
            echo "" >> $profile
            echo "#vvvv PRIMAL ALIASES vvvv" >> $profile
            echo "alias pa='$primalbase/configured/assemble-project.sh' # primal assemble" >> $profile
            echo "alias pw='$primalbase/configured/write-project.sh' # primal write" >> $profile
            echo "#^^^^ PRIMAL ALIASES ^^^^" >> $profile
            echo "" >> $profile
        fi
    fi
fi
