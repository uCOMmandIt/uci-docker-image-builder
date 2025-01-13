#!/bin/bash
echo env
_url=https://raw.githubusercontent.com/KittyKatt/screenFetch/master/screenfetch-dev
wget --quiet -O $BIN_DIR/os-info $_url > /dev/null
if [[ -f $BIN_DIR/os-info ]]; then
    chmod +x $BIN_DIR/os-info
  else
    echo Failed to download 
    echo $_url
    echo info screen not available
fi
