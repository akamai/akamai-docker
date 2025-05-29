#!/bin/bash

#####################
# SETUP
#########

# Fail fast
set -e

# Assume PWD is root of the repo
source ./scripts/env.sh

#####################
# LOGIN
#
# We need to login before we build in order to increase the quota on docker pull
# operations enforced on anonymous builds.
#########

export DOCKER_USERNAME="${DOCKER_USERNAME:?DOCKER_USERNAME must be set}"
export DOCKER_PASSWORD="${DOCKER_PASSWORD:?DOCKER_PASSWORD must be set}"
echo "${DOCKER_PASSWORD}" |
  docker login -u "${DOCKER_USERNAME}" --password-stdin "${DOCKER_REGISTRY}"
