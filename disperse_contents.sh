#!/bin/bash

# Get the variables from user input if they aren't provided as arguments
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    read -p "Enter the path to the source directory: " source_directory
    read -p "Enter the path to the target directory: " target_directory
    read -p "Enter the target subdirectory size in megabytes: " target_size_mb
else
    source_directory="$1"
    target_directory="$2"
    target_size_mb="$3"
fi

# Convert megabytes to bytes
target_size=$((target_size_mb * 1024 * 1024))
mkdir -p "$target_directory"

current_size=0
sub_dir_index=0

find "$source_directory" -type f | while read -r file; do
    size=$(du -b "$file" | cut -f1)
    if [ "$((current_size + size))" -gt "$target_size" ]; then
        ((sub_dir_index++))
        current_size=0
    fi
    current_size=$((current_size + size))
    sub_dir="${target_directory}/subdir_${sub_dir_index}"
    mkdir -p "$sub_dir"
    cp "$file" "$sub_dir"
done

# Display a message indicating completion
echo "Directory divided into subdirectories in: $target_directory"
