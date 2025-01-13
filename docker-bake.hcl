# variables
variable "TAG" {
  default = "latest"
}
variable "LINUX_DISTRO" {
  default = "alpine"
}
variable "IMAGE_NAME" {
  default = "alpine"
}
variable "BASE_IMAGE" {
  default = "alpine"
}
variable "VERBOSE" {
  default = ""
}
variable "REBUILD" {
  default = ""
}
variable "ARCH" {
  default = ""
}
function "tag" {
  params = [suffix]
  result = [format("${IMAGE_NAME}%s:${TAG}", notequal("${ARCH}", suffix) ? "-${suffix}" : "")]
}
# groups
group "dev" {
  targets = ["${ARCH}"]
}
group "default" {
  targets = ["${ARCH}"]
}
group "multi" {
  targets = [
    "amd64",
    "arm64"
  ]
}
# intended for use with default local docker builder     
# uses 'dev' group in docker-bake.hcl   
# assume dev and default build for architecture of local machine
target "amd64" {
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    LINUX_DISTRO = "${LINUX_DISTRO}"
    BASE_IMAGE   = "${BASE_IMAGE}"
    TAG          = "${TAG}"
    VERBOSE      = "${VERBOSE}"
    REBUILD      = "${REBUILD}"
  }
  tags      = tag("amd64")
  platforms = ["linux/amd64"]
}

# intended for use with default docker driver on an arm64 machine 
# use with 'arm' group 
target "arm64" {
  inherits  = ["amd64"]
  tags      = tag("arm64")
  platforms = ["linux/arm64"]
}

# must use with docker-container driver for multiarch image publish to hub.docker.com
# uses 'publish' group in docker-bake.hcl
target "publish" {
  inherits  = ["amd64"]
  tags      = ["${IMAGE_NAME}:${TAG}"]
  platforms = ["linux/amd64", "linux/arm64"]
  output    = ["type=registry"]
}