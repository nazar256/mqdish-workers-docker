# Global ARGs
ARG BASE_IMAGE_VERSION=latest
ARG TARGETPLATFORM
ARG MQDISH_VERSION=1.3.1
ARG RUSTY_WRENCHES_VERSION=1.0.0
ARG ALPINE_VERSION=latest
ARG FFMPEG_IMAGE_VERSION=latest

FROM ghcr.io/nazar256/ffmpeg:${FFMPEG_IMAGE_VERSION} AS ffmpeg

FROM alpine:${ALPINE_VERSION} AS mqdish-cli

ARG MQDISH_VERSION
ARG TARGETPLATFORM
ARG RUSTY_WRENCHES_VERSION

RUN case "${TARGETPLATFORM}" in \
        "linux/amd64")  RUST_TARGET="x86_64-unknown-linux-musl" ;; \
        "linux/386")  RUST_TARGET="i686-unknown-linux-musl" ;; \
        "linux/arm64/v8")  RUST_TARGET="aarch64-unknown-linux-musl" ;; \
        "linux/arm64")  RUST_TARGET="aarch64-unknown-linux-musl" ;; \
        "linux/arm/v7")  RUST_TARGET="armv7-unknown-linux-musleabihf" ;; \
        "linux/arm/v6")  RUST_TARGET="arm-unknown-linux-musleabi" ;; \
        "linux/ppc64le")  RUST_TARGET="powerpc64le-unknown-linux-gnu" ;; \
        "linux/s390x")  RUST_TARGET="s390x-unknown-linux-gnu" ;; \
        *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Downloading mqdish for ${RUST_TARGET}" && \
    wget -O /tmp/mqdish.tar.gz "https://github.com/nazar256/mqdish/releases/download/${MQDISH_VERSION}/mqdish.${RUST_TARGET}.tar.gz" && \
    cd /tmp && \
    tar xzf mqdish.tar.gz && \
    cp mqdish /usr/local/bin/ && \
    chmod +x /usr/local/bin/mqdish

RUN case "${TARGETPLATFORM}" in \
        "linux/amd64")  RUST_TARGET="x86_64-unknown-linux-musl" ;; \
        "linux/386")  RUST_TARGET="i686-unknown-linux-musl" ;; \
        "linux/arm64/v8")  RUST_TARGET="aarch64-unknown-linux-musl" ;; \
        "linux/arm64")  RUST_TARGET="aarch64-unknown-linux-musl" ;; \
        "linux/arm/v7")  RUST_TARGET="armv7-unknown-linux-musleabihf" ;; \
        "linux/arm/v6")  RUST_TARGET="arm-unknown-linux-musleabi" ;; \
        "linux/ppc64le")  RUST_TARGET="powerpc64le-unknown-linux-gnu" ;; \
        "linux/s390x")  RUST_TARGET="s390x-unknown-linux-gnu" ;; \
        *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Downloading rusty-wrenches for ${RUST_TARGET}" && \
    wget -O /tmp/rusty-wrenches.tar.gz "https://github.com/nazar256/rusty-wrenches/releases/download/${RUSTY_WRENCHES_VERSION}/rusty-wrenches.${RUST_TARGET}.tar.gz" && \
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
