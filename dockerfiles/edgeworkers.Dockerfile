#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# BUILDER
#########

FROM node:20-alpine3.23 AS builder

RUN apk add --no-cache git npm jq \
  # install cli-edgeworkers from git
  && git clone --depth 1 https://github.com/akamai/cli-edgeworkers.git \
  && cd cli-edgeworkers \
  # Fix security vulnerabilities
  && jq '.overrides["axios"] = "^1.15.2" | .overrides["brace-expansion"] = "^5.0.5" | .overrides["follow-redirects"] = "^1.16.0" | .overrides["uuid"] = "^11.1.1"' \
    package.json > package.json.tmp && mv package.json.tmp package.json \
  # we need dev dependencies to transpile
  && npm install \
  # fix TS error: cast AxiosHeaderValue to string for .indexOf() call (axios >=1.7 widened the type)
  && sed -i 's/\.indexOf(/\.toString().indexOf(/g' src/edgeworkers/ew-service.ts \
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
