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

ARG BASE=akamai/akamai-docker-base

#####################
# BUILDER
#########

FROM golang:alpine as builder

# alpine golang does not have git
RUN apk add --no-cache git \
  && go get -d github.com/akamai/cli \
  && cd $GOPATH/src/github.com/akamai/cli \
  && go mod init \
  && go mod tidy \
  && go build -o /usr/local/bin/akamai

#####################
# FINAL
#########

FROM ${BASE}

RUN mkdir -p /cli/.akamai-cli

COPY --from=builder /usr/local/bin/akamai /usr/local/bin/akamai

ENTRYPOINT ["/usr/local/bin/akamai"]
