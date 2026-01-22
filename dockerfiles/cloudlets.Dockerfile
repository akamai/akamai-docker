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
  && apk add --no-cache --virtual .dev git gcc python3-dev py3-setuptools libffi-dev musl-dev openssl-dev \
  && git clone https://github.com/akamai/cli-cloudlets.git /cli/.akamai-cli/src/cli-cloudlets \
  && python3 -m venv /cli/.akamai-cli/venv/cli-cloudlets \
  && source /cli/.akamai-cli/venv/cli-cloudlets/bin/activate \
  && python -m pip install --no-cache-dir --upgrade pip \
  && python -m pip install --no-cache-dir --only-binary :all: -r /cli/.akamai-cli/src/cli-cloudlets/requirements.txt \
  # Force upgrade setuptools to fix CVE-2025-47273 (even though requirements.txt has it, ensure it's applied)
  && python -m pip install --no-cache-dir --upgrade --force-reinstall 'setuptools>=78.1.1' \
  && deactivate \
  # Remove pip from the venv to reduce attack surface (keep setuptools for pkg_resources needed by prettytable)
  && rm -rf /cli/.akamai-cli/venv/cli-cloudlets/bin/pip* \
  && rm -rf /cli/.akamai-cli/venv/cli-cloudlets/lib/python*/site-packages/pip \
  && rm -rf /cli/.akamai-cli/venv/cli-cloudlets/lib/python*/site-packages/pip-* \
  && rm -rf /cli/.akamai-cli/venv/cli-cloudlets/lib/python*/site-packages/_distutils_hack \
  && rm -f /cli/.akamai-cli/venv/cli-cloudlets/lib/python*/site-packages/distutils-precedence.pth \
  # Drop dev dependencies and pip from system to remove vulnerabilities from scan
  && apk del .dev py3-pip \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf \
  # git dir not needed, drops a few hundred KB (just a few hundred, thanks to shallow clone)
  && rm -rf /cli/.akamai-cli/src/cli-cloudlets/.git

