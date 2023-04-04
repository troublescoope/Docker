# Os base using Debian latest
FROM debian:latest

# LABELS 
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
RUN apt-get update && \
    apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    git wget curl p7zip-full swig \
    python3 python3-dev python3-pip python3-venv neofetch \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install cloudflare tunnel.

#ARG TARGETPLATFORM
#ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

#RUN echo -e "\e[32m[INFO]: Installing Cloudflared Tunnel.\e[0m" && \
#    case ${TARGETPLATFORM} in \
#         "linux/amd64")  ARCH=amd64  ;; \
#         "linux/arm64")  ARCH=arm64  ;; \
#         "linux/arm/v7") ARCH=arm    ;; \
#    esac && \
#    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}.deb -O cloudflared-linux-${ARCH}.deb && \
#    dpkg -i --force-architecture cloudflared-linux-${ARCH}.deb

# Installing Nodejs
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 18.13.0
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

CMD ["neofetch"]
