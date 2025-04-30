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
  && git clone --depth 1 https://github.com/akamai/cli-adaptive-acceleration.git /cli/.akamai-cli/src/cli-adaptive-acceleration \
  # bump requests version to avoid build and runtime warning:
  # "requests/__init__.py:91: RequestsDependencyWarning: urllib3 (1.25.9) or chardet (3.0.4) doesn't match a supported version!"
  && sed -i 's/requests==2.20.0/requests==2.23.0/' /cli/.akamai-cli/src/cli-adaptive-acceleration/requirements.txt \
  && python3 -m venv /cli/.akamai-cli/venv/cli-adaptive-acceleration \
  && source /cli/.akamai-cli/venv/cli-adaptive-acceleration/bin/activate \
  && python -m pip install --upgrade pip \
  && python -m pip install -r /cli/.akamai-cli/src/cli-adaptive-acceleration/requirements.txt \
  && deactivate \
  # Drop dev dependencies
  && apk del dev \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-adaptive-acceleration/.git


