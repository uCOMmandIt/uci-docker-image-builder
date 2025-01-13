#!/bin/bash
image_info () {
[[ $1 == "-k" ]] && key=$2 && shift 2
tag=$(image_name "$@")
# TODO try using --format to extract keys
# https://docs.docker.com/engine/reference/commandline/inspect/
info=$(docker image inspect $tag 2> /dev/null) || info=$(docker image inspect $1 2> /dev/null) || return 1
if [[ $key ]]; then
# echo  image: $tag, key:$key
echo $info | jq --arg k "$key" '.[] | .[$k]'
else
# quote to preserve newlines
echo "$info"
fi
}

image_exists () {
 image_info -k RepoTags "$@"
}

image_arch () {
 image_info -k Architecture "$@"
}

image_tags () {
 image_info -k RepoTags "$@"
}

image_id () {
 image_info -k Id "$@" | sed 's/.*\://' | sed 's/"//'
}

# if script was executed then call the function
(return 0 2>/dev/null) || image_info $@