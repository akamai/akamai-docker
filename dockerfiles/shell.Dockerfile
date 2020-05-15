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
# FINAL
#########

FROM ${BASE}

# This is the interactive shell container, so people will be more
# familiar with bash than ash
RUN apk add --no-cache bash jq git

COPY files/motd /etc/motd
COPY files/akamai-cli-config /cli/.akamai-cli/config

# This pattern allows us to execute a command
# `docker run ... akamai property ...`
# ... or simply run bash
# `docker run ...`
ENTRYPOINT ["/bin/bash", "-c", "${0} ${1+\"$@\"}"]
