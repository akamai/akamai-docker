#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

FROM node:18-alpine3.19 AS builder

RUN apk add --no-cache git npm \
  # install cli-appsec from git
  # (akamai install does not add the --production flag, which increases
  # the footprint of the package since devDependencies are installed)
  && git clone --depth 1 https://github.com/akamai/cli-appsec.git \
  && cd cli-appsec \
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
