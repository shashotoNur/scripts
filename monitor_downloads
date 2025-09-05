#!/bin/bash

# Path to the Downloads directory
DOWNLOADS_DIR="$HOME/Downloads"

# Function to determine the file type based on extension
get_file_type() {
    case "$1" in
        *.jpg|*.jpeg|*.png|*.gif|*.bmp|*.tiff|*.webp)
            echo "image";;
        *.mp3|*.wav|*.flac|*.aac|*.ogg)
            echo "audio";;
        *.pdf|*.doc|*.docx|*.txt|*.rtf|*.odt|*.csv)
            echo "document";;
        *.mp4|*.mkv|*.avi|*.wmv|*.flv)
            echo "video";;
        *.zip|*.tar|*.gz)
            echo "archive";;
        *.xls|*.xlsx|*.csv)
            echo "spreadsheet";;
        *.ppt|*.pptx|*.key)
            echo "presentation";;
        *.html|*.htm|*.xml)
            echo "markup";;
        *.md|*.markdown)
            echo "markdown";;
        *)
            echo "";;  # Return empty string for unknown file types
    esac
}

# Function to move files to the appropriate directory
move_file() {
    local source_file="$1"
    local dest_dir="$2"
    if [ -n "$dest_dir" ]; then
        # Ensure the destination directory exists
        mkdir -p "$dest_dir"

        # Move the file to the appropriate directory
        mv "$source_file" "$dest_dir/"
        echo "Moved $source_file to $dest_dir/"
    else
        echo "File type unknown, skipping: $source_file"
    fi
}

# Map file types to destination directories
declare -A file_type_mapping
file_type_mapping=(
    ["image"]="$HOME/Pictures"
    ["audio"]="$HOME/Music"
    ["document"]="$HOME/Documents"
    ["video"]="$HOME/Videos"
    ["archive"]="$HOME/Archives"
    ["spreadsheet"]="$HOME/Documents/Spreadsheets"
    ["presentation"]="$HOME/Documents/Presentations"
    ["markup"]="$HOME/Documents/Markup"
    ["markdown"]="$HOME/Documents/Markdown"
)

# Move existing files in the Downloads directory
for existing_file in "$DOWNLOADS_DIR"/*; do
    if [ -f "$existing_file" ]; then
        file_type=$(get_file_type "$existing_file")
        dest_dir="${file_type_mapping[$file_type]}"
        move_file "$existing_file" "$dest_dir"
    fi
done

# Start monitoring the Downloads directory for file creation
inotifywait -m -e create --format '%w%f' "$DOWNLOADS_DIR" |
while read -r new_file; do
    # Check if the new file is a regular file and not a directory
    if [ -f "$new_file" ]; then
        file_type=$(get_file_type "$new_file")
        dest_dir="${file_type_mapping[$file_type]}"
        move_file "$new_file" "$dest_dir"
    fi
done
