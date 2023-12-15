#!/bin/bash

# Check if a directory path is provided
if [ -z "$1" ]; then
    echo -e "Usage: $0 /path/to/directory"
    read -p "Enter the path to the directory: " directory_path
else
    directory_path="$1"
fi

# Markdown file
markdown_file="pdf_info.md"

# Create or truncate the markdown file
echo "| Serial | Book Name | Path | Pages |" > "$markdown_file"
echo "|--------|-----------|------|-------|" >> "$markdown_file"

# Counter for serial number
serial_number=1

# Function to get the number of pages in a PDF file
get_page_count() {
    pdf_file="$1"
    pdf_info=$(pdfinfo "$pdf_file" 2>/dev/null)
    page_count=$(echo "$pdf_info" | grep "Pages:" | awk '{print $2}')
    echo "$page_count"
}

# Find and process PDF files in the directory and its subdirectories
find "$directory_path" -type f -name "*.pdf" | sort | while read -r pdf_file; do
    # Get PDF information
    pdf_name=$(basename "$pdf_file")
    pdf_relative_path=$(realpath --relative-to="$directory_path" "$pdf_file" | sed 's|/[^/]*$||')  # Relative path without filename
    page_count=$(get_page_count "$pdf_file")

    # Append information to the markdown file
    echo "| $serial_number | $pdf_name | $pdf_relative_path | $page_count |" >> "$markdown_file"

    # Increment serial number
    ((serial_number++))
done

echo "Markdown file created: $markdown_file"
