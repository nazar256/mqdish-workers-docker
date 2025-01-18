ARG BASE_IMAGE=ghcr.io/nazar256/mqdish-consumer:latest
ARG TARGETPLATFORM

FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE}

# Need to redeclare ARG after FROM to make it available in this stage
ARG TARGETPLATFORM
ARG VERSION=latest

COPY ./scripts/* /usr/local/bin
RUN apk add --no-cache curl jq yq imagemagick exiftool ffmpeg p7zip rclone bash && \
    addgroup -g 10000 -S mqdish && \
    adduser -S mqdish -G mqdish -u 10000 && \
    mkdir -p /tmp/mqdish && \
    chown -R 10000:10000 /tmp/mqdish

# Map Docker architecture to release artifact architecture

 RUN case "${TARGETPLATFORM}" in \
    "linux/amd64")  ARCH="x86_64-unknown-linux-musl" ;; \
    "linux/arm64/v8")  ARCH="aarch64-unknown-linux-musl" ;; \
    "linux/arm/v7")  ARCH="armv7-unknown-linux-musleabihf" ;; \
    "linux/ppc64le")  ARCH="powerpc64le-unknown-linux-gnu" ;; \
    *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Downloading mqdish for ${ARCH}" && \
    curl -L -o /tmp/mqdish.tar.gz "https://github.com/nazar256/mqdish/releases/download/${VERSION}/mqdish.${ARCH}.tar.gz" && \
    tar xzf /tmp/mqdish.tar.gz -C /usr/local/bin && \
    rm /tmp/mqdish.tar.gz && \
    chmod +x /usr/local/bin/mqdish
RUN case "${TARGETPLATFORM}" in \
        "linux/amd64")  ARCH="x86_64-unknown-linux-musl" ;; \
        "linux/arm64/v8")  ARCH="aarch64-unknown-linux-musl" ;; \
        "linux/arm/v7")  ARCH="armv7-unknown-linux-musleabihf" ;; \
        "linux/ppc64le")  ARCH="powerpc64le-unknown-linux-gnu" ;; \
        *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Downloading mqdish for ${ARCH}" && \
    curl -L -o /tmp/mqdish.tar.gz "https://github.com/nazar256/mqdish/releases/download/${VERSION}/mqdish.${ARCH}.tar.gz" && \
    tar xzf /tmp/mqdish.tar.gz -C /usr/local/bin && \
    rm /tmp/mqdish.tar.gz && \
    chmod +x /usr/local/bin/mqdish
WORKDIR /tmp/mqdish
VOLUME /tmp/mqdish
USER 10000