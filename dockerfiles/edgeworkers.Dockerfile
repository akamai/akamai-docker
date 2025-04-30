#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

FROM node:18-alpine3.19 as builder

RUN apk add --no-cache git npm \
  # install cli-edgeworkers from git
  && git clone --depth 1 https://github.com/akamai/cli-edgeworkers.git \
  && cd cli-edgeworkers \
  # we need dev dependencies to transpile
  && npm install \
  # we need dev dependencies to transpile
  && npm run build \
  # we can remove src (all .ts has been transpiled to bin/**.js)
  && rm -rf src node_modules \
  && npm install --production \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-edgeworkers/.git

#####################
# FINAL
#########

FROM $BASE

RUN apk add --no-cache nodejs \
  && mkdir -p /cli/.akamai-cli/src

COPY --from=builder /cli-edgeworkers /cli/.akamai-cli/src/cli-edgeworkers
