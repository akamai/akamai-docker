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

FROM node:12-alpine3.13 as builder

RUN apk add --no-cache git npm \
  # install cli-edgeworkers from git
  && git clone --depth 1 https://github.com/akamai/cli-edgeworkers.git \
  && cd cli-edgeworkers \
  # we need dev dependencies to transpile
  && npm install \
  # we need dev dependencies to transpile
  && npm run build \
  # we can remove src (all .ts has been transpiled to bin/**.js)
  && rm -rf src node_modules \
  && npm install --production \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-edgeworkers/.git

#####################
# FINAL
#########

FROM $BASE

RUN apk add --no-cache nodejs \
  && mkdir -p /cli/.akamai-cli/src

COPY --from=builder /cli-edgeworkers /cli/.akamai-cli/src/cli-edgeworkers
