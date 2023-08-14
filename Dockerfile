# Use Alpine as the base image
FROM alpine:latest

# LABELS
LABEL org.opencontainers.image.source="https://github.com/troublescope/Docker"
LABEL org.opencontainers.image.description="Personal docker base."

# Upgrade & packages
RUN apk update && apk upgrade && \
    apk add --no-cache ca-certificates autoconf bash git wget curl p7zip swig \
    python3 python3-dev py3-pip py3-virtualenv tzdata 
    

# Set environment variables
ENV LC_ALL C.UTF-8
ENV TZ Asia/Jakarta

SHELL ["/bin/bash", "neofetch"]
