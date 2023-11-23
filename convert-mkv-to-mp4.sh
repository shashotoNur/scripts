#!/bin/bash

# Get the directory location from the user
echo "Enter the directory location:"
read directory

# Convert all MKV files to MP4 while preserving subtitles
for file in $(find "$directory" -type f -name "*.mkv"); do
    ffmpeg -i "$file" -c:v copy -c:a copy -c:s copy "${file%.*}".mp4
done

# Ask for confirmation to remove the MKV files
echo "Do you want to remove the MKV files? (y/n)"
read confirm

if [[ "$confirm" == "y" ]]; then
    rm -f "$directory"/*.mkv
else
    echo "MKV files will not be removed."
fi
