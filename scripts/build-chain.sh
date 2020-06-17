#!/bin/bash

# Copyright 2020 Akamai Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    docker build --force-rm -t $1 -f $2 "${labels[@]}" .
  elif [ "$#" == 3 ]; # ..., $3=Base image
  then
    docker build --force-rm -t $1 -f $2 "${labels[@]}" --build-arg BASE=$3 .
  fi
}

build_chain() {
  info $(chalk 1\;93m "build_chain: $@")
  if [ "$#" == 1 ];
  then
    build_img akamai/$1 dockerfiles/$1.Dockerfile
  else
    local base=$1; shift
    while [ "$#" -gt 1 ];
    do
      local tag=$1; shift
      build_img akamai/$tag-chain dockerfiles/$tag.Dockerfile akamai/$base
      base=$tag-chain
    done
    build_img akamai/$1 dockerfiles/$1.Dockerfile akamai/$base
  fi

  # Tag image
  for tag in ${DOCKER_TAG};
  do
    docker tag "akamai/$1" "akamai/$1:$tag"
  done
}

build_chain $@
