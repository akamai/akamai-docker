#####################
# BUILD ARGS
#########

ARG BASE=alpine:3.23

#####################
# FINAL
#########

FROM ${BASE}

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

# Avoid permission issues by working outside of /root in an a+rwx dir.
# (WORKDIR implictly creates as the current user, root)
WORKDIR /workdir
RUN chmod 0777 .
# Declare as a volume AFTER creating it, otherwise the chmod does not work
VOLUME /workdir