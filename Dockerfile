# Use a specific base image
FROM python:3.11-alpine as build


# Set working directory
WORKDIR /home/sdk/

# Update and install packages
RUN apk update && apk upgrade && \
    apk add --upgrade --no-cache \
        apache2-utils \
        autoconf \
        automake \
        bash \
        boost-dev \
        busybox \
        c-ares-dev \
        ca-certificates \
        ccache \
        clang \
        clang-dev \
        coreutils \
        crypto++ \
        crypto++-dev \
        curl \
        curl-dev \
        g++ \
        gcc \
        gawk \
        gettext \
        gettext-dev \
        git \
        icu-data-full \
        jq \
        libc-dev \
        libffi \
        libffi-dev \
        libjpeg-turbo-dev \
        libmagic \
        libpq-dev \
        libpthread-stubs \
        libtool \
        libsodium-dev \
        linux-headers \
        lshw \
        make \
        mediainfo \
        musl \
        musl-dev \
        musl-locales \
        musl-utils \
        openssl-dev \
        parallel \
        py3-setuptools \
        py3-wheel \
        python3-dev \
        sqlite-dev \
        swig \
        wget \
        xz \
        zlib \
        zlib-dev

# Build and Install MegaSdkC++
ENV PYTHONWARNINGS=ignore
RUN git clone --depth=1 -b release/v4.8.0 https://github.com/meganz/sdk.git /home/sdk/ && \
    cd /home/sdk && rm -rf .git && \
    autoupdate -fIv && ./autogen.sh && \
    ./configure CFLAGS='-fpermissive' CXXFLAGS='-fpermissive' CPPFLAGS='-fpermissive' CCFLAGS='-fpermissive' \
    --disable-silent-rules --enable-python --with-sodium --disable-examples --with-python3 --without-freeimage && \
    make -j$(nproc --all)


# Stage 2: Install Packages and MegaSdkC++
FROM python:3.11-alpine

LABEL maintaer="Troublescope <tomy.prs25@gmail.com>"
LABEL description="Docker image for running an application with MegaSdkC++"
LABEL version="1.0"
LABEL release-date="2023-08-20"

# Update and install mandatory packages
RUN apk update && apk upgrade && \
    apk add --upgrade --no-cache \
        aria2 \
        bash \
        ca-certificates \
        curl \
        ffmpeg \
        crypto++-dev \
        curl-dev \
        gcc \
        git \
        jq \
        libc-dev \
        libmagic \
        linux-headers \
        lshw \
        mediainfo \
        openssl-dev \
        parallel \
        p7zip \
        py3-setuptools \
        py3-wheel \
        python3-dev \
        pv \
        qbittorrent-nox \
        rclone \
        sqlite-dev \
        tzdata \
        unzip \
        wget \
        xz \
        zip \
        zlib-dev

# Setup working directory
WORKDIR /app/

# Copy MegaSdkC++ from stage 1
COPY --from=build /home/sdk/ /home/sdk/
RUN cd /home/sdk/bindings/python && \
    python3 setup.py bdist_wheel && \
    cd dist && pip install --no-cache-dir *.whl

# Set locale
RUN echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile.d/locale.sh && \
    sed -i 's|LANG=C.UTF-8|LANG=en_US.UTF-8|' /etc/profile.d/locale.sh

# Set timezone to UTC
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

# Set shell to Bash
SHELL ["/bin/bash", "-c"]

# Default command 
CMD ["bash"]
