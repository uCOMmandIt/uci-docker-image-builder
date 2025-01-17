#!/bin/bash
%
    if [[ $REBUILD == "packages" ]]; then 
      echo "## Busting Cache, Forcing Rebuild $(date)"
    fi
%
echo "************* PACKAGE INSTALLATION ***********************"
if ! { [ "$VERBOSE" = "packages" ] || [ "$VERBOSE" = "all" ]; }; then unset VERBOSE; fi
source /opt/lib/verbose.lib 
export BUILDING=true
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
echo sourcing core-run.env
quiet cat /opt/core-run.env
source /opt/core-run.env
echo Distro is $LINUX_DISTRO
echo package installer command for this build: "$INSTALL_PKGS"
echo package update command for this build: "$UPDATE_PKGS"

if [[ -f ./repositories.sh ]]; then
   echo "---- Running a custom repository setup script repositories.sh -----"
   source ./repositories.sh
   echo "done ---- Running repository setup script repositories.sh -----"
  fi

list=$(ls *system.pkgs 2> /dev/null)
list+=" $(ls ./system/*.pkgs 2> /dev/null)"
quiet echo list of system package files to install: $list
for file in $list; do
  [ -f "$file" ] || break
  echo "----- Installing System Packages from $file ---------------"
  while IFS= read -r pkg || [ -n "$pkg" ]; do 
  echo installing: $pkg
  silence $INSTALL_PKGS $pkg
  done < ./$file
  echo "done ----- Installing System Packages from $file ---------------"
done

[[ -f $ENV_DIR/run.env ]] && echo "sourcing $ENV_DIR/run.env" && source $ENV_DIR/run.env  

if [[ -f ./packages.sh ]]; then
   echo "---- Running custom package installation script packages.sh -----"
   source ./packages.sh
   echo "done ---- Running package installation script packages.sh -----"
fi
# TODO run a package cache removal based on distro  
echo "********************************"