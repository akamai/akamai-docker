#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

FROM node:20-alpine3.23 AS builder

RUN apk add --no-cache git npm jq \
  # install cli-property-manager from git
  # (akamai install does not add the --production flag, which increases
  # the footprint of the package since devDependencies are installed)
  && git clone --depth 1 https://github.com/akamai/cli-property-manager.git \
  && cd cli-property-manager \
  # Add npm overrides to fix vulnerabilities
  && jq '.overrides["form-data"] = "^4.0.4" | .overrides["tough-cookie"] = "^4.1.3" | .overrides["qs"] = "^6.14.1"' package.json > package.json.tmp && mv package.json.tmp package.json \
  && npm install --production

#####################
# FINAL
#########

FROM $BASE

RUN apk add --no-cache nodejs \
  && mkdir -p /cli/.akamai-cli/src \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-property-manager/.git

COPY --from=builder /cli-property-manager /cli/.akamai-cli/src/cli-property-manager
