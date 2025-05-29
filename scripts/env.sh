#!/bin/bash

# Fail fast
set -e

# Because this file may be sourced multiple times in one build, variable
# assignments should always check for a pre-existing value.

# Used to label the created images
export BUILD_TIMESTAMP=${BUILD_TIMESTAMP:-$(date -u +"%Y-%m-%dT%H:%M:%SZ")}
# Used as a tag for images created by a scheduled build (monthly)
export BUILD_TIME_TAG=${BUILD_TIME_TAG:-$(date -u +"%Y%m%d")}

# The build number is only available in CI context; we default to "local"
# in order to assign that label in other contexts as well. This is mainly
# to simplify listing the images created during a build:
#
# docker images --filter org.label-schema.build-number=local
#
# Also see the `current_build_tags()` function below.
export BUILD_NUMBER=${BUILD_NUMBER:-${GITHUB_RUN_NUMBER:-local}}

# Enable docker buildkit; optimizes build speed and output (set to 1)
export DOCKER_BUILDKIT=1

# Set target repository, defaults to akamai. Useful during local testing
export DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-akamai}

# Get currently built branch from gh action env, or git if building locally
export BRANCH=${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}

# Extra arguments to pass to docker build, e.g. --build-args
# Supported build args include:
# - CLI_REPOSITORY_URL: to override where we clone CLI code from
export DOCKER_BUILD_EXTRA_ARGS=${DOCKER_BUILD_EXTRA_ARGS:-}

# Guess which tags need to be built, based on the environment
guess_tag() {
  # Master branch gets tagged as latest, others as branch-name.
  # Docker tags cannot have "/" so we normalize as "-".
  # Ultimately, it is up to CI to decide which branches to build,
  # see workflow config
  local branchName=$(echo "$BRANCH" | tr '/' '-')
  local latest=latest
  if [ "${branchName}" != "master" ]
  then
    latest="${branchName}"
  fi

  # Final list of tags depends on the context:
  echo ${latest}
}
export DOCKER_TAG="${DOCKER_TAG:-$(guess_tag)}"

#####################
# SHARED UTILS
#########

chalk() {
  local code=$1; shift;
  [ -t 2 ] && 
    echo -e "\033[$code$@\033[0m" ||
    echo $@
}

debug() {
  1>&2 echo "[DEBUG] $@"
}
info() {
  1>&2 echo "[INFO] $@"
}
err() {
  1>&2 echo "[ERR] $@"
}
