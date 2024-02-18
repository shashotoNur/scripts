#!/bin/bash

read -p "Enter the directory to search: " directory_to_search
read -p "Enter the extension to find: " extension_to_find
read -p "Enter the extension to output: " desired_extension

target_directory="$directory_to_search/${extension_to_find}_files"
converted_directory="$target_directory/${desired_extension}_converts"

mkdir -p "$target_directory"
mkdir -p "$converted_directory"

# Find and move files
find "$directory_to_search" -type f -name "*.$extension_to_find" -exec mv -t "$target_directory" {} +

# Convert and move the files
for f in "$target_directory"/*."$extension_to_find"; do
  ffmpeg -i "$f" "${f%.*}.$desired_extension"
  mv "${f%.*}.$desired_extension" "$converted_directory"
done
