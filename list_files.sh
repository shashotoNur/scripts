#!/bin/bash

# Get the starting directory and the output file
starting_dir="$1"
output_file="$2"

# Check if the starting directory exists
if [ ! -d "$starting_dir" ]; then
    echo "Error: Directory '$starting_dir' does not exist."
    exit 1
fi

# Create the output file if it doesn't exist
touch "$output_file"

# Check if the output file is writable
if [ ! -w "$output_file" ]; then
    echo "Error: File '$output_file' is not writable."
    exit 1
fi

# Find all files in the starting directory and its nested directories
if ! find "$starting_dir" -type f -print >> "$output_file"; then
    echo "Error: An error occurred while finding files."
    exit 1
fi

echo "Filenames recorded in '$output_file'."
