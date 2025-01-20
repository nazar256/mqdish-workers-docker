# MqDiSh Docker

A docker container for MqDiSh consumer. Also includes `mqdish` CLI tool for dispatching jobs by the consumer.

## Installation

The scripts in this repository are designed to be used from PATH. You can:

1. Copy/symlink the scripts to a directory that's already in your PATH:
```bash
# Option 1: Copy
sudo cp scripts/* /usr/local/bin/

# Option 2: Symlink
sudo ln -s "$(pwd)/scripts/"* /usr/local/bin/
```

## Included tools

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

- [convert-video](scripts/convert-video) - converts a single video to HEVC/x265 format with high-quality settings:

```bash
convert-video --quality 28 --trashbin ~/trash "video.mp4"
# Converts video.mp4 to video.mkv using HEVC/x265 codec
# Uses high quality settings:
#  - preset=slower for better compression
#  - CRF=28 (adjustable with --quality, range 0-51, lower is better)
#  - AAC audio with quality=3
#  - Copies all subtitles and preserves metadata
# After successful conversion, moves original to ~/trash/video.mp4
```

- [recode-videos](scripts/recode-videos) - finds videos in a directory and dispatches conversion jobs:

```bash
# Basic usage - convert all videos to HEVC with default quality (CRF 28)
recode-videos --recursive --trashbin ~/trash "~/Videos"

# Convert with higher quality (lower CRF means higher quality)
recode-videos --recursive --quality 23 --trashbin ~/trash "~/Videos"

# The script will:
# 1. Find all videos in the specified directory
# 2. Skip files that:
#    - Are already HEVC encoded
#    - Are not videos (by extension)
# 3. For each valid video, dispatch a convert-video job using mqdish
# 4. The consumer will execute each job, converting videos and moving originals
#    to the trash directory (if specified) only after successful conversion
#
# Quality (CRF) guide:
# - Range: 0-51 (lower number = higher quality, larger file)
# - 28 is the default, good balance of quality and size
# - 23-28 is usually visually lossless
# - 18-23 for high-quality archival
# - Below 18 is usually overkill
```

- [convert-audio](scripts/convert-audio) - converts a single audio file to AAC format with high-efficiency settings:

```bash
convert-audio --quality 2 --trashbin ~/trash "audio.mp3"
# Converts audio.mp3 to audio.m4a using AAC codec
# Uses high-efficiency settings:
#  - HE-AAC v2 profile for maximum compression
#  - VBR mode with quality 2 (adjustable with --quality, range 1-5)
#  - Optimized for low bitrate while maintaining good quality
# After successful conversion, moves original to ~/trash/audio.mp3
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
# Supported formats (with p7zip):
# - zip, 7z, rar (with unrar)
# - tar, gz, bz2, xz
# - tgz, tbz2, txz
```

- [recode-audios](scripts/recode-audios) - finds audio files in a directory and dispatches conversion jobs:

```