#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# FINAL
#########

FROM ${BASE}

RUN mkdir -p /cli/.akamai-cli/src \
  && apk add --no-cache python3 py3-pip \
  && apk add --no-cache --virtual dev git gcc python3-dev py3-setuptools libffi-dev musl-dev openssl-dev \
  && git clone --depth 1 https://github.com/akamai/cli-image-manager.git /cli/.akamai-cli/src/cli-image-manager \
  # remove shebangs to avoid virtual environment interferences
  && sed -i 's/#!\ \/usr\/bin\/env\ python//g' /cli/.akamai-cli/src/cli-image-manager/bin/* \
  && python3 -m venv /cli/.akamai-cli/venv/cli-image-manager \
  && source /cli/.akamai-cli/venv/cli-image-manager/bin/activate \
  && python -m pip install --upgrade pip \
  && python -m pip install -r /cli/.akamai-cli/src/cli-image-manager/requirements.txt \
  && deactivate \
  # Drop dev dependencies
  && apk del dev \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-image-manager/.git
