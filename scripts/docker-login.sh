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
#########

echo "${DOCKER_PASSWORD}" |
  docker login -u "${DOCKER_USERNAME}" --password-stdin ${DOCKER_REGISTRY}
