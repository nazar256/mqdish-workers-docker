ARG BASE_IMAGE=ghcr.io/nazar256/mqdish-consumer:latest

FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE}
RUN apk add --no-cache curl jq yq imagemagick exiftool ffmpeg p7zip rclone && \
    addgroup -g 10000 -S mqdish && \
    adduser -S mqdish -G mqdish -u 10000 && \
    mkdir -p /tmp/mqdish && \
    chown -R mqdish:mqdish /tmp/mqdish
WORKDIR /tmp/mqdish
VOLUME /tmp/mqdish
USER mqdish  # use non-root user