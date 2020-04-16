#!/bin/bash

#####################
# SETUP
#########

# Fail fast
set -e

# Assume PWD is root of the repo
source ./scripts/env.sh

#####################
# BUILD
#########

docker build \
  --build-arg "BUILD_DATE=${LABEL_BUILD_DATE}" \
  --build-arg "NAME=${LABEL_NAME}" \
  --build-arg "URL=${LABEL_URL}" \
  --build-arg "VENDOR=${LABEL_VENDOR}" \
  --build-arg "VCS_URL=${LABEL_VCS_URL}" \
  --build-arg "VCS_REF=${LABEL_VCS_REF}" \
  -t "${DOCKER_NAME}" \
  -f "${DOCKER_DOCKERFILE}" \
  "${DOCKER_PATH}"

#####################
# TAG
#########

docker tag "${DOCKER_NAME}" "${DOCKER_NAME}:latest"
docker tag "${DOCKER_NAME}" "${DOCKER_NAME}:${DOCKER_TAG}"
