#!/bin/bash

# Define the directory containing the files
read -p "Enter the directory to search: " directory

# Loop through all files in the directory
for file in "$directory"/images*; do
    echo "$file"
    if [ -f "$file" ]; then  # Check if it's a regular file
        # Generate a random string of 12 characters
        random_string=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)

        # Get the file extension
        extension="${file##*.}"

        # Construct the new filename
        new_filename="$directory/$random_string.$extension"

        # Rename the file
        mv "$file" "$new_filename"

        echo "Renamed $file to $new_filename"
    fi
done
