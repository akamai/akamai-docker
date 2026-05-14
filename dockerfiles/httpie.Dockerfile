#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# FINAL
#########

FROM ${BASE}

# httpie depends on setuptools at runtime
RUN apk add --no-cache python3 py3-pip \
  && apk add --no-cache --virtual dev git gcc python3-dev py3-setuptools libffi-dev musl-dev openssl-dev \
  # Create a virtual environment
  && python3 -m venv /venv \
  # Activate the virtual environment
  && . /venv/bin/activate \
  && python -m pip install --no-cache-dir --upgrade pip setuptools \
  && pip install --no-cache-dir httpie httpie-edgegrid \
  && deactivate \
  && rm -rf /venv/bin/pip* \
  && rm -rf /venv/lib/python*/site-packages/pip \
  && rm -rf /venv/lib/python*/site-packages/pip-* \
  && rm -rf /venv/lib/python*/site-packages/_distutils_hack \
  && rm -f /venv/lib/python*/site-packages/distutils-precedence.pth \
  # Drop dev dependencies
  && apk del dev \
  && apk del py3-pip \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf

# Set the virtual environment as the default Python environment
ENV PATH="/venv/bin:$PATH"

ADD files/httpie-config.json /workdir/.httpie/config.json
