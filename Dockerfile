ARG BASE_IMAGE=ghcr.io/nazar256/mqdish-consumer:latest
ARG TARGETPLATFORM

FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE}
RUN apk add --no-cache curl cadaver jq imagemagick ffmpeg p7zip samba-client openssh
USER 10000  # use non-root user