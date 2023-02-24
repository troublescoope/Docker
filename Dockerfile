# First stage: Build stage
FROM python:3.11-alpine AS builder

RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev \
    py3-pip \
    git \
    build-base \
    autoconf \
    automake \
    libtool \
    libc-dev \
    make \
    cmake \
    zlib-dev \
    libcrypto1.1 \
    libcurl \
    libcurl-dev \
    libsodium-dev \
    libressl-dev \
    libc-ares-dev \
    libfreeimage-dev \
    libraw-dev

WORKDIR /app

COPY requirements.txt .

RUN python3 -m venv venv \
    && venv/bin/pip install --upgrade pip \
    && venv/bin/pip install wheel \
    && venv/bin/pip install -r requirements.txt \
    && venv/bin/pip wheel --wheel-dir=./wheels -r requirements.txt

RUN git clone -b release/v4.8.0 https://github.com/meganz/sdk.git \
    && cd sdk \
    && autoupdate -fIv \
    && ./autogen.sh \
    && ./configure CFLAGS='-fpermissive' CXXFLAGS='-fpermissive' CPPFLAGS='-fpermissive' CCFLAGS='-fpermissive' --disable-silent-rules --enable-python --with-sodium --disable-examples --with-python3 \
    && make -j$(nproc) \
    && cd bindings/python \
    && python3 setup.py bdist_wheel \
    && cp dist/*.whl /app/wheels \
    && cd /app \
    && rm -rf sdk

# Second stage: Production stage
FROM python:3.11-alpine

RUN apk add --no-cache \
    libffi \
    openssl \
    ca-certificates \
    ffmpeg \
    mediainfo \
    aria2 \
    libmagic \
    qbittorrent-nox \
    nodejs \
    npm \
    && npm install -g localtunnel kill-port

WORKDIR /app

COPY --from=builder /app/venv /app/venv
COPY --from=builder /app/wheels /app/wheels
COPY --from=builder /app/requirements.txt .

RUN python3 -m venv venv \
    && venv/bin/pip install --upgrade pip \
    && venv/bin/pip install wheel \
    && venv/bin/pip install --no-index --find-links=./wheels -r requirements.txt \
    && rm -rf ./wheels

CMD ["python3"]

# Support multiarch
# linux/amd64
# linux/arm64
# linux/arm/v7
# Reference: https://docs.docker.com/buildx/working-with-buildx/
# Run command: docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t your-image-name .
