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

ARG BASE=alpine:3.11

#####################
# FINAL
#########

FROM ${BASE}
ARG AKAMAI_CLI_HOME=/cli
ENV AKAMAI_CLI_HOME=$AKAMAI_CLI_HOME
ENV AKAMAI_CLI_CACHE_PATH=$AKAMAI_CLI_HOME/.cache

RUN mkdir -p $AKAMAI_CLI_CACHE_PATH

WORKDIR /root