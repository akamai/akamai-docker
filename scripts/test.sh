#!/bin/bash

#####################
# SETUP
#########

# Fail fast
set -e

# Assume PWD is root of the repo
source ./scripts/env.sh

# Make sure the test container is removed
# when the shell exits, in error or not
atExit() {
  info removing test container
  docker rm -f "${containerId}"
}
trap atExit EXIT

#####################
# MAIN
#########

# Get the platform on which the container will be run
architecture=$(uname -m)

if [ "$architecture" = "x86_64" ] || [ "$architecture" = "amd64" ]; then
    platform=amd64
elif [ "$architecture" = "aarch64" ] || [ "$architecture" = "arm64" ] ; then
    platform=arm64
else
    echo "Unsupported platform: $platform"
    exit 1
fi

# Based on the platform, choose the correct local image and get the container id
image=akamai/shell:local-"${platform}"
info starting test container with tag "${image}"
# In case the image is not found, fail rather than pull remote image
containerId=$(docker run -d --name test --pull=never "${image}" sleep 3600)

# Run the tests
docker cp ./test.bats "${containerId}":/test.bats
docker exec -i "${containerId}" bash <<EOF
set -e

apk add --no-cache git bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
cd /
bats /test.bats
EOF
