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
# JSONNET BUILDER
#########

# The jsonnet CLI depends on jsonnetfmt being available on the PATH
# to prettyfy its output.
# It also makes sense to include both jsonnet and jsonnetfmt in this
# image since it is likely that the user will want to render the
# templates, not just generate them.

FROM golang:alpine3.12 as jsonnet

RUN if [ $(uname -m) == 'aarch64' ]; \
  then \
    apk add --no-cache git ;\
  else \
    apk add --no-cache git upx ;\
  fi \
  && git clone https://github.com/google/go-jsonnet.git \
  && cd go-jsonnet \
  && go build -o /jsonnet -ldflags="-s -w" ./cmd/jsonnet \
  && go build -o /jsonnetfmt -ldflags="-s -w" ./cmd/jsonnetfmt \
  && if [ $(uname -m) != 'aarch64' ]; \
  then \
     upx -3 -o/jsonnet.upx /jsonnet \
    && upx -3 -o/jsonnetfmt.upx /jsonnetfmt; \
  else \
    cp /jsonnetfmt /jsonnet.upx \
    && cp /jsonnetfmt /jsonnetfmt.upx; \
  fi \
  && chmod +x /jsonnet*

#####################
# FINAL
#########

FROM ${BASE}

COPY --from=jsonnet /jsonnet.upx /usr/bin/jsonnet
COPY --from=jsonnet /jsonnetfmt.upx /usr/bin/jsonnetfmt

RUN mkdir -p /cli/.akamai-cli/src \
  && apk add --no-cache python3 py3-pip \
  && apk add --no-cache --virtual dev git gcc python3-dev py3-setuptools libffi-dev musl-dev openssl-dev \
  && git clone --depth 1 https://github.com/akamai-contrib/cli-jsonnet.git /cli/.akamai-cli/src/cli-jsonnet \
  && pip3 install --upgrade pip setuptools \
  && pip3 install -r /cli/.akamai-cli/src/cli-jsonnet/requirements.txt \
  # Drop dev dependencies
  && apk del dev \
  # Drop created wheels
  && rm -rf /root/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-eaa/.git
