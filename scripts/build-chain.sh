#!/bin/bash

#####################
# SETUP
#########

# Fail fast
set -e

# Assume PWD is root of the repo
source ./scripts/env.sh

#####################
# BUILD CHAIN
#########

build_img() {
  info "build_img: $1"

  # Build-time labels
  # http://label-schema.org/rc1/
  local labels=()

  labels+=("--label=org.label-schema.name=$1")
  labels+=("--label=org.label-schema.url=https://developer.akamai.com")
  labels+=('--label=org.label-schema.vendor="Akamai Technologies"')
  # Non-standard, reasonable label
  # Useful for listing all images created during a build (see push-all.sh)
  labels+=("--label=org.label-schema.build-number=${BUILD_NUMBER}")

  # Only include build time label if CI = true
  # This is not necessarily logical, but the build timestamp would
  # otherwise invalidate layer cache systematically, making local builds
  # needlessly long.
  if [ "$CI" = "true" ];
  then
    labels+=("--label=org.label-schema.build-date=${BUILD_TIMESTAMP}")
    labels+=("--label=org.label-schema.vcs-url=$(git remote get-url origin)}")
    labels+=("--label=org.label-schema.vcs-ref=$(git rev-parse --short HEAD)}")
  fi

  if [ "$#" == 2 ]; # $1=image, $2=Dockerfile
  then
    docker build --platform linux/arm64 --force-rm -t $1:local-arm64 -f $2 ${DOCKER_BUILD_EXTRA_ARGS} "${labels[@]}" .
    docker build --platform linux/amd64 --force-rm -t $1:local-amd64 -f $2 ${DOCKER_BUILD_EXTRA_ARGS} "${labels[@]}" .
  elif [ "$#" == 3 ]; # ..., $3=Base image
  then
    docker build --platform linux/arm64 --force-rm -t $1:local-arm64 -f $2 ${DOCKER_BUILD_EXTRA_ARGS} "${labels[@]}" --build-arg BASE=$3:local-arm64 .
    docker build --platform linux/amd64 --force-rm -t $1:local-amd64 -f $2 ${DOCKER_BUILD_EXTRA_ARGS} "${labels[@]}" --build-arg BASE=$3:local-amd64 .
  else
    echo "Unexpected number of arguments to build_img function: $#, failing"
    exit 1
  fi
}

build_chain() {
  info $(chalk 1\;93m "build_chain: $@")
  if [ "$#" == 1 ];
  then
    build_img $DOCKER_REPOSITORY/$1 dockerfiles/$1.Dockerfile
  else
    local base=$1; shift
    while [ "$#" -gt 1 ];
    do
      local tag=$1; shift
      build_img $DOCKER_REPOSITORY/$tag-chain dockerfiles/$tag.Dockerfile $DOCKER_REPOSITORY/$base
      base=$tag-chain
    done
    build_img $DOCKER_REPOSITORY/$1 dockerfiles/$1.Dockerfile $DOCKER_REPOSITORY/$base
  fi
}

build_chain $@
