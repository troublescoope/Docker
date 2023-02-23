# Os base using Debian latest
FROM debian:latest

# LABEL
LABEL org.opencontainers.image.source="https://github.com/troublescoope/Docker"
LABEL org.opencontainers.image.description="Personal docker base."

ARG DEBIAN_FRONTEND=noninteractive

# Upgrade & packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    ca-certificates netbase autoconf apt-utils \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# setting environment for docker 
ENV LC_ALL C.UTF-8
ENV TZ Asia/Jakarta 

# Install base required packages
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get -y install build-essential \
        curl \
        zlib1g-dev \
        libncurses5-dev \
        libgdbm-dev \ 
        libnss3-dev \
        libssl-dev \
        libreadline-dev \
        libffi-dev \
        libsqlite3-dev \
        libbz2-dev \
        wget \
    && apt-get purge -y imagemagick imagemagick-6-common 

RUN cd /usr/src \
    && wget https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz \
    && tar -xzf Python-3.11.2.tgz \
    && cd Python-3.11.2 \
    && ./configure --enable-optimizations \
    && make altinstall
    

# Installing Nodejs
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 18.13.0
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# update alternative for using python 
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.11 1

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

CMD ["neofetch"]
