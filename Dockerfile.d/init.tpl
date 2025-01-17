#!/bin/bash
%
    if [[ $REBUILD == "init" ]]; then 
      echo "## Busting Cache, Forcing Rebuild $(date)"
    fi
%
echo "************* BUILD INITIALZATION ***********************"
if ! { [ "$VERBOSE" = "init" ] || [ "$VERBOSE" = "all" ]; }; then unset VERBOSE; fi
export BUILDING=true
export BUILD_DIR=/build
echo Distro is $LINUX_DISTRO
source /opt/lib/verbose.lib 

echo sourcing core-run.env
quiet cat /opt/core-run.env
source /opt/core-run.env

[[ -f ./build.env ]] && source ./build.env && echo loaded build.env at /init/build.env in source

if [[ -f ./init.sh ]]; then
    echo "### Running Script init.sh of $BUILD_NAME build source with ${SHELL:-/bin/bash} ####"
    quiet echo "----- build environment ------"
    quiet env
    quiet echo "----- env ------"   
    quiet echo "-------------------- init.sh ------------------------------"
    quiet cat ./init.sh    
    quiet echo "-------------------------------------------------------------"
    # init.sh must have shebang and be executable
    if ! ${SHELL:-/bin/bash} ./init.sh; then return 1; fi
    echo "############## Finished running init.sh build script #########################"
fi

echo -e "\n *************  End Initialzation ************************" 