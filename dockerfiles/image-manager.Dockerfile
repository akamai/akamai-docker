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

RUN mkdir -p /cli/.akamai-cli/src \
  && apk add --no-cache python3 \
  && apk add --no-cache --virtual dev git gcc python3-dev py3-setuptools libffi-dev musl-dev openssl-dev \
  && git clone --depth 1 https://github.com/akamai/cli-image-manager.git /cli/.akamai-cli/src/cli-image-manager \
  && pip3 install --upgrade pip setuptools \
  # bump requests version to avoid build and runtime warning:
  # "requests/__init__.py:91: RequestsDependencyWarning: urllib3 (1.25.9) or chardet (3.0.4) doesn't match a supported version!"
  && sed -i 's/requests==2.20.0/requests==2.23.0/' /cli/.akamai-cli/src/cli-image-manager/requirements.txt \
  && pip3 install -r /cli/.akamai-cli/src/cli-image-manager/requirements.txt \
  # Drop dev dependencies
  && apk del dev \
  # Drop created wheels
  && rm -rf /root/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf

ENTRYPOINT ["python3", "/cli/.akamai-cli/src/cli-image-manager/bin/akamai-image-manager"]

