
# UCOMMANDIT DOCKER BUILD SCRIPT

  Image Build Script: Creates one or more images using a target per the docker-bake.hcl file

## USAGE
  
  `udbuild <option switches> <image_name> <repo_user>`
  
   image_name and repo_name are optional and can also be set by environments NAME and RUSER. 
   RUSER can also be set by -u option if image_name is not provided.   

     `udbuild <subcommand> <subcommand option switches> <subcommand arguments>`
  
## SUBCOMMANDS:

   `try` - runs a trial container with image 
   
   `load_env_file <path>` -  loads an build environment file, useful aid for an external script
   
   `build_src <path>` - attempts to locate a valid build source directory
   
   `help,-help,--help <subcommand>` -  view this info or that of a subcommand

   `func <-l> <name> <arguments>` - gives direct access to build functions in build library build.lib, with 
   no name or arguments lists all available functions, use -l to see source for a particular function
   
   `source`  - view the source of this script
   
   `image` - image related subcommands 
      * `name` - generate name from environment/switches
      * `tag`  -  add a name (docker tag) to an existing image
      * `push` - push an image to a remote repository
      * `delete` - completely delete a local image
      * `info`  - with no subcommand show all info for image
          -  `arch`  - list machine architecture of image
          -  `exists` -  used mostly for scripting, determines if image exists locally
          -  `tags` - get the names (docker tags) of an image
          -S  `id` - gets the id of an image from its name (docker tag)

## BUILD OPTIONS

### setable ONLY via CLI switches

`-e <path>` : source an environment file.  By default will look for .env, in PWD.  If used will also try <path> and <path>.env if absolute or in PWD if not.  One could also preset UCI_BUILD_ENV_FILE before running udbuild, not recommended. 

`-h` show this help  

`-p` if running interactive suppress the build prompts  

`-n` use no-cache,  bust the cache and force rebuild the entire image, see `-f:REBUILD`

`-o` do not overwrite an existing image on build (default), instead move it to a temporary timestamp tag


### setable via CLI switches or via environment variable

   `-j : VERBOSE=true` -  show verbose information about the build, verbose is default for `dev` target

   `-a <path> : BUILD_ENV_FILE=<path>`- Use this environment file in the core build and use/append to any build.env at src/init/build.env.  If build.env exists in the PWD it will be used otherwise set the path here. 

   `-b <name> : BASE_IMAGE=<name>` - used in `FROM` in Dockerfile.  The default will be an official distro image (e.g.`ubuntu:latest`) based on `LINUX_DISTRO` and the default distro is alpine so if both `BASE_IMAGE` and `LINUX_DISTRO` are unset FROM will use `alpine:latest`

   `-c <cmd> : TRY_CMD=<cmd>` - a command to use in the try container, default is 'shell`
   

   `-f : REBUILD=init` - force rebuild of only the Dockerfile RUN initialize instruction, note: use `-n` to force rebuild of entire image
   
   `-g <tag> : TAG=<tag>` - tag following : in output image name (i.e.  REPO/USER/NAME:TAG), default: latest
   
     `-d : LINUX_DISTRO=<name>` - supported: alpine, debian, ubuntu, default: alpine; if base image set distro will be determined (and this ignored). Default is alpine
   
   `-i <path> : IMAGE_INFO=<path>` - path to file of information to be included in the image at `/opt/image.info` and visible via `image` command of the entrypoint.  Will over write any image.ifo file in src/init/image.info of the build sources
   
   `-r <repo> : REPO=<repo>` - set a remote private repository for pushing, default is docker hub
   
   `-s <path> : BUILD_SRC=<path>` - set the path to the build source directory, default is src/ in current or parent directory`

   `-t <target> : TARGET=<target>` - the valid build targets for `buildx bake` are `dev arm64 amd64 publish multi default`  default is `default`
   
   `-u <name> : RUSER=<name>` - the remote repository user name to prepend to the image name.  This will be needed for pushing to remote repositories like docker hub or a private repository (e.g. gitea)     

   `x <name> : IMAGE_PREFIX_NAME` - will add in front of the derived image name
   `z <name> : IMAGE_PREFIX_SUFFIX` - will add after the dervived image name (before any tag)

### setable ONLY via environment variable


  
## examples:

### commad line

### environment file
