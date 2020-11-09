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

FROM golang:alpine3.11 as builder

RUN apk add --no-cache git upx \
  && go get -d github.com/akamai/cli \
  && cd $GOPATH/src/github.com/akamai/cli \
  && go mod init \
  && go mod tidy \
  # -ldflags="-s -w" strips debug information from the executable 
  && go build -o /akamai -ldflags="-s -w" \
  # upx creates a self-extracting compressed executable
  && upx -3 -o/akamai.upx /akamai

#####################
# FINAL
#########

FROM ${BASE}

ARG AKAMAI_CLI_HOME=/cli
ENV AKAMAI_CLI_HOME=${AKAMAI_CLI_HOME}
ENV AKAMAI_CLI_CACHE_PATH=${AKAMAI_CLI_HOME}/.akamai-cli/cache

RUN mkdir -p $AKAMAI_CLI_HOME/.akamai-cli ${AKAMAI_CLI_CACHE_PATH}

COPY --from=builder /akamai.upx /bin/akamai

ADD files/akamai-cli-config ${AKAMAI_CLI_HOME}/.akamai-cli/config

RUN akamai config set cli.cache-path ${AKAMAI_CLI_CACHE_PATH}
