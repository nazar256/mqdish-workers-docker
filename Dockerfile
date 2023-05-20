ARG BASE_IMAGE=ghcr.io/nazar256/mqdish-consumer:latest

FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE}
RUN apk add --no-cache curl jq yq imagemagick exiftool ffmpeg p7zip rclone
VOLUME /tmp/mqdish
WORKDIR /tmp/mqdish
USER 10000  # use non-root user