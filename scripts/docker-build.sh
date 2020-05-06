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
