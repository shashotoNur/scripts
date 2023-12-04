#!/bin/bash

# Declare the number of processes to display initially
processes_to_show=5

# Display the top processes by memory usage
echo "Top processes by memory usage:"
ps aux --sort=-%mem | awk '{print $1, $2, $3, $4, $11}' | column -t | head -n $((processes_to_show + 1))

# Display the top processes by CPU usage
echo -e "\nTop processes by CPU usage:"
ps aux --sort=-%cpu | awk '{print $1, $2, $3, $4, $11}' | column -t | head -n $((processes_to_show + 1))

# Ask the user for the process name to search
echo
read -p "Enter the process name to search: " PROCESS_NAME

# Search for the processes and get their PIDs
PIDS=$(pgrep -f "$PROCESS_NAME")

if [ -z "$PIDS" ]; then
    echo "No processes found with the name '$PROCESS_NAME'."
else
    # Display the matching processes and their PIDs
    echo -e "\nProcesses matching '$PROCESS_NAME' found:"

    for PID in $PIDS; do
        PROCESS_NAME=$(ps -o comm= -p "$PID")
        echo "PID: $PID, Process Name: $PROCESS_NAME"
    done

    # Ask the user if they want to kill any of the processes
    read -p "Do you want to kill any of these processes? (y/n): " CHOICE

    if [ "$CHOICE" == "y" ]; then
        # Ask for the PID to kill
        read -p "Enter the PID to kill: " KILL_PID

        # Attempt to kill the process gracefully (SIGTERM)
        kill "$KILL_PID"

        # Wait for the process to terminate with a timeout
        echo "Waiting for the process to terminate..."
        TIMEOUT=3
        sleep "$TIMEOUT"

        # Check if the process is still running
        if ps -p "$KILL_PID" > /dev/null; then
            # If the process is still running, forcefully kill it (SIGKILL)
            kill -9 "$KILL_PID"
            echo "Process with PID $KILL_PID killed forcefully (SIGKILL)."

        else
            echo "Process with PID $KILL_PID terminated gracefully."
        fi

    else
        echo "Processes not killed."
    fi
fi
