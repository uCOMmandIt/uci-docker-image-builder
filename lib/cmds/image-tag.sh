#!/bin/bash

image_tag () {

local name; local remove; local id; local ntag; local tag

# tags an image 
#  -i <imagetag or id>  <newimagetag>
[[ $1 == "-r" ]] && remove=true && shift 1
if [[  $1 == "-i" ]]; then
 shift 1
 id=$1 
else
 id=$(image_id $1)
 name=$1
fi 
 [[ ! $(image_exists $id) ]] && { echo "no image $name $id nothing to tag"; return 1; } 
ntag=$2
if [[ $ntag ]];then
# echo making tag for $2  $(image_name $2)
[[ $ntag = :* ]] && ntag=$( echo $name | cut -d ":" -f1)$ntag
docker tag $id  $ntag
else
 [[ $remove ]] && docker rmi $name || echo to remove an image tag use -r
fi
image_tags $id
}

image_delete () {
  local id
  id=$(image_id $@)
  docker rmi -f $id
}




