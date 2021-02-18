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

FROM golang:alpine3.12 as builder

RUN apk add --no-cache git upx \
  && git clone --depth=1 https://github.com/akamai/cli-purge \
  && cd cli-purge \
  && go mod init github.com/akamai/cli-purge \
  && go mod vendor \
  # -ldflags="-s -w" strips debug information from the executable 
  && go build -o /akamai-purge -ldflags="-s -w" \
  # upx creates a self-extracting compressed executable
  && upx -3 -o/akamai-purge.upx /akamai-purge \
  # we need to include the cli.json file as well
  && cp cli.json /cli.json

#####################
# FINAL
#########

FROM $BASE

RUN mkdir -p /cli/.akamai-cli/src/cli-purge/bin
COPY --from=builder /akamai-purge.upx /cli/.akamai-cli/src/cli-purge/bin/akamai-purge
COPY --from=builder /cli.json /cli/.akamai-cli/src/cli-purge/cli.json
