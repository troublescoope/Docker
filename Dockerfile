# Stage 1: Build Mega SDK
FROM ubuntu:22.04 as build_mega_sdk

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Jakarta

# Set working directory
WORKDIR /home/sdk/

# Install required packages and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends --quiet --fix-missing \
        autoconf \
        automake \
        bash \
        busybox \
        libc-ares-dev \
        ca-certificates \
        ccache \
        clang \
        coreutils \
        crypto++ \
        libcrypto++-dev \
        curl \
        libcurl4-openssl-dev \
        g++ \
        gcc \
        gawk \
        gettext \
        git \
        icu-devtools \
        jq \
        libc-dev \
        libffi-dev \
        libjpeg-dev \
        libmagic-dev \
        libpq-dev \
        libpthread-stubs0-dev \
        libtool \
        libsodium-dev \
        linux-headers-generic \
        lshw \
        make \
        mediainfo \
        musl \
        musl-dev \
        libssl-dev \
        parallel \
        python3-dev \
        python3-distutils \
        libsqlite3-dev \
        swig \
        wget \
        xz-utils \
        zlib1g-dev && \
    git clone --depth=1 -b release/v4.8.0 https://github.com/meganz/sdk.git /home/sdk/ && \
    cd /home/sdk && rm -rf .git && \
    autoupdate -fIv && ./autogen.sh && \
    ./configure CFLAGS='-fpermissive' CXXFLAGS='-fpermissive' CPPFLAGS='-fpermissive' CCFLAGS='-fpermissive' \
    --disable-silent-rules --enable-python --with-sodium --disable-examples --with-python3 --without-freeimage && \
    make -j$(nproc --all) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: Final Image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Jakarta

# Install required packages and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends --quiet --fix-missing \
        aria2 \
        bash \
        ca-certificates \
        curl \
        ffmpeg \
        libcrypto++-dev \
        libcurl4-openssl-dev \
        gcc \
        git \
        jq \
        libc-dev \
        libmagic-dev \
        linux-headers-generic \
        mediainfo \
        libssl-dev \
        parallel \
        p7zip \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-dev \
        pv \
        qbittorrent-nox \
        rclone \
        libsqlite3-dev \
        tzdata \
        unzip \
        wget \
        xz-utils \
        zip \
        zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Playwright
RUN pip3 install --upgrade pip && \
    pip3 install playwright && \
    playwright install && \
    playwright install-deps

# Set locale and timezone
RUN echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile.d/locale.sh && \
    sed -i 's|LANG=C.UTF-8|LANG=en_US.UTF-8|' /etc/profile.d/locale.sh && \
    ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

# Copy MegaSdkC++ from build_mega_sdk
COPY --from=build_mega_sdk /home/sdk/ /home/sdk/
RUN cd /home/sdk/bindings/python && \
    python3 setup.py bdist_wheel && \
    cd dist && pip install --no-cache-dir *.whl

# Set shell to Bash
SHELL ["/bin/bash", "-c"]

# Default command
CMD ["bash"]
