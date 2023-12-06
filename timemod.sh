#!/bin/bash

# Check if the target directory is provided as an argument
if [ -z "$1" ]; then
    read -p "Enter the path to the target directory: " target_directory
else
    target_directory="$1"
fi

# Use find to update the timestamps of all files in the directory and its subdirectories
find "$target_directory" -type f -exec touch {} \;

echo "Timestamps of files in $target_directory and its subdirectories updated to current time."
