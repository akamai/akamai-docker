#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

# Do not upgrade Go version beyond 1.21 for api-gateway
# as the project structure is outdated and may not be compatible.

FROM golang:1.21.12-alpine3.19 as builder

# this will only be used on architectures that upx doesn't use
COPY files/upx-noop /usr/bin/upx
RUN chmod +x /usr/bin/upx

RUN apk add --no-cache $(apk search --no-cache | grep -q ^upx && echo -n upx) git \
  && git clone --depth=1 https://github.com/akamai/cli-api-gateway \
  && cd cli-api-gateway \
  && go mod init github.com/akamai/cli-api-gateway \
  && go mod tidy \
  # -ldflags="-s -w" strips debug information from the executable
  && go build -o /akamai-api-gateway -ldflags="-s -w" ./api-gateway \
  && go build -o /akamai-api-keys -ldflags="-s -w" ./api-keys \
  && go build -o /akamai-api-security -ldflags="-s -w" ./api-security \
  # upx creates a self-extracting compressed executable
  && upx -3 -o/akamai-api-gateway.upx /akamai-api-gateway \
  && upx -3 -o/akamai-api-keys.upx /akamai-api-keys \
  && upx -3 -o/akamai-api-security.upx /akamai-api-security \
  # we need to include the cli.json file as well
  && cp cli.json /cli.json

#####################
# FINAL
#########

FROM $BASE

RUN mkdir -p /cli/.akamai-cli/src/cli-api-gateway/bin
COPY --from=builder /akamai-api-gateway.upx /cli/.akamai-cli/src/cli-api-gateway/bin/akamai-api-gateway
COPY --from=builder /akamai-api-keys.upx /cli/.akamai-cli/src/cli-api-gateway/bin/akamai-api-keys
COPY --from=builder /akamai-api-security.upx /cli/.akamai-cli/src/cli-api-gateway/bin/akamai-api-security
COPY --from=builder /cli.json /cli/.akamai-cli/src/cli-api-gateway/cli.json
