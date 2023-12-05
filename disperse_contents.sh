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
target_size=$((target_size_mb * 1024))
mkdir -p "$target_directory"

# Create all subdirectories in advance
num_subdirs=$(( ($(du -s "$source_directory" | cut -f1) + target_size - 1) / target_size ))
for ((i = 0; i < num_subdirs; i++)); do
    mkdir -p "${target_directory}/subdir_${i}"
done

# Create an array of filenames sorted by size
readarray -t sorted_files < <(find "$source_directory" -type f -printf "%s %p\n" | sort -n | cut -d' ' -f2-)

# Copy files in a round-robin manner to subdirectories
sub_dir_index=0
for file in "${sorted_files[@]}"; do
    sub_dir="${target_directory}/subdir_${sub_dir_index}"
    cp "$file" "$sub_dir"
    ((sub_dir_index = (sub_dir_index + 1) % num_subdirs))
done

# Display a message indicating completion
echo "Directory divided into subdirectories in: $target_directory"
