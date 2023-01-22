# Os base using own
FROM ghcr.io/troublescoope/docker:latest

ARG DEBIAN_FRONTEND=noninteractive
# Upgrade & Install mega builder tools
RUN sed -i -e's/ main/ main contrib non-free/g' /etc/apt/sources.list &&
    apt-get update -y && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    gcc g++ clang make autoconf parallel pv jq\
    libcurl4-openssl-dev libsqlite3-dev zlib1g-dev \
    libssl-dev libcrypto++-dev libc-ares-dev \
    libfreeimage-dev libraw-dev libsodium-dev \
    libudev-dev automake libtool python3-dev p7zip-rar

# Set working dir 
RUN mkdir -p /opt/venv
WORKDIR /opt/venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install dependencies 
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip3 install wheel

ENV PYTHONWARNINGS=ignore
RUN echo -e "\e[32m[INFO]: Building and Installing MegaSdkC++.\e[0m" && \
    git clone https://github.com/meganz/sdk.git ~/home/sdk && \
    cd ~/home/sdk && rm -rf .git && \
    autoupdate -fIv && ./autogen.sh && \
    ./configure CFLAGS='-fpermissive' CXXFLAGS='-fpermissive' CPPFLAGS='-fpermissive' CCFLAGS='-fpermissive' \
    --disable-silent-rules --enable-python --with-sodium --disable-examples --with-python3 && \
    make -j$(nproc --all) && \
    cd bindings/python/ && \
    python3 setup.py bdist_wheel && \
    cd dist && ls && \
    pip3 install *.whl

RUN pip3 install -r requirements.txt

RUN apt-get update  && apt-get upgrade -y \
    && apt-get install -y ffmpeg mediainfo aria2 \
    libmagic-dev \
    qbittorrent-nox && npm install -g localtunnel kill-port \
    && sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

CMD ["python3"]
