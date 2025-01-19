# syntax=docker/dockerfile:latest
ARG BASE_IMAGE=alpine
ARG LINUX_DISTRO=alpine
% if [[ "$BASE_IMAGE_COPY" ]]; then 
  FROM <% $LINUX_DISTRO %>
  COPY --from=<% $BASE_IMAGE %> / /
% else
  FROM $BASE_IMAGE
% fi

# repeat these so they are available for rest of dockerfile
ARG BASE_IMAGE
ARG LINUX_DISTRO
# 
ARG VERBOSE
ARG REBUILD
WORKDIR /build

# put /opt/bin in path permently
ENV PATH="/opt/bin:${PATH}"

# CORE
RUN --mount=type=bind,source=./core,target=/build \
<<eot
.INCLUDE core.tpl  
eot

% if [[ ( "$_packages_" && ! $BUILD_SRC = "_core_" ) ]]; then 
 .INCLUDE packages.run   
% fi

% if [[ ( -d "$BUILD_SRC/rootfs" && ! $BUILD_SRC = "_core_" ) ]]; then 
  COPY .src/rootfs/ / 
% fi

% if [[ ( -f "$BUILD_SRC/init/init.sh" && ! $BUILD_SRC = "_core_" ) ]]; then 
 .INCLUDE init.run  
% fi

# appends any additional custom Dockerfile code in source
.INCLUDE? "$BDIR/.src/Dockerfile"

% if [[ $VOLUME_DIRS ]]; then
  VOLUME <% $VOLUME_DIRS %>
% fi

# default command
# ENTRYPOINT ["/opt/bin/entrypoint"]
ENTRYPOINT ["<%${ENTRYPOINT:-/opt/bin/entrypoint}%>"]
# default 
WORKDIR <% ${WORKDIR:-/opt} %>


