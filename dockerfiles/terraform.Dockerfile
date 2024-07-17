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

FROM alpine:3.20 as builder
ARG TERRAFORM_VERSION=1.4.6
ARG TERRAFORM_SHA256SUM_amd64=e079db1a8945e39b1f8ba4e513946b3ab9f32bd5a2bdf19b9b186d22c5a3d53b
ARG TERRAFORM_SHA256SUM_arm64=b38f5db944ac4942f11ceea465a91e365b0636febd9998c110fbbe95d61c3b26
# TERRAFORM_SHA256SUM_${TARGETARCH} values can be found in https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS

# Because the builder downloads the latest akamai provider,
# subsequent terraform init calls will download to this directory
# if required, and create a hard link otherwise.
ARG TF_PLUGIN_CACHE_DIR="/var/terraform/plugins"
ENV TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR}"

ARG TARGETARCH

# ca-certificates: Required by `terraform init` when downloading provider plugins.
# curl: depends on ca-certificates, but specifying ca-certificates explicitly
# upx: compress executables

# this will only be used on architectures that upx doesn't use
COPY files/upx-noop /usr/bin/upx
RUN chmod +x /usr/bin/upx

RUN apk add --no-cache $(apk search --no-cache | grep -q ^upx && echo -n upx) ca-certificates curl \
    && curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_$TARGETARCH.zip > terraform_${TERRAFORM_VERSION}_linux_$TARGETARCH.zip \
    && eval "TERRAFORM_SHA256SUM=\$TERRAFORM_SHA256SUM_$TARGETARCH" \
    && echo "${TERRAFORM_SHA256SUM} *terraform_${TERRAFORM_VERSION}_linux_$TARGETARCH.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && sha256sum terraform_${TERRAFORM_VERSION}_linux_$TARGETARCH.zip \
    && sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && unzip terraform_${TERRAFORM_VERSION}_linux_$TARGETARCH.zip -d /usr/local/bin \
    && rm -f terraform_${TERRAFORM_VERSION}_linux_$TARGETARCH.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && upx -o/usr/local/bin/terraform.upx /usr/local/bin/terraform

# initialize latest akamai provider;
# upx (just above) takes very long to run, it's worth creating
# a new layer for the following to avoid recompressing when adding
# a new provider
ADD files/terraform.tf /terraform.tf
RUN mkdir -p ${TF_PLUGIN_CACHE_DIR} \
    && terraform init -input=false -backend=false \
    # find all executable files in the plugins and upx them
    && find ${TF_PLUGIN_CACHE_DIR} -type f -perm +0111 -exec upx -3 -o{}.upx {} \; \
    # for some reason, using mv at this step fails (the operation works, but file not found raised)
    && find ${TF_PLUGIN_CACHE_DIR} -type f -perm +0111 -not -name '*.upx' -exec cp -v {}.upx {} \; \
    # ... so we do it in two steps
    && find ${TF_PLUGIN_CACHE_DIR} -type f -name '*.upx' -exec rm {} \;

#####################
# FINAL
#########

FROM $BASE

ARG TF_PLUGIN_CACHE_DIR="/var/terraform/plugins"
ENV TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR}"

RUN apk add --no-cache curl ca-certificates

COPY --from=builder /terraform.tf /terraform.tf
COPY --from=builder /usr/local/bin/terraform.upx /usr/local/bin/terraform
# we copy over the plugin directory; terraform init will link plugins to
# the files in this directory if available
COPY --from=builder /var/terraform /var/terraform
