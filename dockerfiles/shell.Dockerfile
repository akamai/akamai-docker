#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# FINAL
#########

FROM ${BASE}

# This is the interactive shell container, so people will be more
# familiar with bash than ash
# libstdc++: required by jsonnet
RUN apk add --no-cache bash jq git vim tree bind-tools libstdc++

COPY files/motd /etc/motd
COPY files/profile /etc/profile

# This pattern allows us to execute a command
# `docker run ... akamai property ...`
# ... or simply run bash
# `docker run ...`
ENTRYPOINT ["/bin/bash", "-lc", "${0} ${1+\"$@\"}"]
