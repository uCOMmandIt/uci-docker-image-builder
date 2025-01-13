# UCI Docker Image Builder (udbuild)

Easily build custom docker images and publish painlessly all without messing around with a Dockerfile.  

The "guts" of this repo is a single BASH shell script `build` plus an associated library of scripts and other pieces that facilitate building docker linux images using any of four of these distros (arch,alpine,debian,ubuntu) and either architecture (amd64/arm64).  


## History - Why

Awhile back (circa 2022) I wanted to create some of my own docker images.  After editing up my own one off Dockerfiles and trying to build the image, publish and delopy it as a container I found the process to be involved with a lot of fiddling on the command line.  For each image I was reinventing the wheel and any dev cycle was taking forever.  So...after awhile I started coding a bash script that could standardize/automate that whole process and significantly speed up the development/deploy cycle. Two years later this repo and the bash scripts therein allow me to spin up new custom images and get them deployed (usually via docker compose) pretty easily.  I can concentrate on just the bash code I need to run in the container to get whatever set up configured and initialized rather than on all the other pieces to make that happen.  As I amass more custom image "repos" I can leverage them to build variations without starting all over.  My biggest acheivement with this script is an all in one nextcloud container set up JUST the way I want it. 

So have you never built your own image before or find that building and publishing images is a pain this repo is for you.  Everything I have learned about this process is embodied in the script.  You can use it to learn or just use it as a "black box".  For example it uses `buildx bake` and an hcl build file plus moby container to build both amd64 and arm64 images and publish to hub.docker.com for deployment elsewhere.  What is `buildx bake` well learn on your own or just leverage my learning.

I have NOT publically published this repo with the intention of supporting for others use of it but....after all this work I felt like it was a shame to keep it to myself.  Is the documentation comprehensive? no, but it is a start.  This script probably does way more than you imagine.  It might take awhile to learn about all it can do, but I tried to make it super easy to get started with a lot of sensible defaults.  As I mentioned to use this script is to allow you to concentrate on the actual code you need to set up/run in your container because after all that is what makes images/containers different.


## Requirements

This image builder script was created on a linux machine and thus has only been tested on such.  If you are using windows or mac this script may or may not work for you.  Bottom line use a linux distro with this script.

1. You need the docker daemon installed.  
2. The user who will be developing images needs to be in the `docker` group
3. You need bash installed and you need to have some knowledge of bash scripting in order to make your custom image
4. If you intend to publish your image to a public or private repository you will need an account, see Publishing below

 
## Install

from a terminal simply clone this repo toe to a convenient location writable by the user creating images.  If you make `/opt` writable by the this user then cloning to a subdirectory of /opt is a recommended location.  Once cloned enter that directory and 

```
cd some/parent/dir
git clone https://github.com/uCOMmandIt/uci-docker-image-builder.git
cd uci-docker-image-builder
./install
```

the default settings for the install script will attempt to make a link `udib` to the `build` script in `/usr/bin`

altenatively you may use `./install <-r> <-d /your/link/dir> <your link name>`
to install the link in another directory (must be in $PATH) under another name other than `udib` which is the defaul
`-r` will remove the link you made.

Once installed (in your $PATH) you should be able to run 

`udib help`  from any directory of your machine. 

It is recommened to run a [portainer](https://www.portainer.io/) container on your image development machine so you can better see and manage the images the script makes as well any any testing/trial containers it makes.


## Getting started

The best way to use this script/repository is to copy the `example/` subdirectory elsewhere

```
/bin/cp -R example/ /opt/myimage/
cd /opt/myimage
./build
```

This above will try to build an alpine image (by default) and will prompt you with details before actually doing so.  So for now reply `n`.

It is recommended that you initialize `/opt/myimage` as a git repository and then you and track/commit/push changes to your image build.  Backing up /opt/myimage is all you need do to "save" your work.  You do NOT and should NOT save anything in the builder directory itself so you do not need to save or back it up.  If you happen to delete the builder directory/repo you can just clone it to the same place and you'll be back up and running. 

Once you know more about how to modify your `/opt/myimage` folder then you will be ready to build your first image.

# How the script works

The UCI docker build (udbuild) script makes building images easy by obfuscating the Dockerfile

The Dockerfile is assembled at build time via a bunch of templates.  The essence of the Dockerfile created are three RUN (layers) commands explained here.  

1. Installs core packages and environment and only supports base images that run the distros alpine, arch, ubuntu or debian.  
2. Installs the packages you specify for your custom image via a distro's package manager plus a script 
3. Intializes the image with bash script(s) that you write.  

The reasoning behind this structure is that the core and package (RUN/layers) once set will rarely change as you develop and test your image and thus when you rebuild only the init/initialization layer will be rebuilt signficantly speeding up build times and thus your dev cycle.

You primarily create your custom image editing `BUILD_SRC` source directory (see below) typically a `src/` subdirectory within your image folder (e.g `/opt/myimage/src`).    

Baked into the image via the core is an entrypoint script that makes interacting with the image/container easy and can also launch your "custom" app within the container although it is possible to completely override this entrypoint script

Once the script "assembles" all the pieces (i.e. the Dockerfile) it uses docker's  "buildx bake" commands and a docker-bake.hcl file to make local images

The default build uses the official alpine image as a base and saves a local generated name (e.g. myimage.latest) 

The repo also supports building both amd64 and arm64 architecture variants pushing those to your account at hub.docker.com or an alternate private images repository (like a self hosted gitea or github)

A good way to get going is to read carefully the `udib help` and to read the `env.example` file.   

## Customizing your image 

from inside your `/opt/myimage` folder copy the `env.example` file to `.env`.  By default the builder will look for and load this file `.env`.
In general it is easier to set the environment variables in the `.env` file rather then via their corresponding command line options, still the commandline options make it easy to override the environment variable for a one off variation of a `.env` file. See again the help.

In the  `.env` you can now uncomment and set variables to begin to "customize" how the script runs.

Also you need to focus on the `src/` subdirectory

the subdirectory packages/ will be mounted during the package RUN mentioned above (2).  The init dire

```
src
├── init
│   ├── host
│   └── init.sh
├── packages
│   ├── install-os-info.sh
│   ├── packages.lst
│   └── packages.sh
└── rootfs
    └── opt
        ├── bin
        │   └── mycmd
        ├── env
        │   ├── run.env
        │   └── run.env.example
        ├── image.info
        ├── lib
        └── myapp
```

## Publishing

TODO

tldr use docker login for first logging into to your remote repositories like hub.docker.com, github, gitea/forgejo


## Update

To update this builder simply go to /<install parent>/uci-docker-image_builder and execute `git pull origin main`

## Deploying your image with a container

