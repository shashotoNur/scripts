#!/bin/bash

# --- Softcode Subtitles and Clean Up Script (using FFmpeg) ---
# This script takes a single directory as input.
# It expects the directory to contain one video file (.mp4 or .mkv) and one subtitle file (.srt).
# It uses ffmpeg to softcode the subtitle into the video and saves the new .mkv file
# in the parent directory. It then moves the original directory to the trash.

# --- Prerequisites ---
# You must have 'ffmpeg' and 'trash-cli' installed on your system.
# On most systems, these can be installed with your package manager (e.g., apt, dnf, brew).

# Set the nullglob option to prevent unmatched globs from being treated as literals.
# This fixes the issue of the script counting non-existent files.
shopt -s nullglob

# Function to display usage information
show_usage() {
    echo "Usage: $0 <path_to_directory>"
    echo "The directory must contain exactly one .srt file and one video file (.mp4 or .mkv)."
    exit 1
}

# Check if a directory path was provided
if [[ -z "$1" ]]; then
    show_usage
fi

TARGET_DIR="$1"

# Check if the provided path is a directory
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: '$TARGET_DIR' is not a valid directory."
    exit 1
fi

# Get the absolute path of the target directory
ABSOLUTE_DIR=$(realpath "$TARGET_DIR")
PARENT_DIR=$(dirname "$ABSOLUTE_DIR")
DIR_NAME=$(basename "$ABSOLUTE_DIR")

# Change to the target directory to easily find the files
cd "$TARGET_DIR" || { echo "Error: Failed to change directory to $TARGET_DIR"; exit 1; }

# Find the video file (.mp4 or .mkv)
# With 'nullglob', this array will only contain matched files, preventing the previous error.
VIDEO_FILES=(*.mp4 *.mkv)
VIDEO_FILE_COUNT=${#VIDEO_FILES[@]}

# Find the subtitle file (.srt)
SRT_FILES=(*.srt)
SRT_FILE_COUNT=${#SRT_FILES[@]}

# Check if there is exactly one video and one srt file
if [[ $VIDEO_FILE_COUNT -ne 1 ]] || [[ $SRT_FILE_COUNT -ne 1 ]]; then
    echo "Error: The directory must contain exactly one video file and one subtitle file."
    echo "Found: $VIDEO_FILE_COUNT video file(s) and $SRT_FILE_COUNT srt file(s)."
    exit 1
fi

# Get the names of the specific files
VIDEO_FILE="${VIDEO_FILES[0]}"
SRT_FILE="${SRT_FILES[0]}"

# Get the base name of the video file for the output
OUTPUT_BASE_NAME="${VIDEO_FILE%.*}"
OUTPUT_FILE="$PARENT_DIR/$OUTPUT_BASE_NAME.mkv"

echo "Found video file: $VIDEO_FILE"
echo "Found subtitle file: $SRT_FILE"
echo "Output file will be: $OUTPUT_FILE"

# Use ffmpeg to softcode the subtitle into the video.
# -i flags provide the input files.
# -c copy copies the video and audio streams to avoid re-encoding.
# -c:s srt tells ffmpeg to handle the srt subtitle track.
# The output is a new .mkv container.
echo "Muxing files with FFmpeg... this should be quick."
ffmpeg -i "$VIDEO_FILE" -i "$SRT_FILE" -map 0 -map 1 -c copy -c:s srt "$OUTPUT_FILE"

# Check if ffmpeg was successful
if [[ $? -eq 0 ]]; then
    echo "Muxing successful!"
    echo "Moving original directory to trash..."

    # Use trash-cli to move the original directory to trash
    cd "$PARENT_DIR" || { echo "Error: Failed to change back to parent directory."; exit 1; }
    trash-put "$DIR_NAME"

    if [[ $? -eq 0 ]]; then
        echo "Successfully moved '$DIR_NAME' to trash."
        echo "Done!"
    else
        echo "Warning: Muxing was successful, but failed to move '$DIR_NAME' to trash."
        echo "Please move the directory manually to avoid clutter."
    fi
else
    echo "Error: Muxing failed. No changes were made."
fi
