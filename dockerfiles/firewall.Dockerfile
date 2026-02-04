#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# FINAL
#########

FROM ${BASE}

COPY patches/ /tmp/patches/

RUN mkdir -p /cli/.akamai-cli/src \
  && apk add --no-cache python3 py3-pip \
  && apk add --no-cache --virtual .dev git gcc python3-dev py3-setuptools libffi-dev musl-dev openssl-dev \
  && git clone --depth 1 https://github.com/akamai/cli-firewall.git /cli/.akamai-cli/src/cli-firewall \
  && git -C /cli/.akamai-cli/src/cli-firewall apply --ignore-whitespace /tmp/patches/cli-firewall.patch  \
  && rm -rf /tmp/patches \
  && python3 -m venv /cli/.akamai-cli/venv/cli-firewall \
  && source /cli/.akamai-cli/venv/cli-firewall/bin/activate \
  && python -m pip install --no-cache-dir --upgrade pip \
  && python -m pip install --no-cache-dir -r /cli/.akamai-cli/src/cli-firewall/requirements.txt \
  && deactivate \
  # Remove pip from the venv to reduce attack surface
  && rm -rf /cli/.akamai-cli/venv/cli-firewall/bin/pip* \
  && rm -rf /cli/.akamai-cli/venv/cli-firewall/lib/python*/site-packages/pip \
  && rm -rf /cli/.akamai-cli/venv/cli-firewall/lib/python*/site-packages/pip-* \
  && rm -rf /cli/.akamai-cli/venv/cli-firewall/lib/python*/site-packages/_distutils_hack \
  && rm -f /cli/.akamai-cli/venv/cli-firewall/lib/python*/site-packages/distutils-precedence.pth \
  # Drop dev dependencies and pip from system to remove vulnerabilities from scan
  && apk del .dev py3-pip \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-firewall/.git

