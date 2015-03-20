#!/bin/bash

# this script builds and (re-)installs locally developed R-packages
# 'quantify'

TMPDIR=/tmp/tronador_packages
PKGDIR=/home/voellenk/tronador_workdir/tronador/R_packages

mkdir -p $TMPDIR 
cd $TMPDIR
# remove-p  packages from current work dir
rm *.tar.gz

# build quantify package
R --vanilla CMD build --compact-vignettes --resave-data=best $PKGDIR/quantify/pkg

# Remove and reinstall packages
R --vanilla CMD REMOVE quantify
R --vanilla --verbose CMD INSTALL quantify_*.tar.gz
