# Os base using own
FROM ghcr.io/troublescoope/docker:latest

ARG DEBIAN_FRONTEND=noninteractive
# Upgrade & Install mega builder tools
RUN apt-get update  && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    gcc g++ clang make autoconf parallel pv jq\
    libcurl4-openssl-dev libsqlite3-dev zlib1g-dev \
    libssl-dev libcrypto++-dev libc-ares-dev \
    libfreeimage-dev libraw-dev libsodium-dev \
    libudev-dev automake libtool python3-dev swig

# Install dependencies 
RUN pip install --upgrade pip
RUN pip3 install wheel

ENV PYTHONWARNINGS=ignore
RUN echo -e "\e[32m[INFO]: Building and Installing MegaSdkC++.\e[0m" && \
    git clone https://github.com/meganz/sdk.git /sdk && \
    cd /sdk && rm -rf .git && \
    autoupdate -fIv && ./autogen.sh && \
    ./configure CFLAGS='-fpermissive' CXXFLAGS='-fpermissive' CPPFLAGS='-fpermissive' CCFLAGS='-fpermissive' \
    --disable-silent-rules --enable-python --with-sodium --disable-examples --with-python3 && \
    make -j$(nproc --all) && \
    cd bindings/python/ && \
    python3 setup.py bdist_wheel && \
    cd dist && ls && \
    pip3 install *.whl && cd ~ && rm -rf /sdk

SHELL ["/bin/bash", "-c"]