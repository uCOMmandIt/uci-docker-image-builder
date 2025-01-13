#!/bin/sh
%
    if [ "$REBUILD" = "core" ]; then 
      echo "# Busting Cache, Forcing Rebuild starting at core RUN "
      echo # $(date)
    fi
%
if ! { [ "$VERBOSE" = "core" ] || [ "$VERBOSE" = "all" ]; }; then unset VERBOSE; fi

echo "**************************************" 
echo "****** Building UCI Image Core ******" 


echo copying core rootfs to image
/bin/cp -R -f -p rootfs/. /
. /opt/lib/verbose.lib 

quiet env
quiet echo core build directory
quiet pwd
quiet ls -la
quiet echo "--------------------------------------"
. /opt/lib/distro.lib
if valid_distro; then
echo distro $LINUX_DISTRO was validated...continuing
set_distro
/bin/sh ./packages.sh
/bin/bash -l ./core.sh
if [ -f ./custom/run ]; then
  echo custom directory exists with run file inside
  cd ./custom || exit
  echo sourcing that run file now
  /bin/bash -l ./run
  cd .. 
fi
echo 
echo "*************  End UCI CORE build ********************" 
else
echo !!! FATAL ERROR: distro of base image $BASE_IMAGE does not match linux distro $LINUX_DISTRO !!!
exit 1
fi
