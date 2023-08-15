# Use a specific base image
FROM --platform=$BUILDPLATFORM ghcr.io/troublescope/docker:latest

# Set build arguments
ARG BUILDPLATFORM
ENV VENV_PATH="/venv/bin"

# Set working directory
WORKDIR /usr/src/app

# Set permissions for the working directory
RUN chmod -R 777 /usr/src/app && \
    chmod -R +x /usr/src/app && \
    chmod -R 705 /usr/src/app

# Install basic packages
RUN apk update && apk upgrade && \
    apk add --upgrade --no-cache \
    sudo py3-wheel musl-dev musl \
    busybox musl-locales github-cli lshw \
    qbittorrent-nox py3-lxml aria2 p7zip \
    xz curl pv jq ffmpeg parallel \
    git make g++ gcc automake zip unzip \
    autoconf speedtest-cli mediainfo bash \
    musl-utils tzdata gcompat libmagic \
    libffi-dev libffi \
    dpkg cmake icu-data-full apk-tools \
    coreutils bash-completion bash-doc

# Set shell to bash
SHELL ["/bin/bash", "-c"]

# Install build tools
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk add --upgrade --no-cache \
    libtool curl-dev libsodium-dev c-ares-dev sqlite-dev freeimage-dev swig boost-dev \
    libpthread-stubs zlib zlib-dev libpq-dev clang clang-dev ccache gettext gettext-dev \
    gawk crypto++ crypto++-dev libjpeg-turbo-dev 

# Build and Install MegaSdkC++
ENV PYTHONWARNINGS=ignore
RUN git clone -b release/v4.8.0 https://github.com/meganz/sdk.git ~/home/sdk && \
    cd ~/home/sdk && rm -rf .git && \
    autoupdate -fIv && ./autogen.sh && \
    ./configure CFLAGS='-fpermissive' CXXFLAGS='-fpermissive' CPPFLAGS='-fpermissive' CCFLAGS='-fpermissive' \
    --disable-silent-rules --enable-python --with-sodium --disable-examples --with-python3 && \
    make -j$(nproc --all) && \
    cd bindings/python/ && \
    python3 setup.py bdist_wheel && \
    cd dist && ls && \
    pip install *.whl
    

# Run Final Apk Update
RUN apk update && apk upgrade && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Setup Language Environments
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"
RUN echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile.d/locale.sh && \
    sed -i 's|LANG=C.UTF-8|LANG=en_US.UTF-8|' /etc/profile.d/locale.sh && \
    cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Set shell to bash
SHELL ["/bin/bash", "-c", "source /$VENV_PATH/activate && $0 $@"]
