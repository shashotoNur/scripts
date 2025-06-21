#!/bin/bash

# Get the variables from user input if they aren't provided as arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "Usage: $0 /path/to/source <desired_number>\n"

    read -p "Enter the path to the source directory: " source_directory
    read -p "Enter the number of files are to be in a directory: " desired_number
else
    source_directory="$1"
    desired_number="$2"
fi

number_of_files=$(ls -1 "$source_directory" | wc -l)

# Calculate the number of required subdirectories
num_subdirs=$(( (number_of_files + desired_number - 1) / desired_number ))

# Create the required subdirectories
for ((i = 0; i < num_subdirs; i++)); do
    target_path="${source_directory}/${i}"

    if [ -f "${target_path}" ]; then
        mv "${target_path}" "${target_path}.bak"
    fi

    mkdir -p "${target_path}"
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
    filename=$(basename "$file")
    # Skip dotfiles and files without extensions
    if [[ "$filename" != *.* || "$filename" == .* ]]; then
        echo "Skipping '$file'"
        continue
    fi

    sub_dir="${source_directory}/${sub_dir_index}"
    if [[ -d "$sub_dir" ]]; then
        mv "$file" "$sub_dir"
    fi

    ((sub_dir_index = (sub_dir_index + 1) % num_subdirs))
done

# Display a message indicating completion
echo "$source_directory contents are now divided into its subdirectories."
