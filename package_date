#!/bin/bash

# Function to display usage
usage() {
    echo "Usage:"
    echo "  $0 -p <package_name>      # Get the installed date and version of a specific package"
    echo "  $0 -d <YYYY-MM-DD>        # List packages installed on a specific date with version and time"
    exit 1
}

# Parse command-line arguments
while getopts ":p:d:" opt; do
    case $opt in
        p) package="$OPTARG" ;;
        d) date="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if neither -p nor -d was provided
if [[ -z "$package" && -z "$date" ]]; then
    usage
fi

# Check pacman log existence
PACMAN_LOG="/var/log/pacman.log"
if [[ ! -f "$PACMAN_LOG" ]]; then
    echo "Error: Pacman log not found at $PACMAN_LOG"
    exit 1
fi

# Function to format the timestamp
format_time() {
    input_timestamp="$1"
    # Remove timezone and ALPM suffix
    clean_timestamp=$(echo "$input_timestamp" | sed -E 's/([+-][0-9]{4}) ALPM//')
    # Convert to human-readable format
    date -d "$clean_timestamp" "+%Y-%m-%d, %I:%M %p"
}

# Handle package installation date query
if [[ -n "$package" ]]; then
    echo "Searching for the installation date of package: $package"
    install_entry=$(grep -i "installed $package " "$PACMAN_LOG" | head -n 1)
    if [[ -n "$install_entry" ]]; then
        raw_timestamp=$(echo "$install_entry" | awk '{print $1, $2}' | tr -d '[]')
        version=$(echo "$install_entry" | awk -F 'installed ' '{print $2}' | awk '{print $2}')
        readable_time=$(format_time "$raw_timestamp")
        echo "    Version: $version | Installed on: $readable_time"
    else
        echo "    Package '$package' not found in pacman logs."
    fi
fi

# Handle date-specific package query
if [[ -n "$date" ]]; then
    echo "Searching for packages installed on date: $date"
    grep -i "installed " "$PACMAN_LOG" | grep "$date" | while read -r line; do
        raw_timestamp=$(echo "$line" | awk '{print $1, $2}' | tr -d '[]')
        package_name=$(echo "$line" | awk -F "installed " '{print $2}' | awk '{print $1}')
        version=$(echo "$line" | awk -F "installed " '{print $2}' | awk '{print $2}')
        readable_time=$(format_time "$raw_timestamp" | awk '{print $2, $3}')
        echo "    Package: $package_name | Version: $version | Installed at: $readable_time"
    done
fi
