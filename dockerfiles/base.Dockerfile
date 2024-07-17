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

ARG BASE=alpine:3.13

#####################
# FINAL
#########

FROM ${BASE}

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

# Avoid permission issues by working outside of /root in an a+rwx dir.
# (WORKDIR implictly creates as the current user, root)
WORKDIR /workdir
RUN chmod 0777 .
# Declare as a volume AFTER creating it, otherwise the chmod does not work
VOLUME /workdir