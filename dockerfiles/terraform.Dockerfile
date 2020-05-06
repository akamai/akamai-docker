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

FROM alpine as builder
ARG TERRAFORM_VERSION=0.12.20
ARG TERRAFORM_SHA256SUM=46bd906f8cb9bbb871905ecb23ae7344af8017d214d735fbb6d6c8e0feb20ff3

# Because the builder downloads the latest akamai provider,
# subsequent terraform init calls will download to this directory
# if required, and create a hard link otherwise.
ARG TF_PLUGIN_CACHE_DIR="/var/terraform/plugins"
ENV TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR}"

# ca-certificates: Required by `terraform init` when downloading provider plugins.
# curl: depends on ca-certificates, but specifying ca-certificates explicitly
# upx: compress executables
RUN apk add --no-cache ca-certificates curl upx \
    && curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && echo "${TERRAFORM_SHA256SUM} *terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
    && rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && upx -o/usr/local/bin/terraform.upx /usr/local/bin/terraform

# initialize latest akamai provider;
# upx (just above) takes very long to run, it's worth creating
# a new layer for the following to avoid recompressing when adding
# a new provider
# ca-certificates: Required by `terraform init` when downloading provider plugins.
RUN mkdir -p ${TF_PLUGIN_CACHE_DIR} \
    # these are commonly used, we preinstall and compress them with upx
    && echo 'provider "akamai" {}' >> /init.tf \
    && echo 'provider "null" {}' >> /init.tf \
    && echo 'provider "local" {}' >> /init.tf \
    && terraform init -input=false -backend=false -get-plugins=true -verify-plugins=true \
    && rm init.tf \
    && find ${TF_PLUGIN_CACHE_DIR} -type f -exec upx --brute -o{}.upx {} \; \
    # for some reason, using mv at this step fails (the operation works, but file not found raised)
    && find ${TF_PLUGIN_CACHE_DIR} -type f -not -name '*.upx' -exec cp {}.upx {} \; \
    # ... so we do it in two steps
    && find ${TF_PLUGIN_CACHE_DIR} -type f -name '*.upx' -exec rm {} \;

#####################
# FINAL
#########

FROM $BASE

ARG TF_PLUGIN_CACHE_DIR="/var/terraform/plugins"
ENV TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR}"

RUN apk add --no-cache curl ca-certificates

COPY --from=builder /usr/local/bin/terraform.upx /usr/local/bin/terraform
# we copy over the plugin directory; terraform init will link plugins to
# the files in this directory if available
COPY --from=builder /var/terraform /var/terraform

ENTRYPOINT ["/usr/local/bin/terraform"]
