ARG BASE_IMAGE=ghcr.io/nazar256/mqdish-consumer:latest
ARG PUID=10000
ARG PGID=10000

FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE}
RUN apk add --no-cache curl jq yq imagemagick exiftool ffmpeg p7zip rclone && \
    addgroup -g ${PGID} -S mqdish && \
    adduser -S mqdish -G mqdish -u ${PUID} && \
    mkdir -p /tmp/mqdish && \
    chown -R ${PUID}:${PGID} /tmp/mqdish
WORKDIR /tmp/mqdish
VOLUME /tmp/mqdish
USER ${PUID}