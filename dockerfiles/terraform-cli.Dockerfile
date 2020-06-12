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

FROM golang:alpine as builder

RUN apk add --no-cache git upx \
  && go get -d github.com/akamai/cli-terraform \
  && cd "${GOPATH}/src/github.com/akamai/cli-terraform" \
  # -ldflags="-s -w" strips debug information from the executable 
  && go build -o /akamaiTerraform -ldflags="-s -w" \
  # upx creates a self-extracting compressed executable
  && upx -3 -o/akamaiTerraform.upx /akamaiTerraform \
  # we need to include the cli.json file as well
  && cp "${GOPATH}/src/github.com/akamai/cli-terraform/cli.json" /cli.json \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-akamaiTerraform/.git

#####################
# FINAL
#########

FROM $BASE

RUN mkdir -p /cli/.akamai-cli/src/cli-terraform/bin
COPY --from=builder /akamaiTerraform.upx /cli/.akamai-cli/src/cli-terraform/bin/akamaiTerraform
COPY --from=builder /cli.json /cli/.akamai-cli/src/cli-terraform/cli.json
