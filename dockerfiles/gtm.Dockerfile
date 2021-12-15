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

# this will only be used on architectures that upx doesn't use
COPY files/upx-noop /usr/bin/upx
RUN chmod +x /usr/bin/upx

RUN apk add --no-cache $(apk search --no-cache | grep -q ^upx && echo -n upx) git \
  && git clone --depth=1 https://github.com/akamai/cli-gtm \
  && cd cli-gtm \
  && go mod vendor \
  # -ldflags="-s -w" strips debug information from the executable
  && go build -mod vendor -o /akamaiGtm -ldflags="-s -w" \
  # upx creates a self-extracting compressed executable
  && upx -3 -o/akamaiGtm.upx /akamaiGtm \
  # we need to include the cli.json file as well
  && cp cli.json /cli.json \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-gtm/.git

#####################
# FINAL
#########

FROM $BASE

RUN mkdir -p /cli/.akamai-cli/src/cli-gtm/bin
COPY --from=builder /akamaiGtm.upx /cli/.akamai-cli/src/cli-gtm/bin/akamaiGtm
COPY --from=builder /cli.json /cli/.akamai-cli/src/cli-gtm/cli.json
