#!/bin/bash

# Function to display usage
show_usage() {
    echo "Usage: $0 [MAX_SIZE_MB] [SOURCE_DIRECTORY]"
    echo "Copy files from the SOURCE_DIRECTORY to a target directory at random until MAX_SIZE_MB is reached."
    echo
    echo "Arguments:"
    echo "  MAX_SIZE_MB        Maximum size of the target directory in megabytes."
    echo "  SOURCE_DIRECTORY   Path to the source directory containing files to copy."
    echo
    echo "If no arguments are provided, the script will prompt for input."
    echo
    echo "Options:"
    echo "  --help             Show this help message and exit."
}

# Function to convert megabytes to bytes
convert_mb_to_bytes() {
    echo $(($1 * 1024 * 1024))
}

# Function to get the size of a file in bytes
get_file_size() {
    stat -c%s "$1"
}

# Function to copy files to target directory at random
copy_files_randomly() {
    local source_dir="$1"
    local max_size="$2"
    local target_dir="$3"
    local total_size=0
    local copied_files=()

    # Ensure source directory path ends with a forward slash
    [[ "${source_dir}" != */ ]] && source_dir="${source_dir}/"

    # Read all files from the source directory into an array
    mapfile -t sorted_files < <(find "$source_dir" -type f | sort)

    while [ $total_size -lt $max_size ] && [ ${#sorted_files[@]} -gt 0 ]; do
        # Randomly select a file
        local random_index=$((RANDOM % ${#sorted_files[@]}))
        local file="${sorted_files[$random_index]}"
        local file_size=$(get_file_size "$file")

        # Check if file size is less than 10MB
        if [ -n "$file_size" ] && [ "$file_size" -le $(convert_mb_to_bytes 10) ]; then

            # Check if adding the file exceeds max_size
            if [ $((total_size + file_size)) -le "$max_size" ]; then
                cp "$file" "$target_dir"

                total_size=$((total_size + file_size))
                copied_files+=("$(basename "$file")")
            fi
        fi

        # Remove the file from the list along with its neighbors
        for ((i = random_index - 2; i <= random_index + 2; i++)); do
            unset 'sorted_files[i]'
        done

        # Re index the array
        sorted_files=("${sorted_files[@]}")
    done

    echo "Copied files:"
    local index=1
    for copied_file in "${copied_files[@]}"; do
        echo -e "\t$index. $copied_file"
        index=$((index + 1))
    done
}

# Function to calculate the size of a directory
calculate_directory_size() {
    local dir=$1
    du -sh "$dir" | cut -f1
}

# Main script starts here
main() {
    # Check for --help argument
    if [ "$1" == "--help" ]; then
        show_usage
        exit 0
    fi

    local max_size
    local source_dir

    if [ -z "$1" ]; then
        read -p "Enter the maximum size of the target directory (in MB): " max_size
    else
        max_size=$1
    fi

    if [ -z "$2" ]; then
        read -p "Enter the path to the source directory: " source_dir
    else
        source_dir=$2
    fi

    max_size=$(convert_mb_to_bytes "$max_size")

    # Create target directory in current working directory
    local target_dir="./sample"
    mkdir -p "$target_dir"

    # Start copying files randomly
    copy_files_randomly "$source_dir" "$max_size" "$target_dir"

    # Calculate and print the size of the target directory
    local target_dir_size=$(calculate_directory_size "$target_dir")
    echo "Size of the target directory: $target_dir_size"
}

main "$@"
