#!/bin/bash

# Get a list of modified files that are not staged
UNSTAGED_FILES=$(git ls-files -m -o --exclude-standard --full-name)

TOTAL_SIZE_BYTES=0

# Function to convert bytes to human-readable format
bytes_to_human_readable() {
    local bytes=$1
    local human_readable=""

    if (( bytes < 1024 )); then
        human_readable="${bytes} Bytes"
    elif (( bytes < 1024 * 1024 )); then
        human_readable=$(echo "scale=2; $bytes / 1024" | bc)
        human_readable="${human_readable} KB"
    elif (( bytes < 1024 * 1024 * 1024 )); then
        human_readable=$(echo "scale=2; $bytes / (1024 * 1024)" | bc)
        human_readable="${human_readable} MB"
    else
        human_readable=$(echo "scale=2; $bytes / (1024 * 1024 * 1024)" | bc)
        human_readable="${human_readable} GB"
    fi
    echo "$human_readable"
}


if [ -z "$UNSTAGED_FILES" ]; then
    echo "No unstaged changes found."
else
    echo "Calculating size of not staged changes..."
    echo "--- Individual File Sizes ---"
    while IFS= read -r file; do
        if [ -f "$file" ]; then # Check if it's a regular file
            # Get file size in bytes using 'stat' (common on Linux/macOS)
            FILE_SIZE=$(stat -c %s "$file" 2>/dev/null || stat -f %z "$file" 2>/dev/null)
            if [ -n "$FILE_SIZE" ]; then
                TOTAL_SIZE_BYTES=$((TOTAL_SIZE_BYTES + FILE_SIZE))
                HUMAN_READABLE_SIZE=$(bytes_to_human_readable "$FILE_SIZE")
                echo "  ${file}: ${HUMAN_READABLE_SIZE}"
            else
                echo "  Warning: Could not get size for '${file}'. Skipping."
            fi
        fi
    done <<< "$UNSTAGED_FILES"

    echo "-----------------------------"
    # Convert total bytes to a more readable format (KB, MB, GB)
    TOTAL_HUMAN_READABLE_SIZE=$(bytes_to_human_readable "$TOTAL_SIZE_BYTES")
    echo "Total size of all not staged changes: ${TOTAL_HUMAN_READABLE_SIZE}"
fi
