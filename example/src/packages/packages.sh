#!/bin/bash
echo custom package installer script
echo "--------HERE IS THE ENVIRONMENT-------"
env
echo "--------------------"
echo "installing a fancy OS info script"
/bin/bash ./install-os-info.sh
echo now running the os-info script, a command in PATH at $BIN_DIR/os-info
os-info