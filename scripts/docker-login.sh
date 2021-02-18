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
# LOGIN
#
# We need to login before we build in order to increase the quota on docker pull
# operations enforced on anonymous builds.
#########

export DOCKER_USERNAME="${DOCKER_USERNAME:?DOCKER_USERNAME must be set}"
export DOCKER_PASSWORD="${DOCKER_PASSWORD:?DOCKER_PASSWORD must be set}"
echo "${DOCKER_PASSWORD}" |
  docker login -u "${DOCKER_USERNAME}" --password-stdin ${DOCKER_REGISTRY}
