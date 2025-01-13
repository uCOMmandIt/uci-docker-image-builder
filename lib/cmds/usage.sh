#!/bin/bash
usage() {  

local help; local force 
help=$(dirname "$(realpath "$BASH_SOURCE")")/help.md
[[ $1 == "c" ]] && force=cat
if [[ $(which glow) && ! $force ]]; then 
  glow $help 
else
  echo -e "\e[1;31mfor a better experience viewing this help file install glow, https://github.com/charmbracelet/glow\e[1;37m" 
 sed 's/`//g' < $help     
fi
  
} 