ARG BASE_IMAGE=ghcr.io/nazar256/mqdish-consumer:latest

FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE}
COPY ./scripts/* /usr/local/bin
RUN apk add --no-cache curl jq yq imagemagick exiftool ffmpeg p7zip rclone bash && \
    addgroup -g 10000 -S mqdish && \
    adduser -S mqdish -G mqdish -u 10000 && \
    mkdir -p /tmp/mqdish && \
    chown -R 10000:10000 /tmp/mqdish
WORKDIR /tmp/mqdish
VOLUME /tmp/mqdish
USER 10000