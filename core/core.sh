#!/bin/bash
echo "------------- CORE INSTALLATION ------------"
export BUILDING=true
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
source /opt/core-run.env
if [[ -f ./build.env ]]; then
    echo sourcing a custom core build enviornment
    cat ./build.env
    echo "--------"
    source ./build.env 
fi
source $LIB_DIR/verbose.lib

echo appending pkg commands to core-run.env
echo appending sourcing of $ENV_DIR/run.env if it exists
cat <<ENV >> /opt/core-run.env
export INSTALL_PKGS="$INSTALL_PKGS"
export UPDATE_PKGS="$UPDATE_PKGS"
[ -f "\$ENV_DIR/run.env" ] && [ -z "\$BUILDING" ] && source \$ENV_DIR/run.env
ENV
quiet cat /opt/core-run.env
mkdir -p /etc/profile.d
echo creating login sourcing file for core-run.env in /etc/profile.d
echo "source /opt/core-run.env" > /etc/profile.d/01-core-run-env.sh
echo "source /opt/core-run.env" >> /etc/profile

# if UCI_SHELL is set then USER must be login user 
[[ $USER_PW ]] && export USER=${USER:-host}
if [[ $USER ]]; then
    $LIB_DIR/user-create
fi
[[ $UCI_SHELL ]] && $LIB_DIR/uci-shell
quiet ls -la /etc/profile.d
quiet cat /etc/profile

ls -la /opt
echo "done ------------- CORE INSTALLATION ------------"