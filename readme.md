# UCI Docker Image Builder (udbuild)

Easily build custom docker images and publish painlessly all without messing around with a Dockerfile.  If you have you never built your own image before or find that building and publishing images is a pain this repo is for you. 

The "guts" of this repo is a single BASH shell script `build` plus an associated library of scripts and other pieces that facilitate building docker linux images using any of four of these distros (arch,alpine,debian,ubuntu) and either architecture (amd64/arm64).  


## History - Why

Awhile back (circa 2022) I wanted to create some of my own docker images.  After editing one off Dockerfiles and trying to build the image, publish and delopy it as a container I found the process to be involved a lot of CLI fiddling.  For each image I was reinventing the wheel and any dev cycle was taking forever.  So...after awhile I started coding a bash script that could standardize/automate that whole process and significantly speed up the development/deploy cycle. Two years later this repo and the bash scripts therein exist and allow me to spin up new custom images and get them deployed (usually via docker compose) pretty easily.  It allows me to concentrate on just the bash code I need to setup/initialize the code/app in the container. As I amass more custom image "repos" I can leverage them to build variations without starting all over.  My biggest acheivement with this script is an all in one nextcloud container set up just the way I want it. 

Everything I have learned about this process is embodied in the script.  You can use it to learn or just use it as a "black box".  For example it uses `buildx bake` and an hcl build file plus a moby container to build both amd64 and arm64 images and publish to hub.docker.com for deployment elsewhere.  What is `buildx bake` well learn on your own or just leverage my learning.

So despite the documentation being a first cut and imcomplete I have decided to publish this repo on github rather than continue to keep it to myself.  This script probably does way more than you imagine.  Since I wrote it for myself I tried to make it super easy with a lot of sensible defaults and flexible too. It might take awhile to learn about all it can do.  I am sure you will encounter bugs but it is only creating images so not a big deal if it fails and too since it is all written in bash you will likely be able to fix and improve the script yourself.   

## Requirements

This image builder script was created on a linux machine and thus has only been tested on such.  If you are using windows or mac this script may or may not work for you.  Bottom line use a linux machine with this script.

1. You need the docker daemon installed.  
2. The user who will be developing images needs to be in the `docker` group
3. Bash must be installed and you need to have some knowledge of bash scripting in order to make your custom image
4. If you intend to publish your image to a public or private repository you will need an account, see Publishing below

 
## Install

from a terminal simply clone this repo (from hereon refered as the **builder repo or directory**) to a convenient location **writable** by the user creating images.  If you make `/opt` writable by this user then cloning to a subdirectory of `/opt` is a recommended location.   

```
cd some/parent/dir
git clone https://github.com/uCOMmandIt/uci-docker-image-builder.git
cd uci-docker-image-builder
./install
```

the default settings for the install script will attempt to make a link `udib` to the `build` script in `/usr/bin`

altenatively you may use `./install <-r> <-d /your/link/dir> <your link name>`  to install the link in another directory (must be in $PATH) under another name other than `udib` which is the default

`-r` will remove the link you made.

Once installed (in your $PATH) you should be able to run 

`udib help`  from any directory of your machine. 

It is highly recommened to spin up a [portainer](https://www.portainer.io/) container on your image development machine so you can better see and manage the images the script makes as well any any testing/trial containers it makes.


## Getting started

The best way to use this script/repository is to copy the `example/` subdirectory elsewhere, for example to `/opt/myimage` 

```
/bin/cp -R example/ /opt/myimage/
cd /opt/myimage
./build
```

This above will try to build an alpine image (by default) and will prompt you with details before actually doing so.  So for now reply `n`.

It is recommended that you initialize `/opt/myimage` as a git repository in order to track/commit/push changes to your image build.  Backing up `/opt/myimage` is all you need do to "save" your work.  You do NOT and should NOT save anything in the builder directory/repo itself so you never need to save or back it up.  If you happen to delete the builder directory/repo you can just clone it to the same place and you'll be back up and running. 

Once you know more about how to modify your `/opt/myimage` folder then you will be ready to build your first image. Keep reading

# How the script works

The UCI docker build (udbuild) script makes building images easy by obfuscating the Dockerfile

The Dockerfile is assembled at build time via a bunch of templates.  The essence of the Dockerfile created are three RUN layers and one COPY layer explained here.  
After you build an image you can see the Dockerfile the script created.  It will be in the root of the builder repo

1. RUN -CORE: Installs core packages and environment and only supports base images that run the distros alpine, arch, ubuntu or debian.  
2. RUN - PACKAGES: Installs the packages you specify for your custom image via a distro's package manager plus a script you can write
3. COPY - ROOTFS: Copies the rootfs folder in your build source (src/) to the root of the container
4. RUN - INIT: Intializes the container image with bash script(s) that you write.  

The reasoning behind this structure is that the CORE and PACKAGE (RUN/layers) once set will rarely change as you develop and test your image and thus when you rebuild only the ROOTFS layer and INIT layers will be rebuilt signficantly speeding up build times and thus your dev cycle. And if files in in the src/rootfs folder don't change then even that layer will not be rebuilt.

You primarily create your custom image editing a 'source' directory (see below) typically a `src/` subdirectory within your image folder (e.g `/opt/myimage/src`).    

Baked into the image via the CORE is an entrypoint script that makes interacting with the image/container easy and can also launch your "custom" app within the container.  It is possible to completely override this entrypoint script if you prefer.

Once the script "assembles" all the pieces (i.e. the Dockerfile) it uses docker's  "buildx bake" commands and a docker-bake.hcl file to make local images

The default build uses the official alpine image as a base and saves a local generated name (e.g. myimage.latest) but you can specify any existing image as the `BASE_IMAGE` the only requirment is that that base image must be running either alpine,arch.debian or ubuntu distros.

This builder repo also supports building both amd64 and arm64 architecture variants pushing those to your account at hub.docker.com or an alternate private images repository (like a self hosted gitea or github)

A good way to get going is to read carefully the `udib help` and then look at your `opt/myimage` folder you already created including reading the `readme.md` and `env.example` files therein.   

## Customizing your image 

### Environment

From inside your e.g. `/opt/myimage` folder (see getting started) copy the `env.example` file to `.env`.  By default the builder will look for and load this file `.env`. In general it is easier to set the environment variables in the `.env` file rather then via their corresponding command line options, still the commandline options make it easy to override the environment variable for a one off variation of a `.env` file. See again the help.

In the  `.env` you can now uncomment and set variables to begin to "customize" how the script runs.

The first one to uncomment is `IMAGE_NAME`  this will set the image name that the script will create.
The next one might be `BASE_IMAGE` which will tell the script which image to start with.  If you leave this commented the script will start with the official alpine base image by defaul.  If a base image does not have a full url then docker will first look locally and if not will try at hub.docker.com and pull that image.  Once pulled as you rebuild the base image is now local and docker will not pull it again.

### Source

So once you have your environment set you need to focus on the `src/` subdirectory in `/opt/myimage`

```
src/
├── init
│   ├── <container user name>  optional
│   └── init.sh
├── packages
│   ├── packages.sh <optional>
│   ├── repositories.sh <optional>
│   ├── system <optional>
│   │   ├── 01-base.pkgs
│   │   └── 02-more.pkgs.off
│   └── system.pkgs <either this file or system folder above>
└── rootfs
    └── opt
        ├── bin
        │   └── start <or use your own name, e.g. myapp>
        ├── env
        │   ├── run.env
        ├── image.info
        ├── lib <may add more script files here>
        ├── data <or your own name, a folder than can keep persistant data from the container mounted on the host>
        └── myapp <optional may contain more scripts/code>
```

#### packages

The subdirectory `packages/` will be mounted during the PACKAGE RUN mentioned above (2).  The package layer (see package.tpl) first executes a `repositories.sh` script.  Here you can change, amend, customize the system repositories.  Like add a local custom repostory or change to alternate repository (like edge with alpine).
Then any package name found in a *system.pkgs file will be installed as well as any *.pkgs files inside the /system subdirectory.  This make is easy to compartmentalize loading packages and to turn them off by simply adding .off the the file name.  Once those "system" packages have been the `packages.sh` script will be run if it exists.  Here you can customize what other non system packages need to be installed.  For example you may need to install php modules or maybe node modules. Restrict yourself to just loading stuff and save any setup and initialization for the INIT RUN layer (3).  

see `Dockerfile.d/packages.tpl`  to see and understand how the steps above are executed.

#### init

TODO:

### rootfs

TODO:

This folder is copied to root of container.  This allows you to add to image any file or any folder and also to overwrite any existing file.   The builder user the /opt folder for for the entrypoint script and in general all the customizing.  It makes is easier to separte the customization from files and folders added by system packages and the OS itself.  It makes it easier to develop as you can mount the entire opt directory on your host dev machine and troubleshoot editing scripts etc in a trial container (see Development below)

## Developing


## Publishing

TODO:

tldr use docker login for first logging into to your remote repositories like hub.docker.com, github, gitea/forgejo


## Update

To update the builder go to `/<install parent>/uci-docker-image_builder` and execute `git pull origin main`

## Deploying

TODO: