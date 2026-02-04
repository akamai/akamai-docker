#####################
# BUILD ARGS
#########

ARG BASE=akamai/cli

#####################
# BUILDER
#########

FROM node:20-alpine3.23 AS builder

# sandbox originally binds to 127.0.0.1 which doesn't work with Docker's port mapping
# the patch changes the ip to 0.0.0.0
COPY patches/ /tmp/patches/

RUN apk add --no-cache git npm \
  # install cli-sandbox from git
  # (akamai install does not add the --production flag, which increases
  # the footprint of the package since devDependencies are installed)
  && git clone --depth 1 https://github.com/akamai/cli-sandbox.git \
  && cd cli-sandbox \
  && git apply --ignore-whitespace /tmp/patches/cli-sandbox*.patch  \
  && rm -rf /tmp/patches \
  && npm pkg set overrides.execa=">=2.0.0" overrides.tar="^7.5.4" overrides.qs="^6.14.1" \
  && npm install --ignore-scripts \
  && npm run build \
  && rm -rf .git node_modules \
  && npm install --production --ignore-scripts

#####################
# FINAL
#########

FROM $BASE

RUN apk add --no-cache nodejs openjdk17-jre-headless libc6-compat gcompat nss

ENV JAVA_HOME=/usr/lib/jvm/default-jvm

# workaround
RUN touch $JAVA_HOME/bin/javac

COPY --from=builder /cli-sandbox $AKAMAI_CLI_HOME/.akamai-cli/src/cli-sandbox

RUN mkdir -p $AKAMAI_CLI_CACHE_PATH/sandbox-cli \
  && mkdir -p /sandboxes && ln -s /sandboxes $AKAMAI_CLI_CACHE_PATH/sandbox-cli/sandboxes \
  # .edgerc file is needed to install sandbox-client
  # however it can be empty
  && touch .edgerc \
  && $AKAMAI_CLI_HOME/.akamai-cli/src/cli-sandbox/akamai-sandbox install \
  && rm .edgerc \
  && rm -rf $AKAMAI_CLI_CACHE_PATH/sandbox-cli/downloads

VOLUME /sandboxes
