#!/bin/bash

clip_file="$HOME/.cliphist"
last_clip=""

# Ensure the clip history file exists
touch "$clip_file"

# Function to get the last line of a file
function get_last_line {
    tail -n 1 "$1"
}

# Initialize last_clip with the current last line of clip_file
last_clip=$(get_last_line "$clip_file")

# Monitor clipboard and append new entries to clip history file
echo "Clipboard history is being stored at $clip_file"
while true
do
    # Get current clipboard content
    current_clip=$(cliphist list | head -n 1 | cliphist decode)

    # Check if clipboard content is not empty and is new
    if [[ -n "$current_clip" && "$current_clip" != "$last_clip" ]]
    then
        echo "$current_clip" >> "$clip_file"
        last_clip="$current_clip"
    fi

    # Sleep for 1 second before checking again
    sleep 1
done
