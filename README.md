# MqDiSh Docker

A docker container for MqDiSh consumer. Also includes `mqdish` CLI tool for dispatching jobs by the consumer.

With these tools MqDish shines and basically was the reason I developed it. Example use-case is to automatically extract archives, convert photos, audio and video files in directories recursively using distributed workers across multiple machines available (for instance, laptops, desktops, RaspberryPI and VPS machines). Thus I can keep my gallery archive in the most efficient format, save storage and use all available machines for that.

## Installation

The scripts in this repository are designed to be used from PATH. You can opy/symlink the scripts to a directory that's already in your PATH:
```bash
# Option 1: Copy
sudo cp scripts/* /usr/local/bin/

# Option 2: Symlink
sudo ln -s "$(pwd)/scripts/"* /usr/local/bin/
```

## Included tools

### FFmpeg

FFmpeg is built from source as the latest (current) version 7.1 with libfdk-aac 2.0.3 support.

### Alpine packages

To see installed packages refer to the [Dockerfile](Dockerfile).

### Scripts

- [lsfiles](scripts/lsfiles) - lists directory passing the file path to another command:

```bash
lsfiles --recursive "~/Pictures" "echo"
# results in:
# ~/Pictures/1.jpg
# ~/Pictures/2.jpg
# ~/Pictures/sub_dir/1.jpg

lsfiles "~/Pictures" "echo"
# results in:
# ~/Pictures/1.jpg
# ~/Pictures/2.jpg

lsfiles "/home/user/Pictures" "echo"
# results in:
# /home/user/Pictures/1.jpg
# /home/user/Pictures/2.jpg
```

- [convert-image](scripts/convert-image) - converts a single image to another format with detailed logging:

```bash
convert-image --quality 80 --output-format heic --trashbin ~/trash "image.jpg"
# Converts image.jpg to image.heic with 80% quality
# After successful conversion, moves original to ~/trash/image.jpg
# Provides detailed logging of the conversion process
```

- [recode-images](scripts/recode-images) - finds images in a directory and dispatches conversion jobs:

```bash
# Basic usage - convert all images to HEIC with 80% quality
recode-images --recursive --quality 80 --output-format heic "~/Pictures"

# Convert only large images and move originals to trash
recode-images --recursive --quality 80 --min-size 1000x1000 --output-format heic --trashbin ~/trash "~/Pictures"

# The script will:
# 1. Find all images in the specified directory
# 2. Skip files that:
#    - Are already in the target format
#    - Are not valid images
#    - Are smaller than --min-size (if specified)
# 3. For each valid image, dispatch a convert-image job using mqdish
# 4. The consumer will execute each job, converting images and moving originals
#    to the trash directory (if specified) only after successful conversion
```

- [convert-video](scripts/convert-video) - converts a single video to HEVC/x265 format with customizable settings:

```bash
# Basic usage with default high-quality settings
convert-video --trashbin ~/trash "video.mp4"
# Default settings:
#  - HEVC/x265 codec with preset=slower
#  - CRF=28 for good quality/size balance
#  - AAC audio with HE-AAC v2 profile and vbr quality 3
#  - Copies all subtitles and preserves metadata

# Custom FFmpeg arguments for specific needs
convert-video --ffmpeg-args "-c:v libx265 -preset veryslow -crf 23 -c:a libfdk_aac -vbr 5" --trashbin ~/trash "video.mp4"
# Uses custom FFmpeg settings:
#  - veryslow preset for better compression
#  - CRF 23 for higher quality
#  - Higher audio bitrate (vbr 5)
```

- [recode-videos](scripts/recode-videos) - finds videos in a directory and dispatches conversion jobs:

```bash
# Basic usage - convert all videos with default settings
recode-videos --recursive --trashbin ~/trash "~/Videos"

# Custom encoding settings for higher quality
recode-videos --recursive --ffmpeg-args "-c:v libx265 -preset slower -crf 18 -c:a libfdk_aac -profile:a aac_he_v2 -vbr 3 -c:s copy -tag:v hvc1
" --trashbin ~/trash "~/Videos"

# The script will:
# 1. Find all videos in the specified directory
# 2. Skip files that:
#    - Are already HEVC encoded
#    - Are not videos (by extension)
# 3. For each valid video, dispatch a convert-video job using mqdish
# 4. The consumer will execute each job, converting videos and moving originals
#    to the trash directory (if specified) only after successful conversion
#
# Default FFmpeg arguments:
# -c:v libx265 -preset slower -crf 28 -c:a libfdk_aac -profile:a aac_he_v2 -vbr 3 -c:s copy -tag:v hvc1
```

- [extract-archive](scripts/extract-archive) - extracts a single archive with smart directory detection:

```bash
extract-archive --trashbin ~/trash "archive.zip"
# Extracts archive.zip with smart directory detection:
#  - If archive contains single root folder: extracts to current directory
#  - If archive contains multiple items: creates directory named like archive
# Examples:
#  - archive.zip containing folder "data/" -> extracts to ./data/
#  - archive.zip containing multiple files -> extracts to ./archive/
# After successful extraction, moves original to ~/trash/archive.zip
```

- [extract-archives](scripts/extract-archives) - finds archives in a directory and dispatches extraction jobs:

```bash
# Basic usage - extract all archives in current directory
extract-archives --trashbin ~/trash "."

# Extract all archives recursively
extract-archives --recursive --trashbin ~/trash "~/Downloads"

# The script will:
# 1. Find all archives in the specified directory
# 2. Skip files that are not archives (by extension)
# 3. For each archive, dispatch an extract-archive job using mqdish
# 4. The consumer will execute each job:
#    - Analyze archive contents
#    - Create target directory if needed
#    - Extract with smart directory detection
#    - Move original to trash if specified
#
# Supported formats:
# - zip, 7z, rar
# - tar, gz, bz2, xz
# - tgz, tbz2, txz
```

- [convert-audio](scripts/convert-audio) - converts a single audio file to AAC format with customizable settings:

```bash
# Basic usage with default high-efficiency settings
convert-audio --trashbin ~/trash "audio.mp3"
# Default settings:
#  - AAC codec with HE-AAC profile
#  - VBR mode with quality 2
#  - Optimized for low bitrate while maintaining good quality

# Custom FFmpeg arguments for different quality/profile
convert-audio --ffmpeg-args "-c:a libfdk_aac -profile:a aac_low -b:a 256k" --trashbin ~/trash "audio.mp3"
# Uses custom FFmpeg settings:
#  - AAC-LC profile for higher quality
#  - Fixed bitrate of 256k
```

- [recode-audios](scripts/recode-audios) - finds audio files in a directory and dispatches conversion jobs:

```bash
# Basic usage - convert all audio files with default settings
recode-audios --recursive --trashbin ~/trash "~/Music"

# Custom encoding settings for higher quality
recode-audios --recursive --ffmpeg-args "-c:a libfdk_aac -profile:a aac_low -b:a 256k" --trashbin ~/trash "~/Music"

# The script will:
# 1. Find all audio files in the specified directory
# 2. Skip files that:
#    - Are already in m4a/aac format
#    - Are not audio files (by extension)
# 3. For each valid audio file, dispatch a convert-audio job using mqdish
# 4. The consumer will execute each job, converting audio and moving originals
#    to the trash directory (if specified) only after successful conversion
#
# Default FFmpeg arguments:
# -vn -c:a libfdk_aac -profile:a aac_he -vbr 2
#
# Supported formats:
# - mp3, wav, wma, ogg
# - flac, aiff, opus, ape
# All files will be converted to m4a format
```

## Real use case

Here are some examples of real use case usage with samba NAS storage mounted to containers in Docker Swarm cluster built on Tailscale:

### Unpack all archives detecting directories automatically

```bash
dispatch --topic mqdish-single -- extract-archives --recursive --trashbin /mnt/trashbin/aria-downloads /mnt/aria-downloads
```

### Convert all images to HEIC with 30% quality

```bash
dispatch --topic mqdish-singlethreaded -- recode-images --recursive --quality 30 --output-format heic --trashbin /mnt/trashbin/gallery /mnt/gallery
```

### Convert all videos to HEVC with custom settings

```bash
dispatch --topic mqdish-multithreaded -- recode-videos --recursive --ffmpeg-args "-c:v libx265 -preset veryslow -crf 16 -c:a libfdk_aac -profile:a aac_he_v2 -vbr 1" --trashbin /mnt/trashbin/gallery /mnt/gallery
```

### Convert all audio to AAC with custom settings

```bash
dispatch --topic mqdish-singlethreaded -- recode-audios --recursive --ffmpeg-args "-c:a libfdk_aac -profile:a aac_he_v2 -vbr 2" --trashbin /mnt/trashbin/audiobooks /mnt/audiobooks
```
