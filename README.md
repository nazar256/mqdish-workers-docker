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

- [dispatch](scripts/dispatch) - simply passes all it's arguments as is as STDIN to `mqdish`. But could also pass arguments to `mqdish` as well.

```bash
dispatch --topic "test" -- "echo 'Hello'"
# results in:
# echo 'Hello' | mqdish --topic "test"
```

