#!/bin/bash

# starts a trail container with passed image with a bash prompt
# $1 image name, $2 user 
# user can be also prepended by using u option
# added tag is "latest" by default, use t option for alternate tag
# if p flag is used script will scrub any local image and attempt to download a published to docker image

try_container () {

  declare -A arch=( ["x86_64"]="" ["aarch64"]="-arm64")
  local mp;local cuser; local hmp; local vname; local prod; local priv
  local hostmp; local efile; local entrypoint; local evar
  local envf; local image; local options; local dry_run
  local build; local cmd; local script; local dcmd

  [[ $1 == "build" ]] && build=true && shift

  declare OPTION; declare OPTARG; declare OPTIND
  OPTIND=0
  while getopts "f:o:dpr:t:u:m:h:kv:e:i:c:s:b:y:" OPTION; do
  # echo processing: option:$OPTION argument:$OPTARG index:$OPTIND remaining:${@:$OPTIND}
  case "$OPTION" in
  y)
    entrypoint="--entrypoint $OPTARG"
  ;; 
  s)
    script="$OPTARG"
  ;; 
  e)
    efile=$OPTARG
  ;;  
  c)
    cmd=$OPTARG
  ;; 
  i)
    image="$OPTARG"
  ;; 
  f)
    envf="--env-file $OPTARG"
  ;; 
  b)
  # CUSTOM BASE IMAGE
    BASE_IMAGE=$OPTARG
  ;;
  d)
    dry_run="echo "
  ;; 
  u)
    cuser=$OPTARG
  ;;  
  k)
    keep=true
  ;; 
  m)
    mp=$OPTARG
  ;; 
  o)
    options="$OPTARG"
  ;; 
  h)
    hmp=$OPTARG
  ;; 
  v)
    evar="-e $OPTARG"
  ;;  
  t)
    TAG=$OPTARG
  ;;  
  p)
    priv=--privileged
  ;;           
  r)
      prod=$OPTARG
      ;;   
  *)  echo unknown run option -$OPTARG
      echo "USAGE: try <options>"
      echo "available options: -t <latest> custom tag "
  ;;
  esac
  done

  shift $((OPTIND - 1))

  image=${image:-$IMAGE_NAME}

  if [[ ! ( $build && $image ) ]]; then
    echo attempting to get image name from environment file
    source_env_file $efile
    image=$(make_image_name) 
  fi 

    if [[ ! $image ]]; then
    echo must supply an image name to try either via -i option
    echo or setting $IMAGE_NAME environment variable
    echo or from an environment file
    return 1
  fi

  if [[ $prod ]]; then 
      echo removing any local copy of image $image
      docker image rm $image
      host=prod
    else 
      host=local
      # TODO change this
      image=${image/:/${arch[$(uname -p)]}:}
  fi

  name=${image//\//-}
  image=$image:${TAG:-latest}

  echo trying image name: $image
  
  docker rm try-$name > /dev/null 2>&1
  if [[ $mp ]]; then 
    hostmp="${hmp:-${PWD}/mnt/$mp}"
    [[ ! $(isAbsPath $hostmp) ]] && hostmp=$PWD/$hostmp    
    vname="try-$name${dir//\//-}"
    echo $vname
    mkdir -p "$hostmp"
    dvcmd=$(   tr "\n" " " <<-END 
docker volume create --driver local 
--opt type=none 
--opt device=$hostmp 
--opt o=bind $vname 
END
)        
    if [[ $dry_run ]]; then
      echo dry run volume creation command
      echo $dvcmd
     else
      if ! $dvcmd > /dev/null; then
      echo error creating volume, aborting container try
      return 4
      fi
    fi
    echo directory $mp in container will be mounted at $hostmp
  fi

  if [[ ! $dry_run ]]; then
    echo starting container with image: $image, and name $name
    echo -e "at container prompt type 'exit' to exit from shell and remove trial container\n"
  fi  
  dcmd=$(   tr "\n" " " <<-END 
docker run -i $([[ ! $script ]] && echo -t) 
--rm $priv $evar $options ${entrypoint} ${envf}
$([[ $cuser ]] && echo --user $cuser) 
--name try-$name --hostname try-$host-$name 
$([[ $mp ]] && echo -v $vname:/$mp)
$image 
$([[ $script ]] && echo script || ${cmd} ) $@
END
  )
  if [[ $dry_run ]]; then
     echo dry run, docker command 
     echo "$([[ -f $script ]] && echo cat || echo "echo") "$script" | $dcmd"
   elif [[ $script ]]; then
   $([[ -f $script ]] && echo cat || echo "echo") "$script" | $dcmd
   else 
   echo -e "\n ----------------------------------------------"
   $dcmd 
   echo -e "\n ----------------------------------------------"
   echo -e "\ndone with session, removing containter try-$name"
    if [[ $mp ]] ; then
        echo removing volume $vname used for mapping  
        docker volume rm $vname > /dev/null
        if [[ $keep ]]; then
          echo mounted container directory $mp on host at $hostmp will not be removed
         else
          echo deleting directory at mountpoint $hostmp mapped to $mp in container
          echo "use option -k to keep this directory after exiting container" 
          echo "useful for testing scripts inside the container"
          if ! rm -rf $hostmp &>/dev/null; then
            echo unable to remove $hostmp.  Likely folders in container are not owned by same host user/ID $USER/$(id -u $USER)
            echo trying to remove with sudo.
            sudo rm -rf $hostmp
            if [[ -d $hostmp ]]; then
              echo unable to remove $hostmap, you must do it manually
            fi
          fi
        fi 
    fi
  fi  
    
}

# if script was executed then call the function
(return 0 2>/dev/null) || try_container "$@"