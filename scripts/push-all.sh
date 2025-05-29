#!/bin/bash

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

source ./scripts/remove-tag.sh

current_build_tags | grep -Ev "$DOCKER_REPOSITORY/(base|.*-chain)" |
  while read image;
  do
    echo "$image"
    for tag in ${DOCKER_TAG};
    do
      # re-tag images; adds build number to avoid race condition between builds
      ARMTAG="$BUILD_NUMBER-arm64"
      AMDTAG="$BUILD_NUMBER-amd64"
      docker tag "$image:local-arm64" "$image:$ARMTAG"
      docker tag "$image:local-amd64" "$image:$AMDTAG"
      # push temporary image tags
      docker push "$image:$ARMTAG"
      docker push "$image:$AMDTAG"
      # couple the temporary tags into one manifest
      docker manifest create "$image:$tag" --amend "$image:$ARMTAG" --amend "$image:$AMDTAG"
      docker manifest push "$image:$tag"
      # remove temporary tags
      remove_tag "$image" "$ARMTAG"
      remove_tag "$image" "$AMDTAG"
    done
  done
