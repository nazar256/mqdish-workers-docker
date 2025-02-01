# Global ARGs
ARG BASE_IMAGE_VERSION=latest
ARG TARGETPLATFORM
ARG MQDISH_VERSION=1.3.0
ARG RUSTY_WRENCHES_VERSION=1.0.0
ARG ALPINE_VERSION=3.18
ARG FFMPEG_IMAGE_VERSION=latest

FROM ghcr.io/nazar256/ffmpeg:${FFMPEG_IMAGE_VERSION} AS ffmpeg

FROM alpine:${ALPINE_VERSION} AS mqdish-cli

ARG MQDISH_VERSION
ARG TARGETPLATFORM

RUN case "${TARGETPLATFORM}" in \
        "linux/amd64")  ARCH="x86_64-unknown-linux-musl" ;; \
        "linux/386")  ARCH="i686-unknown-linux-musl" ;; \
        "linux/arm64/v8")  ARCH="aarch64-unknown-linux-musl" ;; \
        "linux/arm64")  ARCH="aarch64-unknown-linux-musl" ;; \
        "linux/arm/v7")  ARCH="armv7-unknown-linux-musleabihf" ;; \
        "linux/arm/v6")  ARCH="arm-unknown-linux-musleabi" ;; \
        "linux/ppc64le")  ARCH="powerpc64le-unknown-linux-gnu" ;; \
        "linux/s390x")  ARCH="s390x-unknown-linux-gnu" ;; \
        *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Downloading mqdish for ${ARCH}" && \
    wget -O /tmp/mqdish.tar.gz "https://github.com/nazar256/mqdish/releases/download/${MQDISH_VERSION}/mqdish.${ARCH}.tar.gz" && \
    cd /tmp && \
    tar xzf mqdish.tar.gz && \
    cp mqdish /usr/local/bin/ && \
    chmod +x /usr/local/bin/mqdish

RUN case "${TARGETPLATFORM}" in \
        "linux/amd64")  ARCH="x86_64-unknown-linux-musl" ;; \
        "linux/386")  ARCH="i686-unknown-linux-musl" ;; \
        "linux/arm64/v8")  ARCH="aarch64-unknown-linux-musl" ;; \
        "linux/arm64")  ARCH="aarch64-unknown-linux-musl" ;; \
        "linux/arm/v7")  ARCH="armv7-unknown-linux-musleabihf" ;; \
        "linux/arm/v6")  ARCH="arm-unknown-linux-musleabi" ;; \
        "linux/ppc64le")  ARCH="powerpc64le-unknown-linux-gnu" ;; \
        "linux/s390x")  ARCH="s390x-unknown-linux-gnu" ;; \
        *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Downloading rusty-wrenches for ${ARCH}" && \
    wget -O /tmp/rusty-wrenches.tar.gz "https://github.com/nazar256/rusty-wrench/releases/download/${RUSTY_WRENCHES_VERSION}/rusty-wrench.${ARCH}.tar.gz" && \
    cd /tmp && \
    tar xzf rusty-wrenches.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/*

# Release stage
FROM ghcr.io/nazar256/mqdish-consumer:${BASE_IMAGE_VERSION}

# Install runtime dependencies that match the build dependencies
RUN apk add --no-cache curl \
    jq yq imagemagick exiftool \
    p7zip \
    libarchive-tools \
    unzip \
    rclone \
    bash && \
    addgroup -g 10000 -S mqdish && \
    adduser -S mqdish -G mqdish -u 10000 && \
    mkdir -p /tmp/mqdish && \
    chown -R 10000:10000 /tmp/mqdish

# Copy FFmpeg and mqdish binaries and libraries from other stages
COPY --from=ffmpeg /usr/bin/ffmpeg /usr/bin/
COPY --from=ffmpeg /usr/bin/ffprobe /usr/bin/
COPY --from=ffmpeg /usr/lib/* /usr/lib/
COPY --from=ffmpeg /usr/local/lib/lib* /usr/local/lib/
COPY --from=mqdish-cli /usr/local/bin/mqdish /usr/local/bin/mqdish
COPY ./scripts/* /usr/local/bin

ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib

WORKDIR /tmp/
VOLUME /tmp/
USER 10000
