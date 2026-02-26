#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

FROM node:20-alpine3.23 AS builder

COPY patches/ /tmp/patches/

RUN apk add --no-cache git jq \
  # install cli-appsec from git
  # (akamai install does not add the --production flag, which increases
  # the footprint of the package since devDependencies are installed)
  && git clone --depth 1 https://github.com/akamai/cli-appsec.git \
  && cd cli-appsec \
  && git apply --ignore-whitespace /tmp/patches/cli-appsec.patch  \
  && rm -rf /tmp/patches \
  # Add npm overrides to fix vulnerabilities
  # CVE-2025-7783 (form-data), CVE-2025-58754 (axios), GHSA-3xgq-45jj-v275 (cross-spawn)
  && jq '.overrides["form-data"] = "^4.0.4" | .overrides["axios"] = "^1.13.2" | .overrides["cross-spawn"] = "^7.0.3"' package.json > package.json.tmp && mv package.json.tmp package.json \
  && npm install --production \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-appsec/.git

#####################
# FINAL
#########

FROM $BASE

RUN apk add --no-cache nodejs \
  && mkdir -p /cli/.akamai-cli/src

COPY --from=builder /cli-appsec /cli/.akamai-cli/src/cli-appsec
