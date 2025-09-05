#!/bin/bash

usage() {
    echo "Usage: $0 -i <input_path> [-t <time_interval>] [-n <num_frames>] [-o <output_directory>]"
    echo ""
    echo "  -i <input_path>: Required. The path to the input video file or directory containing video files."
    echo "  -t <time_interval>: Optional. Time interval in seconds between extracted frames (e.g., 5 for every 5 seconds)."
    echo "                     Cannot be used with -n."
    echo "  -n <num_frames>: Optional. Number of equidistant frames to extract from each video."
    echo "                   Cannot be used with -t."
    echo "  -o <output_directory>: Optional. The base directory to save the image files. Defaults to 'output_frames'."
    exit 1
}

if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it to use this script."
    exit 1
fi

input_path=""
time_interval=""
num_frames=""
output_base_dir="output_frames"

while getopts "i:t:n:o:" opt; do
    case ${opt} in
        i ) input_path=$OPTARG ;;
        t ) time_interval=$OPTARG ;;
        n ) num_frames=$OPTARG ;;
        o ) output_base_dir=$OPTARG ;;
        \? ) usage ;;
    esac
done
shift $((OPTIND -1))

if [[ -z "$input_path" ]]; then
    echo "Error: Input path is required."
    usage
fi

if [[ (! -z "$time_interval" && ! -z "$num_frames") || ( -z "$time_interval" && -z "$num_frames" ) ]]; then
    echo "Error: You must provide either a time interval (-t) or a number of frames (-n), but not both."
    usage
fi

if [[ ! -z "$time_interval" && ! "$time_interval" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: Time interval must be a positive number."
    usage
fi

if [[ ! -z "$num_frames" && ( ! "$num_frames" =~ ^[0-9]+$ || "$num_frames" -le 0 ) ]]; then
    echo "Error: Number of frames must be a positive integer."
    usage
fi

mkdir -p "$output_base_dir" || { echo "Error: Could not create base output directory '$output_base_dir'"; exit 1; }

process_video() {
    local video_file="$1"
    local output_dir="$2"
    local current_time_interval="$3"
    local current_num_frames="$4"

    echo "---"
    echo "Processing video: '$video_file'"

    local video_filename=$(basename "$video_file")
    local video_name_no_ext="${video_filename%.*}"
    local video_output_subdir="$output_dir/$video_name_no_ext"
    mkdir -p "$video_output_subdir" || { echo "Error: Could not create directory '$video_output_subdir'"; return 1; }

    duration=$(ffmpeg -i "$video_file" 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed s/,// | awk '{ split($1, A, ":"); print 3600*A[1] + 60*A[2] + A[3] }')

    if [[ -z "$duration" ]]; then
        echo "Error: Could not determine video duration for '$video_file'. Skipping."
        return 1
    fi

    echo "Video duration: $(printf "%.2f" "$duration") seconds"

    if [[ ! -z "$current_time_interval" ]]; then
        # Extract frames based on time interval
        local interval_seconds=$(echo "scale=3; $current_time_interval" | bc)
        echo "Extracting frames every $interval_seconds seconds..."

        local current_time_offset=0
        local frame_count=0
        while (( $(echo "$current_time_offset < $duration" | bc -l) )); do
            local hours=$(echo "scale=0; $current_time_offset / 3600" | bc | cut -d'.' -f1)
            local minutes=$(echo "scale=0; ($current_time_offset % 3600) / 60" | bc | cut -d'.' -f1)
            local seconds=$(echo "scale=0; $current_time_offset % 60" | bc | cut -d'.' -f1)
            local timestamp=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
            local output_filename="$video_output_subdir/frame_$(printf "%04d" $((frame_count+1)))_at_${timestamp//:/-}.png"

            echo "  Extracting frame $((frame_count+1)) at $timestamp..."
            ffmpeg -ss "$current_time_offset" -i "$video_file" -vframes 1 -q:v 2 "$output_filename" &>/dev/null
            if [[ $? -ne 0 ]]; then
                echo "  Warning: Failed to extract frame $((frame_count+1)) at $timestamp. Moving on..."
            fi
            current_time_offset=$(echo "scale=3; $current_time_offset + $interval_seconds" | bc)
            ((frame_count++))
        done
        echo "Successfully extracted $frame_count frames to '$video_output_subdir'"

    elif [[ ! -z "$current_num_frames" ]]; then
        # Extract equidistant frames based on number
        local frames_to_extract="$current_num_frames"
        echo "Extracting $frames_to_extract equidistant frames..."

        local adjusted_duration=$(echo "scale=3; $duration - 1" | bc)
        if (( $(echo "$adjusted_duration < 0" | bc -l) )); then
            adjusted_duration=0
        fi

        local interval=0
        if (( frames_to_extract > 1 )); then
            interval=$(echo "scale=3; $adjusted_duration / ($frames_to_extract - 1)" | bc)
        fi

        for (( i=0; i<frames_to_extract; i++ )); do
            local current_time=$(echo "scale=3; $i * $interval" | bc)

            if (( $(echo "$current_time > $adjusted_duration" | bc -l) )); then
                current_time="$adjusted_duration"
            fi

            local hours=$(echo "scale=0; $current_time / 3600" | bc | cut -d'.' -f1)
            local minutes=$(echo "scale=0; ($current_time % 3600) / 60" | bc | cut -d'.' -f1)
            local seconds=$(echo "scale=0; $current_time % 60" | bc | cut -d'.' -f1)
            local timestamp=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
            local output_filename="$video_output_subdir/frame_$(printf "%04d" $((i+1)))_at_${timestamp//:/-}.png"

            echo "  Extracting frame $((i+1)) at $timestamp..."
            ffmpeg -ss "$current_time" -i "$video_file" -vframes 1 -q:v 2 "$output_filename" &>/dev/null
            if [[ $? -ne 0 ]]; then
                echo "  Warning: Failed to extract frame $((i+1)) at $timestamp. Moving on..."
            fi
        done
        echo "Successfully extracted $frames_to_extract frames to '$video_output_subdir'"
    fi
}

if [[ -d "$input_path" ]]; then
    echo "Input is a directory: '$input_path'"
    echo "Searching for video files (mp4, mov, avi, mkv) within this directory..."
    find "$input_path" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" \) | while read -r video_file; do
        process_video "$video_file" "$output_base_dir" "$time_interval" "$num_frames"
    done
    echo "---"
    echo "All video files processed. Results are in '$output_base_dir'."
elif [[ -f "$input_path" ]]; then
    echo "Input is a single video file: '$input_path'"
    process_video "$input_path" "$output_base_dir" "$time_interval" "$num_frames"
    echo "---"
    echo "Video file processed. Results are in '$output_base_dir'."
else
    echo "Error: Input path '$input_path' is not a valid file or directory."
    exit 1
fi
