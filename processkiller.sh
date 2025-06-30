#!/bin/bash

# Function to display top processes
display_top_processes() {
    local SORT_OPTION=$1
    local SHOW=$2

    echo -e "\nTop processes by $SORT_OPTION usage:"
    ps aux --sort=-%$SORT_OPTION | awk '{print $1, $2, $3, $4, $11}' | column -t | head -n $((SHOW + 1))
}

# Function to wait for process(es) to terminate
wait_for_termination() {
    local PIDS="$1"
    local TIMEOUT=2
    echo "Verifying termination in $TIMEOUT seconds..."
    sleep "$TIMEOUT"

    for PID in $PIDS; do
        if ps -p "$PID" > /dev/null; then
            echo "Process $PID is still running."
        fi
    done
}

# Function to kill multiple processes
kill_processes() {
    local PIDS="$1"
    local PROCESS_NAME="$2"

    echo "Attempting to kill all processes matching the name..."
    kill $PIDS

    wait_for_termination "$PIDS"

    PIDS=$(pgrep -f "$PROCESS_NAME")

    if [ -z "$PIDS" ]; then
        echo "All processes named '$PROCESS_NAME' were terminated gracefully."
    else
        kill -9 $PIDS
        echo "Some processes required forceful termination."
    fi
}

# Function to kill a single process
kill_process() {
    local PID=$1

    echo "Attempting to kill process with PID '$PID'"
    kill "$PID"

    wait_for_termination "$PID"

    if ps -p "$PID" > /dev/null; then
        kill -9 "$PID"
        echo "Process with PID $PID was killed forcefully."
    else
        echo "Process with PID $PID was killed gracefully."
    fi
}

# Main function to find and kill process(es)
main() {
    # Show top resource-consuming processes
    TO_SHOW=5
    display_top_processes mem "$TO_SHOW"
    display_top_processes cpu "$TO_SHOW"

    echo
    read -p "Enter a process name to check: " PROCESS_NAME

    PIDS=$(pgrep -f "$PROCESS_NAME")

    if [ -z "$PIDS" ]; then
        echo "No matching processes found."
        return
    fi

    echo -e "\nProcesses matching '$PROCESS_NAME':"
    ps -o pid=,comm= -p $PIDS

    read -p "Do you want to kill any of these processes? (y/N): " CHOICE

    if [ "$CHOICE" != "y" ]; then
        echo "No processes were killed."
        return
    fi

    read -p "Enter PID to kill (or '*' to kill all): " KILL_PID

    if [ "$KILL_PID" == "*" ]; then
        kill_processes "$PIDS" "$PROCESS_NAME"
    else
        kill_process "$KILL_PID"
    fi
}

# Start the script
main
