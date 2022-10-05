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

# Required arguments
export BUILD_NUMBER="${BUILD_NUMBER:?BUILD_NUMBER must be set}"

# Print all image:tag combinations created by the current build
# using the build-number label, and excluding dangling images
# that may be created by multi-stage builds.
current_build_tags() {
  docker images \
    --filter label=org.label-schema.build-number="${BUILD_NUMBER:-local}" \
    --filter dangling=false \
    --format "{{.Repository}}" |
      sort -u
}

#####################
# LOGIN
#
# When called by CI, this is already done as part of the ci.sh build.
# Logic is preserved here simply so push-all.sh can be called independently
# if needed.
#########

./scripts/docker-login.sh

#####################
# PUSH
#########

# HACK : unconditionally push to latest
#DOCKER_TAG="${DOCKER_TAG} latest"

current_build_tags | grep -Ev "$DOCKER_REPOSITORY/(base|.*-chain)" |
  while read image;
  do
    echo "$image"
    docker push "$image:arm64"
    docker push "$image:amd64"
  done

source ./scripts/remove-tag.sh

current_build_tags | grep -Ev "$DOCKER_REPOSITORY/(base|.*-chain)" |
  while read image;
  do
    echo "$image"
    for tag in ${DOCKER_TAG};
    do
      docker manifest create "$image:$tag" --amend "$image:arm64" --amend "$image:amd64"
      docker manifest push "$image:$tag"
      remove_tag "$image" arm64
      remove_tag "$image" amd64
    done
  done