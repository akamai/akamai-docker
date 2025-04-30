#####################
# BUILD ARGS
#########

ARG BASE=akamai/base

#####################
# FINAL
#########

FROM ${BASE}

# httpie depends on setuptools at runtime
RUN apk add --no-cache python3 py3-pip py3-setuptools \
  && apk add --no-cache --virtual dev git gcc python3-dev libffi-dev musl-dev openssl-dev \
  # Create a virtual environment
  && python3 -m venv /venv \
  # Activate the virtual environment
  && . /venv/bin/activate \
  && pip install --upgrade pip setuptools \
  && pip install httpie httpie-edgegrid \
  # Drop dev dependencies
  && apk del dev \
  # Drop created wheels
  && rm -rf /workdir/.cache \
  # Drop ~20MB by removing bytecode cache created by pip
  && find / -name __pycache__ | xargs rm -rf

# Set the virtual environment as the default Python environment
ENV PATH="/venv/bin:$PATH"

ADD files/httpie-config.json /workdir/.httpie/config.json
