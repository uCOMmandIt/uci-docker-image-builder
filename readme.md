# UCI Docker Image Builder (udbuild)

Easily build customizable docker images for local use and publishing without messing around with a Dockerfile.  

The "guts" of this repo is a single BASH shell script plus associated library to facilitate building docker linux images using any of four of these distros (arch,alpine,debian,ubuntu) and either architecture (amd64/arm64).  


## Requirements

This image builder script was created on a linux machine and thus has only been tested on such.  If you are using windows or mac this script may or may not work for you.  Bottom line use a linux distro with this script.

1. You need the docker daemon installed.  
2. The user who will be developing images needs to be in the `docker` group
3. You need bash installed and you need to have some knowledge of bash scripting in order to make your custom image
4. If you intend to publish your image to a public or private repository you will need an account, see Publishing below

 
## Install

from a terminal simply clone this repo toe to a convenient location writable by the user creating images.  If you make `/opt` writable by the this user then cloning to a subdirectory of /opt is a recommended location.  Once cloned enter that directory and 

```
git clone <url>  /opt/udbuild
cd /opt/udbuild
./install
```

Once installed (in your $PATH) you should be able to run 

`udbuild help`  from any directory of your machine. 


## Getting started

The best way to use this script/repository is to copy the example/ subdirectory elsewhere

```
/bin/cp -R /opt/udbuild/example /opt/myimage
cd /opt/myimage
./build
```

This above will try to build an alpine image (by default) and will prompt you with details before actually doing so.  So for now reply `n`.

It is recommended that you initialize /opt/myimage as a git repository and then you and track/commit/push changes to your image build.  Backing up /opt/myimage is all you need do to "save" your work.  You do not need to save anything in the udbuild directory.

Once you know more about how to modify your `/opt/myimage` folder then you will be ready to build your first image.

# How the script works

The UCI docker build (udbuild) script makes building images easy by obfuscating the Dockerfile

The Dockerfile is assembled at build time is essentially three DockerFile RUN (layers) commands.  

1. Installs core packages and environment and only supports base images that run the distros alpine,arch,ubuntu or debian.  
2. Installs the packages you specify for your custom image via a distro's package manager plus a script 
3. Intializes the image with bash script(s) that you write.  

The reasonning behind this structure is that the core and package (RUN/layers) once set will rarely change as you develop and test your image and thus when you rebuild only the init/initialization layer will be rebuilt signficantly speeding up build times and thus your dev cycle.

You primarily create your custom image editing `BUILD_SRC` source directory (see below) typically a `src/` subdirectory within your image folder (e.g `/opt/myimage`).    

Baked into the image is an entrypoint script that makes interacting with the image/container easy and can also launch your "custom" app within the container although it is possible to completely override this script

Once the scripts "assembles" all the pieces (i.e. the Dockerfile) it uses docker's  "buildx bake" commands and a docker-bake.hcl file to make local images

The default build is simply uses the official alpine image as a base and saves a local generated name (e.g. myimage-alpine.latest) 

The repo also supports building both amd64 and arm64 variants pushing those to your account at hub.docker.com or an alternate private images repository (like a self hosted gitea or github)

A good way to get going is to read carefully the `udbuild help` and to read the `env.example` file.   

#  Getting Started

from inside your `/opt/myimage` folder copy the `env.example` file to `.env`.   By default the builder will look for and load this file `.env`.
In general it is easier to set the environment variables in the `.env` file rather then via their corresponding command line options, still the commandline options make it easy to override the environment variable for one off variation of a `.env` file. See again the help.

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


## Update

To update this builder simply go to /<install parent>/uci-docker-image_builder and execute `git pull origin main`
