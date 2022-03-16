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
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

FROM golang:alpine3.13 as builder

ARG CLI_REPOSITORY_URL=https://github.com/akamai/cli

# this will only be used on architectures that upx doesn't use
COPY files/upx-noop /usr/bin/upx
RUN chmod +x /usr/bin/upx

RUN apk add --no-cache $(apk search --no-cache | grep -q ^upx && echo -n upx) git \
  && git clone --depth=1 $CLI_REPOSITORY_URL \
  && cd cli \
  && go mod tidy \
  # -ldflags="-s -w" strips debug information from the executable
  && go build -o /akamai -ldflags="-s -w" cli/main.go \
  # upx creates a self-extracting compressed executable
  && upx -3 -o/akamai.upx /akamai 

#####################
# FINAL
#########

FROM ${BASE}

ARG AKAMAI_CLI_HOME=/cli
ENV AKAMAI_CLI_HOME=${AKAMAI_CLI_HOME}
# don't forget to update files/akamai-cli-config if you make any changes here
ENV AKAMAI_CLI_CACHE_PATH=${AKAMAI_CLI_HOME}/.akamai-cli/cache

ENV AKAMAI_LOG=info
ENV AKAMAI_CLI_LOG_PATH="/cli/.akamai-cli/logs/cli.log"

RUN mkdir -p $AKAMAI_CLI_HOME/.akamai-cli $AKAMAI_CLI_HOME/.akamai-cli/logs ${AKAMAI_CLI_CACHE_PATH} \
    && touch $AKAMAI_CLI_LOG_PATH

COPY --from=builder /akamai.upx /bin/akamai

ADD files/akamai-cli-config ${AKAMAI_CLI_HOME}/.akamai-cli/config

RUN chmod -R a+rwx ${AKAMAI_CLI_HOME}