#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

FROM golang:1.23.8-alpine3.21 as builder

# this will only be used on architectures that upx doesn't use
COPY files/upx-noop /usr/bin/upx
RUN chmod +x /usr/bin/upx

RUN apk add --no-cache $(apk search --no-cache | grep -q ^upx && echo -n upx) git \
  && git clone --depth=1 https://github.com/akamai/cli-purge \
  && cd cli-purge \
  && go mod tidy \
  # -ldflags="-s -w" strips debug information from the executable
  && go build -o /akamai-purge -ldflags="-s -w" \
  # upx creates a self-extracting compressed executable
  && upx -3 -o/akamai-purge.upx /akamai-purge \
  # we need to include the cli.json file as well
  && cp cli.json /cli.json

#####################
# FINAL
#########

FROM $BASE

RUN mkdir -p /cli/.akamai-cli/src/cli-purge/bin
COPY --from=builder /akamai-purge.upx /cli/.akamai-cli/src/cli-purge/bin/akamai-purge
COPY --from=builder /cli.json /cli/.akamai-cli/src/cli-purge/cli.json
