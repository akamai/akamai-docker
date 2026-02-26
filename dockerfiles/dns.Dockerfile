#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

FROM golang:1.24.11-alpine3.23 AS builder

# this will only be used on architectures that upx doesn't use
COPY files/upx-noop /usr/bin/upx
RUN chmod +x /usr/bin/upx

ARG CLI_DNS_REF=0.6.0

RUN apk add --no-cache $(apk search --no-cache | grep -q ^upx && echo -n upx) git \
  && git clone --depth=1 --branch ${CLI_DNS_REF} https://github.com/akamai/cli-dns \
  && cd cli-dns \
  && go mod vendor \
  # -ldflags="-s -w" strips debug information from the executable
  && go build -mod vendor -o /akamaiDns -ldflags="-s -w" \
  # upx creates a self-extracting compressed executable
  && upx -3 -o/akamaiDns.upx /akamaiDns \
  # we need to include the cli.json file as well
  && cp cli.json /cli.json \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-dns/.git

#####################
# FINAL
#########

FROM $BASE

RUN mkdir -p /cli/.akamai-cli/src/cli-dns/bin
COPY --from=builder /akamaiDns.upx /cli/.akamai-cli/src/cli-dns/bin/akamaiDns
COPY --from=builder /cli.json /cli/.akamai-cli/src/cli-dns/cli.json
