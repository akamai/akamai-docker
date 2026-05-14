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
  # Fix security vulnerabilities: upgrade requests (supports urllib3 2.x) and urllib3
  && sed -i 's/requests==2.20.0/requests>=2.32.0/' /cli/.akamai-cli/src/cli-adaptive-acceleration/requirements.txt \
  && echo 'urllib3>=2.6.0' >> /cli/.akamai-cli/src/cli-adaptive-acceleration/requirements.txt \
  && python3 -m venv /cli/.akamai-cli/venv/cli-adaptive-acceleration \
  && source /cli/.akamai-cli/venv/cli-adaptive-acceleration/bin/activate \
  && python -m pip install --no-cache-dir --upgrade pip \
  && python -m pip install --no-cache-dir -r /cli/.akamai-cli/src/cli-adaptive-acceleration/requirements.txt \
  && deactivate \
  && rm -rf /cli/.akamai-cli/venv/cli-adaptive-acceleration/bin/pip* \
  && rm -rf /cli/.akamai-cli/venv/cli-adaptive-acceleration/lib/python*/site-packages/pip \
  && rm -rf /cli/.akamai-cli/venv/cli-adaptive-acceleration/lib/python*/site-packages/pip-* \
  && rm -rf /cli/.akamai-cli/venv/cli-adaptive-acceleration/lib/python*/site-packages/_distutils_hack \
  && rm -f /cli/.akamai-cli/venv/cli-adaptive-acceleration/lib/python*/site-packages/distutils-precedence.pth \
  # Drop dev dependencies
  && apk del dev \
  && apk del py3-pip \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-adaptive-acceleration/.git


