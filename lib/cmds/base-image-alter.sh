#!/bin/bash

base_image_alter () {

  local efile; local dry_run
  
  declare OPTION; declare OPTARG; declare OPTIND
  OPTIND=0
  while getopts "de" OPTION; do
  # echo processing: option:$OPTION argument:$OPTARG index:$OPTIND remaining:${@:$OPTIND}
  case "$OPTION" in
  e)
    efile=$OPTARG
  ;;  
  d)
    dry_run="echo "
  ;; 
  *)  echo unknown base image alter option -$OPTARG
      echo "USAGE: base_image_alter <options>"
      echo "available options: "
  ;;
  esac
  done

  shift $((OPTIND - 1))

  BASE_IMAGE=${1:-$BASE_IMAGE}

  if [[ ! $BASE_IMAGE ]]; then
    echo attempting to getting base image name from environment file
    source_env_file $efile
    [[ ! $BASE_IMAGE ]] && BASE_IMAGE=$(get_default_distro_image)
  fi 

  [[ ! $BASE_IMAGE ]] && echo unable to determine base image && return 1

  echo $BASE_IMAGE will be altered with: $BASE_IMAGE_ALTER


}




