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
  && git clone --depth 1 https://github.com/akamai/cli-etp.git /cli/.akamai-cli/src/cli-etp \
  && python3 -m venv /cli/.akamai-cli/venv/cli-etp \
  && source /cli/.akamai-cli/venv/cli-etp/bin/activate \
  && python -m pip install --no-cache-dir --upgrade pip \
  && python -m pip install --no-cache-dir -r /cli/.akamai-cli/src/cli-etp/requirements.txt \
  && deactivate \
  && rm -rf /cli/.akamai-cli/venv/cli-etp/bin/pip* \
  && rm -rf /cli/.akamai-cli/venv/cli-etp/lib/python*/site-packages/pip \
  && rm -rf /cli/.akamai-cli/venv/cli-etp/lib/python*/site-packages/pip-* \
  && rm -rf /cli/.akamai-cli/venv/cli-etp/lib/python*/site-packages/_distutils_hack \
  && rm -f /cli/.akamai-cli/venv/cli-etp/lib/python*/site-packages/distutils-precedence.pth \
  # Drop dev dependencies
  && apk del dev \
  && apk del py3-pip \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-etp/.git

