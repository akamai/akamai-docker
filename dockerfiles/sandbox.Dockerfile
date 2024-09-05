# Copyright © 2024 Akamai Technologies, Inc. All rights reserved.
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
# BUILD ARGS
#########

ARG BASE=akamai/cli

#####################
# BUILDER
#########

FROM node:18-alpine3.17 as builder

# sandbox originally binds to 127.0.0.1 which doesn't work with Docker's port mapping
# the patch changes the ip to 0.0.0.0
COPY patches/ /tmp/patches/

RUN apk add --no-cache git npm \
  # install cli-sandbox from git
  # (akamai install does not add the --production flag, which increases
  # the footprint of the package since devDependencies are installed)
  && git clone --depth 1 https://github.com/akamai/cli-sandbox.git \
  && cd cli-sandbox \
  && git apply --ignore-whitespace /tmp/patches/*.patch  \
  && rm -rf /tmp/patches \
  && npm install --ignore-scripts \
  && npm run build \
  && rm -rf .git node_modules \
  && npm install --production --ignore-scripts

#####################
# FINAL
#########

FROM $BASE

RUN apk add --no-cache nodejs openjdk8-jre-base libc6-compat gcompat nss

ENV JAVA_HOME=/usr/lib/jvm/default-jvm

# workaround
RUN touch $JAVA_HOME/bin/javac

COPY --from=builder /cli-sandbox $AKAMAI_CLI_HOME/.akamai-cli/src/cli-sandbox

RUN mkdir -p $AKAMAI_CLI_CACHE_PATH/sandbox-cli \
  && mkdir -p /sandboxes && ln -s /sandboxes $AKAMAI_CLI_CACHE_PATH/sandbox-cli/sandboxes \
  # .edgerc file is needed to install sandbox-client
  # however it can be empty
  && touch .edgerc \
  && $AKAMAI_CLI_HOME/.akamai-cli/src/cli-sandbox/akamai-sandbox install \
  && rm .edgerc \
  && rm -rf $AKAMAI_CLI_CACHE_PATH/sandbox-cli/downloads

VOLUME /sandboxes
