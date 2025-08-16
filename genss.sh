#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <video_file> <time_or_number> [output_directory]"
    echo ""
    echo "  <video_file>: The path to the input video file."
    echo "  <time_or_number>: "
    echo "    - A time in HH:MM:SS format (e.g., 00:01:30) to extract a single frame at that time."
    echo "    - A positive integer (e.g., 10) to extract that many equidistant frames."
    echo "  [output_directory]: Optional. The directory to save the image files. Defaults to 'output_frames'."
    exit 1
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it to use this script."
    exit 1
fi

# Parse command-line arguments
video_file="$1"
time_or_number="$2"
output_dir="${3:-output_frames}" # Default output directory

# Validate input
if [[ -z "$video_file" || -z "$time_or_number" ]]; then
    usage
fi

if [[ ! -f "$video_file" ]]; then
    echo "Error: Video file '$video_file' not found."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$output_dir" || { echo "Error: Could not create directory '$output_dir'"; exit 1; }

# Determine if input is time or number
if [[ "$time_or_number" =~ ^([0-9]{2}:){2}[0-9]{2}$ ]]; then
    # Input is a time (HH:MM:SS) - extract single frame
    echo "Extracting single frame at $time_or_number from '$video_file'..."
    ffmpeg -ss "$time_or_number" -i "$video_file" -vframes 1 "$output_dir/frame_at_${time_or_number//:/-}.png"
    if [[ $? -eq 0 ]]; then
        echo "Frame saved to '$output_dir/frame_at_${time_or_number//:/-}.png' 👍"
    else
        echo "Error: Failed to extract frame at $time_or_number. 😔"
    fi
elif [[ "$time_or_number" =~ ^[0-9]+$ && "$time_or_number" -gt 0 ]]; then
    # Input is a positive number - extract equidistant frames
    num_frames="$time_or_number"
    echo "Extracting $num_frames equidistant frames from '$video_file'..."

    # Get video duration in seconds
    duration=$(ffmpeg -i "$video_file" 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed s/,// | awk '{ split($1, A, ":"); print 3600*A[1] + 60*A[2] + A[3] }')

    if [[ -z "$duration" ]]; then
        echo "Error: Could not determine video duration. 😔"
        exit 1
    fi

    # Adjust duration for frame extraction to be one second before the end
    adjusted_duration=$(echo "scale=3; $duration - 1" | bc)
    if (( $(echo "$adjusted_duration < 0" | bc -l) )); then
        adjusted_duration=0 # Ensure duration doesn't go negative for very short videos
    fi

    # Calculate interval for equidistant frames
    if (( num_frames == 1 )); then
        interval=0 # If only 1 frame, take the first frame
        current_time_start=0 # Start at 0 for single frame
    else
        interval=$(echo "scale=3; $adjusted_duration / ($num_frames - 1)" | bc)
        current_time_start=0
    fi


    echo "Video duration: $(printf "%.2f" "$duration") seconds"
    echo "Adjusted duration for frames (1 second before end): $(printf "%.2f" "$adjusted_duration") seconds"
    echo "Interval for frames: $(printf "%.2f" "$interval") seconds"

    for (( i=0; i<num_frames; i++ )); do
        current_time=$(echo "scale=3; $current_time_start + $i * $interval" | bc)

        # Ensure current_time does not exceed the adjusted duration
        if (( $(echo "$current_time > $adjusted_duration" | bc -l) )); then
            current_time="$adjusted_duration"
        fi

        # Use bc to extract hours, minutes, and seconds and ensure they are integers
        hours=$(echo "scale=0; $current_time / 3600" | bc | cut -d'.' -f1)
        minutes=$(echo "scale=0; ($current_time % 3600) / 60" | bc | cut -d'.' -f1)
        seconds=$(echo "scale=0; $current_time % 60" | bc | cut -d'.' -f1)

        timestamp=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
        output_filename="$output_dir/frame_$(printf "%04d" $((i+1)))_at_${timestamp//:/-}.png"
        echo "Extracting frame $((i+1)) at $timestamp..."
        ffmpeg -ss "$current_time" -i "$video_file" -vframes 1 -q:v 2 "$output_filename" &>/dev/null
        if [[ $? -ne 0 ]]; then
            echo "Warning: Failed to extract frame $((i+1)) at $timestamp. Moving on..."
        fi
    done
    echo "All requested frames saved to '$output_dir' 🎉"
else
    echo "Error: Invalid time or number format. Please provide HH:MM:SS or a positive integer."
    usage
fi
