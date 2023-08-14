# Use Alpine as the base image
FROM alpine:latest

# LABELS
LABEL org.opencontainers.image.source="https://github.com/troublescope/Docker"
LABEL org.opencontainers.image.description="Personal docker base."

# Upgrade & packages
RUN apk update && apk upgrade && \
    apk add --no-cache ca-certificates autoconf bash git wget curl p7zip swig \
    python3 py3-dev py3-pip py3-venv neofetch tzdata

# Set environment variables
ENV LC_ALL C.UTF-8
ENV TZ Asia/Jakarta

# Install cloudflare tunnel (uncomment and modify this part as needed)

# Install Node.js
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 18.13.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | sh \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

CMD ["neofetch"]
