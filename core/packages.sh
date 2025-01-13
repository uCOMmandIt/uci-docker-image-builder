#!/bin/sh
echo "------------- CORE PACKAGE INSTALLATION ------------"
echo UPDATING PACKAGE REGISTRY....
. /opt/lib/verbose.lib
silence $UPDATE_PKGS 
echo .... DONE!
if [ -f ./packages/$LINUX_DISTRO ]; then
    echo INSTALLING $LINUX_DISTRO DISTRO SPECIFIC PACKAGES
    echo ....
    while IFS="" read -r pkg || [ -n "$pkg" ]; do 
    $INSTALL_PKGS $pkg
    done < ./packages/$LINUX_DISTRO
    echo "DONE INSTALLING $LINUX_DISTRO SPECIFIC PACKAGES"
fi
echo INSTALLING COMMON PACKAGES FOR ANY DISTRO
_pkgs=$(cat ./packages/common)
echo $_pkgs 
echo ....
silence $INSTALL_PKGS $_pkgs
echo "DONE INSTALLING COMMON PACKAGES"
echo "done ------------- CORE PACKAGE INSTALLATION ------------"
