ARG BASE_IMAGE=ghcr.io/nazar256/mqdish-consumer:latest

FROM ${BASE_IMAGE}
RUN apk add --no-cache curl cadaver jq imagemagick ffmpeg p7zip samba-client openssh