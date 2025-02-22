# Copyright © 2024 Akamai Technologies, Inc. All rights reserved.
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

# httpie depends on setuptools at runtime
RUN apk add --no-cache python3 py3-pip py3-setuptools \
  && apk add --no-cache --virtual dev git gcc python3-dev libffi-dev musl-dev openssl-dev \
  # Create a virtual environment
  && python3 -m venv /venv \
  # Activate the virtual environment
  && . /venv/bin/activate \
  && pip install --upgrade pip setuptools \
  && pip install httpie httpie-edgegrid \
  # Drop dev dependencies
  && apk del dev \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf

# Set the virtual environment as the default Python environment
ENV PATH="/venv/bin:$PATH"

ADD files/httpie-config.json /workdir/.httpie/config.json
