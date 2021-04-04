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

RUN if [ $(uname -m) == 'aarch64' ]; \
  then \
    apk add --no-cache git ;\
  else \
    apk add --no-cache git upx ;\
  fi \
  && git clone --depth=1 https://github.com/akamai/cli-api-gateway \
  && cd cli-api-gateway \
  && go mod init github.com/akamai/cli-api-gateway \
  && go mod tidy \
  # -ldflags="-s -w" strips debug information from the executable
  && go build -o /akamai-api-gateway -ldflags="-s -w" ./api-gateway \
  && go build -o /akamai-api-keys -ldflags="-s -w" ./api-keys \
  && go build -o /akamai-api-security -ldflags="-s -w" ./api-security \
  # upx creates a self-extracting compressed executable
  && if [ $(uname -m) != 'aarch64' ]; \
  then \
     upx -3 -o/akamai-api-gateway.upx /akamai-api-gateway \
  && upx -3 -o/akamai-api-keys.upx /akamai-api-keys \
  && upx -3 -o/akamai-api-security.upx /akamai-api-security; \
  else \
     cp /akamai-api-gateway /akamai-api-gateway.upx \
  && cp /akamai-api-keys /akamai-api-keys.upx \
  && cp /akamai-api-security /akamai-api-security.upx; \
  fi \
  # we need to include the cli.json file as well
  && cp cli.json /cli.json

#####################
# FINAL
#########

FROM $BASE

RUN mkdir -p /cli/.akamai-cli/src/cli-api-gateway/bin
COPY --from=builder /akamai-api-gateway.upx /cli/.akamai-cli/src/cli-api-gateway/bin/akamai-api-gateway
COPY --from=builder /akamai-api-keys.upx /cli/.akamai-cli/src/cli-api-gateway/bin/akamai-api-keys
COPY --from=builder /akamai-api-security.upx /cli/.akamai-cli/src/cli-api-gateway/bin/akamai-api-security
COPY --from=builder /cli.json /cli/.akamai-cli/src/cli-api-gateway/cli.json
