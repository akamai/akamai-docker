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
  && apk add --no-cache --virtual dev git gcc python3-dev py3-setuptools libffi-dev musl-dev openssl-dev sed \
  && git clone --depth 1 https://github.com/akamai/cli-image-manager.git /cli/.akamai-cli/src/cli-image-manager \
  # Fix security vulnerabilities in Python dependencies
  && cd /cli/.akamai-cli/src/cli-image-manager \
  && sed -i 's/requests==2\.23\.0/requests>=2.32.0/' requirements.txt \
  && sed -i 's/urllib3==1\.25\.\*/urllib3>=2.6.0/' requirements.txt \
  && sed -i 's/future==0\.16\.0/future>=0.18.3/' requirements.txt \
  && sed -i 's/idna<2\.7,>=2\.5/idna>=3.7/' requirements.txt \
  && cd / \
  # remove shebangs to avoid virtual environment interferences
  && sed -i 's/#!\ \/usr\/bin\/env\ python//g' /cli/.akamai-cli/src/cli-image-manager/bin/* \
  && python3 -m venv /cli/.akamai-cli/venv/cli-image-manager \
  && source /cli/.akamai-cli/venv/cli-image-manager/bin/activate \
  && python -m pip install --no-cache-dir --upgrade pip \
  && python -m pip install --no-cache-dir -r /cli/.akamai-cli/src/cli-image-manager/requirements.txt \
  && deactivate \
  && rm -rf /cli/.akamai-cli/venv/cli-image-manager/bin/pip* \
  && rm -rf /cli/.akamai-cli/venv/cli-image-manager/lib/python*/site-packages/pip \
  && rm -rf /cli/.akamai-cli/venv/cli-image-manager/lib/python*/site-packages/pip-* \
  && rm -rf /cli/.akamai-cli/venv/cli-image-manager/lib/python*/site-packages/_distutils_hack \
  && rm -f /cli/.akamai-cli/venv/cli-image-manager/lib/python*/site-packages/distutils-precedence.pth \
  # Drop dev dependencies
  && apk del dev \
  && apk del py3-pip \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-image-manager/.git
