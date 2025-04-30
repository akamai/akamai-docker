#!/bin/bash

#####################
# SETUP
#########

# Fail fast
set -e

# Assume PWD is root of the repo
source ./scripts/env.sh

#####################
# MAIN
#########

./scripts/docker-login.sh
./scripts/build-all.sh
./scripts/test.sh
./scripts/push-all.sh