#!/bin/bash

image_name () {

local tag; local efile; local suffix

# generate a full image name with tag
# $1 name, $2 user(or repo), $3 repo  

# [[ $# -lt 1 ]] && echo "image base name required" && exit 

declare OPTION; declare OPTARG; declare OPTIND
while getopts 'e:s:g:r:u:' OPTION; do
# echo processing: option:$OPTION argument:$OPTARG index:$OPTIND remaining:${@:$OPTIND}
case "$OPTION" in
e)
  efile=$OPTARG
  ;;  
u)
    RUSER=$OPTARG
;;  
g)
    TAG=$OPTARG
    ;;    
s)  # add -arm64 to image
    suffix=$OPTARG
    ;;      
*)  echo unknown image-name option -$OPTARG
    echo "USAGE: image_name <options> <name> <repo_user>"
    echo "available options:  -s <suffix>: add -<suffix> , -g: tag, -u: repo user, -e: env file"
;;
esac
done

shift $((OPTIND - 1))


source_env_file $efile

tag=$( echo $1 | cut -s -d ":" -f2)
TAG=${tag:-$TAG}
name=${1%:*}
shift

echo $(make_image_name $name $@)$([[ $suffix ]] && echo -$suffix):${TAG:-latest}
}

# if script was executed then call the function
(return 0 2>/dev/null) || image_name $@