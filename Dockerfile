FROM alpine:3.11 as base

FROM base as builder
ARG AKAMAI_CLI_HOME=/cli
ENV AKAMAI_CLI_HOME=$AKAMAI_CLI_HOME GOROOT=/usr/lib/go GOPATH=/go GO111MODULE=auto PATH=$PATH:$GOBIN
RUN mkdir -p $AKAMAI_CLI_HOME/.akamai-cli
RUN apk add --no-cache docker git bash python2 python2-dev py2-pip python3 python3-dev npm wget jq openssl openssl-dev curl nodejs build-base libffi libffi-dev vim nano util-linux go dep tree bind-tools 
RUN go get -d github.com/akamai/cli && cd $GOPATH/src/github.com/akamai/cli && go mod init && go mod tidy && go build -o /usr/local/bin/akamai
RUN pip install --upgrade pip && pip3 install --upgrade pip
RUN curl -s https://developer.akamai.com/cli/package-list.json -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:42.0) Gecko/20100101 Firefox/42.0" | jq '.packages[].name' | sed s/\"//g | xargs akamai install --force 
RUN go get github.com/spf13/cast && akamai install cli-api-gateway 
# https://github.com/akamai/cli-sandbox/issues/24
RUN akamai install sandbox && cd $AKAMAI_CLI_HOME/.akamai-cli/src/cli-sandbox/ && npm run build
RUN cd $AKAMAI_CLI_HOME/.akamai-cli/src/cli-edgeworkers/ && npm run build
WORKDIR /wheels
RUN pip install wheel
RUN pip wheel httpie httpie-edgegrid cffi

FROM base
ARG AKAMAI_CLI_HOME=/cli
ENV AKAMAI_CLI_HOME=$AKAMAI_CLI_HOME GOROOT=/usr/lib/go GOPATH=/go GO111MODULE=auto PATH=$PATH:$GOBIN
RUN apk add --no-cache docker git bash python2 py2-pip python3 npm wget jq openssl openssh-client curl nodejs libffi vim nano util-linux tree bind-tools openjdk8 libc6-compat gcompat nss

COPY --from=builder /wheels /wheels
RUN pip install --upgrade pip && \
    pip3 install --upgrade pip && \
    pip3 install netstorageapi && \
    pip install -f /wheels cffi httpie httpie-edgegrid && \
    rm -rf /wheels && \
    rm -rf /root/.cache/pip/*

COPY --from=builder $AKAMAI_CLI_HOME $AKAMAI_CLI_HOME
COPY --from=builder /usr/local/bin/akamai /usr/local/bin/akamai

RUN echo 'eval "$(/usr/local/bin/akamai --bash)"' >> /root/.profile 
RUN echo "[cli]" > $AKAMAI_CLI_HOME/.akamai-cli/config && \
    echo "cache-path            = $AKAMAI_CLI_HOME/.akamai-cli/cache" >> $AKAMAI_CLI_HOME/.akamai-cli/config && \
    echo "config-version        = 1.1" >> $AKAMAI_CLI_HOME/.akamai-cli/config && \
    echo "enable-cli-statistics = true" >> $AKAMAI_CLI_HOME/.akamai-cli/config && \
    echo "last-ping             = 2018-08-08T00:00:12Z" >> $AKAMAI_CLI_HOME/.akamai-cli/config && \
    echo "client-id             = devops-sandbox" >> $AKAMAI_CLI_HOME/.akamai-cli/config && \
    echo "install-in-path       =" >> $AKAMAI_CLI_HOME/.akamai-cli/config && \
    echo "last-upgrade-check    = ignore" >> $AKAMAI_CLI_HOME/.akamai-cli/config && \
    echo "stats-version         = 1.1" >> $AKAMAI_CLI_HOME/.akamai-cli/config
RUN echo '                ___    __                         _            ' >  /etc/motd && \
    echo '               /   |  / /______ _____ ___  ____ _(_)           ' >> /etc/motd && \
    echo '              / /| | / //_/ __ `/ __ `__ \/ __ `/ /            ' >> /etc/motd && \
    echo '             / ___ |/ ,< / /_/ / / / / / / /_/ / /             ' >> /etc/motd && \
    echo '            /_/  |_/_/|_|\__,_/_/ /_/ /_/\__,_/_/              ' >> /etc/motd && \
    echo '===============================================================' >> /etc/motd && \
    echo '=  Welcome to the Akamai Docker Image                         =' >> /etc/motd && \
    echo '===============================================================' >> /etc/motd && \
    echo '=  Project page:                                              =' >> /etc/motd && \
    echo '=  https://github.com/akamai/akamai-docker                    =' >> /etc/motd && \
    echo '===============================================================' >> /etc/motd
RUN echo "cat /etc/motd" >> /root/.bashrc && \
    echo "PS1=\"\[\e[38;2;255;165;0m\]Akamai DevOps [\w] >>\[\e[m\] \"" >> /root/.bashrc
RUN echo "[[ -f /root/.terraform-env ]] && source .terraform-env" >> /root/.profile && \
    echo "export JAVA_HOME=/usr/lib/jvm/default-jvm" >> /root/.profile
RUN mkdir /root/.httpie 
RUN echo '{' >> /root/.httpie/config.json && \
    echo '"__meta__": {' >> /root/.httpie/config.json && \
    echo '    "about": "HTTPie configuration file", ' >> /root/.httpie/config.json && \
    echo '    "httpie": "1.0.0-dev"' >> /root/.httpie/config.json && \
    echo '}, ' >> /root/.httpie/config.json && \
    echo '"default_options": ["--timeout=300","--style=autumn"], ' >> /root/.httpie/config.json && \
    echo '"implicit_content_type": "json"' >> /root/.httpie/config.json && \
    echo '}' >> /root/.httpie/config.json

ENV TERRAFORM_VERSION=0.12.20 \
    TERRAFORM_SHA256SUM=46bd906f8cb9bbb871905ecb23ae7344af8017d214d735fbb6d6c8e0feb20ff3
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "${TERRAFORM_SHA256SUM} *terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS

RUN mkdir /root/pipeline && ln -s /root/pipeline /pipeline

VOLUME /root
WORKDIR /root
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]
