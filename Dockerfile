# Global ARGs
ARG BASE_IMAGE=ghcr.io/nazar256/mqdish-consumer:latest
ARG TARGETPLATFORM
ARG MQDISH_VERSION=1.2.0
ARG FF_VERSION=7.1
ARG ALPINE_VERSION=3.21
ARG FDK_AAC_VERSION=2.0.3

FROM alpine:${ALPINE_VERSION} as builder

ARG FDK_AAC_VERSION
ARG FF_VERSION
ARG MQDISH_VERSION
ARG TARGETPLATFORM

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    pkgconfig \
    yasm \
    nasm \
    tar \
    xz \
    wget \
    autoconf \
    automake \
    libtool \
    x264-dev \
    x265-dev \
    libvpx-dev \
    opus-dev \
    lame-dev \
    libvorbis-dev \
    libtheora-dev \
    libass-dev \
    libwebp-dev \
    freetype-dev \
    sdl2-dev \
    zlib-dev \
    libdrm-dev

# Build and install libfdk-aac
WORKDIR /tmp/fdk-aac
RUN wget https://github.com/mstorsjo/fdk-aac/archive/v${FDK_AAC_VERSION}.tar.gz && \
    tar xf v${FDK_AAC_VERSION}.tar.gz && \
    cd fdk-aac-${FDK_AAC_VERSION} && \
    autoreconf -fiv && \
    ./configure --prefix=/usr --enable-shared && \
    make -j$(nproc) && \
    make install

# Download and build FFmpeg
WORKDIR /tmp/ffmpeg
RUN wget https://ffmpeg.org/releases/ffmpeg-${FF_VERSION}.tar.xz && \
    tar xf ffmpeg-${FF_VERSION}.tar.xz && \
    cd ffmpeg-${FF_VERSION} && \
    ./configure \
        --prefix=/usr \
        --enable-gpl \
        --enable-nonfree \
        --enable-libfdk-aac \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libvpx \
        --enable-libopus \
        --enable-libmp3lame \
        --enable-libvorbis \
        --enable-libtheora \
        --enable-libass \
        --enable-libwebp \
        --enable-libfreetype \
        --enable-sdl2 \
        --disable-debug \
        --disable-doc \
        --extra-cflags="-I/usr/include" \
        --extra-ldflags="-L/usr/lib" && \
    make -j$(nproc) && \
    make install DESTDIR=/tmp/ffmpeg-build


# Map Docker architecture to release artifact architecture
RUN case "${TARGETPLATFORM}" in \
        "linux/amd64")  ARCH="x86_64-unknown-linux-musl" ;; \
        "linux/arm64/v8")  ARCH="aarch64-unknown-linux-musl" ;; \
        "linux/arm64")  ARCH="aarch64-unknown-linux-musl" ;; \
        "linux/arm/v7")  ARCH="armv7-unknown-linux-musleabihf" ;; \
        "linux/ppc64le")  ARCH="powerpc64le-unknown-linux-gnu" ;; \
        *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Downloading mqdish for ${ARCH}" && \
    wget -O /tmp/mqdish.tar.gz "https://github.com/nazar256/mqdish/releases/download/${MQDISH_VERSION}/mqdish.${ARCH}.tar.gz" && \
    cd /tmp && \
    tar xzf mqdish.tar.gz && \
    cp target/${ARCH}/release/mqdish /usr/local/bin/ && \
    rm -rf target mqdish.tar.gz && \
    chmod +x /usr/local/bin/mqdish


# Second stage
FROM --platform=${TARGETPLATFORM} ${BASE_IMAGE}

# Redeclare ARGs after FROM
# ARG TARGETPLATFORM
# ARG MQDISH_VERSION

# Install runtime dependencies that match the build dependencies
RUN apk add --no-cache curl \
    jq yq imagemagick exiftool \
    # x264-libs \
    # x265-libs \
    # libvpx \
    # opus \
    # lame \
    # libvorbis \
    # libtheora \
    # libass \
    # libwebp \
    # freetype \
    # sdl2 \
    # libdrm \
    # libstdc++ \
    # libgcc \
    p7zip \
    libarchive-tools \
    unzip \
    rclone \
    bash && \
    addgroup -g 10000 -S mqdish && \
    adduser -S mqdish -G mqdish -u 10000 && \
    mkdir -p /tmp/mqdish && \
    chown -R 10000:10000 /tmp/mqdish

# Copy FFmpeg binaries and libraries from builder
COPY --from=builder /tmp/ffmpeg-build/usr/bin/ffmpeg /usr/bin/
COPY --from=builder /tmp/ffmpeg-build/usr/bin/ffprobe /usr/bin/
COPY --from=builder /tmp/ffmpeg-build/usr/lib/* /usr/lib/
COPY --from=builder /usr/lib/* /usr/lib/
COPY --from=builder /usr/local/bin/mqdish /usr/local/bin/mqdish
COPY ./scripts/* /usr/local/bin

ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib
WORKDIR /tmp/
VOLUME /tmp/
USER 10000
