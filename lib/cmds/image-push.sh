#!/bin/bash

image_push () {

#tags an image and pushes it to a <custom private> repository
# if not reposity is given will use docker.io and push to hub.docker.com
# $1 name, $2 user(or repo), $3 repo  
local name; local tag; local user; local repo

declare OPTION; declare OPTARG; declare OPTIND
while getopts 'ae:pt:i:u:r:' OPTION; do
# echo processing: option:$OPTION argument:$OPTARG index:$OPTIND remaining:${@:$OPTIND}
case "$OPTION" in

e)
   if ! source_env_file $OPTARG; then return 2; fi
   ;;  
# a)
#   ARM=arm64
# ;;  
t)
 tag=$OPTARG
 ;;
u)
 user=$OPTARG
 ;;
i)
 name=$OPTARG
 ;; 
r) 
 rename=$OPTARG
;; 
p)  
  # pull image from dockerhub if not available
  PULL=true
    ;;  
*)  echo unknown run option -$OPTARG
    echo "USAGE: start <options>"
    echo "available options: -h pull from hub.docker.com if not available, -a  push arm64 image, -t <latest> custom tag "
;;
esac
done

shift $((OPTIND - 1))

# image tag
repo=${1:-$REPO}  
name=${name:-$IMAGE_NAME}
user=${user:-$RUSER}
tag=${tag:$TAG}

if [[ ! $repo ]]; then
 echo to push an image a repo MUST be passed or REPO be set
 echo aborting push
 return 1
fi

if [[ ! $name ]]; then
 echo no image name passed or IMAGE_NAME not set
 echo aborting push
 return 1
fi

# image_name=$([[ $ARM ]] && echo ${name//:/-arm64:} || echo $name)

source=$name:${TAG:-latest}

if ! docker images -q $source > /dev/null 2>&1; then 
    echo "no image $source available to push"
    [[ ! $PULL ]] && echo NOTE: use -p or set PULL=true to attempt to pull image from hub.docker.com
    if [[ $PULL ]]; then
        echo attempting to pull $source
        if ! docker pull $source > /dev/null 2>&1; then
            echo unable to pull $source from hub.docker.com
            platform=$([[ $ARM ]] && echo "--platform linux/$ARM")
            echo trying to pull $platform $source from hub.docker.com
            if ! docker pull $platform $source > /dev/null 2>&1; then
                echo unable to pull $platform $source, aborting
                exit 2
              else
              PULL=downloaded
            fi
          else
            PULL=downloaded  
        fi
    else
     exit 1    
    fi
fi

target=$repo/$([[ $user ]] && echo ${user}/)$([[ $rename ]] && echo ${rename} || echo $name):${tag:-latest}

echo pushing $source to $target

# can pre login to create authentication or use
if [[ $REPO_USERNAME ]]; then
 docker login -u="${REPO_USERNAME}" -p="${REPO_TOKEN}" ${REPO} 
fi 

docker tag $source $target
if ! docker images -q $target &> /dev/null ; then echo ERROR: unable to tag image for pushing; return 1; fi
if ! docker image push $target 1> /dev/null; then
echo ERROR: unable to push $source to $target
echo if the push had failed authorization you likely have never logged in
echo you need to run "docker login" or provide REPO_USERNAME REPO_TOKEN
echo see the help and readme
fi

if [[ $PULL == downloaded ]]; then
echo removing $source downloaded from hub.docker.com docker
docker image rm $source > /dev/null 2>&1
fi

echo removing tag $target
# image rm will only remove the tag
docker image rm "$target"
#  > /dev/null 2>&1

}

# if script was executed then call the function
(return 0 2>/dev/null) || image_push $@