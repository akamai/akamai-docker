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

# Make sure the test container is removed
# when the shell exits, in error or not
atexit() {
  info removing test container
  docker rm -f ${containerId}
}
trap atexit EXIT

#####################
# MAIN
#########

info starting test container
containerId=$(docker run -d --name test akamai/shell sleep 3600)

docker cp ./test.bats ${containerId}:/test.bats
docker exec -i ${containerId} bash <<EOF
set -e

apk add --no-cache git bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
cd /
bats /test.bats
EOF
