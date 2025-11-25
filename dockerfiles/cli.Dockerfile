#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

FROM golang:1.24.10-alpine3.22 AS builder

ARG CLI_REPOSITORY_URL=https://github.com/akamai/cli

# this will only be used on architectures that upx doesn't use
COPY files/upx-noop /usr/bin/upx
RUN chmod +x /usr/bin/upx

RUN apk add --no-cache $(apk search --no-cache | grep -q ^upx && echo -n upx) git \
  && git clone --depth=1 $CLI_REPOSITORY_URL \
  && cd cli \
  && go mod tidy \
  # -ldflags="-s -w" strips debug information from the executable
  && go build -o /akamai -ldflags="-s -w" cli/main.go \
  # upx creates a self-extracting compressed executable
  && upx -3 -o/akamai.upx /akamai 

#####################
# FINAL
#########

FROM ${BASE}

ARG AKAMAI_CLI_HOME=/cli
ENV AKAMAI_CLI_HOME=${AKAMAI_CLI_HOME}
# don't forget to update files/akamai-cli-config if you make any changes here
ENV AKAMAI_CLI_CACHE_PATH=${AKAMAI_CLI_HOME}/.akamai-cli/cache

ENV AKAMAI_LOG=info
ENV AKAMAI_CLI_LOG_PATH="/cli/.akamai-cli/logs/cli.log"

RUN mkdir -p $AKAMAI_CLI_HOME/.akamai-cli $AKAMAI_CLI_HOME/.akamai-cli/logs ${AKAMAI_CLI_CACHE_PATH} \
    && touch $AKAMAI_CLI_LOG_PATH

COPY --from=builder /akamai.upx /bin/akamai

ADD files/akamai-cli-config ${AKAMAI_CLI_HOME}/.akamai-cli/config

RUN chmod -R a+rwx ${AKAMAI_CLI_HOME}