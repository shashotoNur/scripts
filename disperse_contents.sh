#!/bin/bash

# Get the variables from user input if they aren't provided as arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "Usage: $0 /path/to/source <target_size>\n"

    read -p "Enter the path to the source directory: " source_directory
    read -p "Enter the target subdirectory size in megabytes: " target_size_mb
else
    source_directory="$1"
    target_size_mb="$2"
fi

# Convert megabytes to kilobytes
target_size=$((target_size_mb * 1024))

# Get the size of the source directory in kilobytes
source_size=$(du -s "$source_directory" | cut -f1)

# Calculate the number of required subdirectories
num_subdirs=$((source_size / target_size))

# Create the required subdirectories
for ((i = 0; i < num_subdirs; i++)); do
    mkdir -p "${source_directory}/${i}"
done

# Create an array of filenames sorted by size
readarray -t sorted_files < <(
    find "$source_directory" -type f -printf "%s %p\n" |  # Print size and path
    sort -n |  # Sort by size
    cut -d' ' -f2-  # Cut to get only the path
)

# Move files in a round-robin manner to subdirectories
sub_dir_index=0
for file in "${sorted_files[@]}"; do
    sub_dir="${source_directory}/${sub_dir_index}"
    mv "$file" "$sub_dir"

    ((sub_dir_index = (sub_dir_index + 1) % num_subdirs))
done

# Display a message indicating completion
echo "$source_directory contents are now divided into its subdirectories."
