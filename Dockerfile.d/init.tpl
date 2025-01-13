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
quiet cat /opt/core_run.env
source /opt/core_run.env

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


# This is all done now at runtime via entrypoint
# UHID (user host ID) can be set in build environment.  
# by default it is 1000 which is usually the first created user on a system
# This can be reset at run time
# export UHID=${UHID:-1000}
# echo setting ownership and group of /opt and $VOLUME_DIRS to $UHID
# echo this can be set via UHID at build and runtime
# # if VOLUME_DIRS are set then those will also be set to same UHID
# echo chown -R -h $UHID:$UHID /opt $VOLUME_DIRS
# chown -R -h $UHID:$UHID /opt $VOLUME_DIRS

# # map host id now based on build environment
# if [[ $VOLUME_DIRS ]]; then
#     echo "*** creating and configuring volume directories ***"
#     echo $VOLUME_DIRS
#     mkdir -p $VOLUME_DIRS 
#     $BIN_DIR/map-host-id 
#     chmod -R g+rw $VOLUME_DIRS 
# fi

echo -e "\n *************  End Initialzation ************************" 