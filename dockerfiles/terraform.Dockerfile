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
ARG TERRAFORM_VERSION=0.12.24
ARG TERRAFORM_SHA256SUM=602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11

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

#####################
# FINAL
#########

FROM $BASE

COPY --from=builder /usr/local/bin/terraform.upx /usr/local/bin/terraform

# Because the builder downloads the latest akamai provider,
# subsequent terraform init calls will download to this directory
# if required, and create a hard link otherwise.
ARG TF_PLUGIN_CACHE_DIR="/.terraform/plugins"
ENV TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR}"

# initialize latest akamai provider;
# upx (just above) takes very long to run, it's worth creating
# a new layer for the following to avoid recompressing when adding
# a new provider
# ca-certificates: Required by `terraform init` when downloading provider plugins.
RUN apk add --no-cache curl ca-certificates \
    && mkdir -p /.terraform/.plugins \
    && echo 'provider "akamai" {}' >> /init.tf \
    && echo 'provider "null" {}' >> /init.tf \
    && echo 'provider "local" {}' >> /init.tf \
    && TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR}" terraform init -input=false -backend=false -get-plugins=true -verify-plugins=true

ENTRYPOINT ["/usr/local/bin/terraform"]
