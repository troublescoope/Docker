# Use Alpine as the base image
FROM alpine:latest

# LABELS
LABEL org.opencontainers.image.source="https://github.com/troublescope/Docker"
LABEL org.opencontainers.image.description="Personal docker base."

# Upgrade & packages
RUN apk update && apk upgrade && \
    apk add --no-cache ca-certificates autoconf bash git wget curl p7zip swig \
    python3 python3-dev py3-pip py3-virtualenv neofetch tzdata \
    && echo python -V

# Set environment variables
ENV LC_ALL C.UTF-8
ENV TZ Asia/Jakarta

# Variabel Nodejs
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 18.13.0

# Install NVM script
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Load NVM and use Node.js
RUN source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

CMD ["neofetch"]
