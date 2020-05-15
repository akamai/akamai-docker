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

# This image should be build on a variant to run a series of tests.

#####################
# BUILD ARGS
#########

ARG BASE=akamai/shell

#####################
# INSTALL BATS
#########

FROM ${BASE}

ARG TEST_SUITE=test.bats

RUN apk add --no-cache git bash \
  && git clone https://github.com/bats-core/bats-core.git \
  && cd bats-core \
  && ./install.sh /

ADD ${TEST_SUITE} /root/test.bats

RUN bats /test.bats
