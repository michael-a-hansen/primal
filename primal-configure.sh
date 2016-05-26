#!/bin/bash

texshopdir="n"
profilepath="n"
defaulttexer="pdflatex"

# try to get a default texdir by finding pdflatex on the path
# primal will take whatever you give it with your path settings!
pdflatexexecutable=$(which pdflatex)
texdir=$(echo $pdflatexexecutable | rev | cut -c 9- | rev)


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
            echo "-- primal: error in primal_configure.sh! the provided 'default-texer' did not match an acceptable value, pdflatex or latex."
            exit 1
        fi
        shift
    ;;
        --texdir=*)
        texdir="${i#*=}"
        shift
    ;;
        *)
        echo "-- primal: error in primal_configure.sh! unexpected argument encounted."
        echo "  - Allowable arguments are:"
        echo "  --texshop=[]"
        echo "  --profile=[]"
        echo "  --default-texer=[]"
        echo "  --texdir=[]"
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
cp "src/generate-pdf.sh" "configured/generate-pdf.sh"
cp "src/cleanup.sh" "configured/cleanup.sh"

# build the global configuration script
globalconfig="configured/primal-global-config"
touch $globalconfig
echo "texdir=$texdir" >> $globalconfig
echo "texer=$defaulttexer" >> $globalconfig
echo "pdfinsrc=y" >> $globalconfig
echo "primalbasedir=$primalbase" >> $globalconfig

# integrate with texshop
if [ ! "$texshopdir" = "n" ]; then
    if [ ! -e $texshopdir ]; then
        echo "-- primal: error in primal_configure.sh! provided TeXShop engine folder does not exist!"
        exit 1
    fi
    primalengine="$texshopdir/primal.engine"
    if [ -e $primalengine ]; then
        rm $primalengine
    fi
    ln -s "$primalbase/configured/write-project.sh" $primalengine
fi

# configure tests
testdir="test"
if [ -d "$testdir" ]; then
    rm -R $testdir
fi
mkdir $testdir
testconfig="$testdir/primal-config"
touch $testconfig
echo "texdir=$texdir" >> $testconfig
echo "primalbasedir=$primalbase" >> $testconfig
cp "src/test.sh" $testdir
cp "src/runtests.sh" $testdir

# add aliases
if [ ! "$profilepath" = "n" ]; then
    if [ ! -e $profilepath ]; then
        echo "-- primal: error in primal_configure.sh! provided profile/aliases file does not exist!"
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

