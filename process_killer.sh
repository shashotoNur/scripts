#!/bin/bash

# Declare the number of processes to display initially
processes_to_show=5

# Function to display top processes
display_top_processes() {
  local sort_option=$1
  echo "Top processes by $sort_option usage:"
  ps aux --sort=-%$sort_option | awk '{print $1, $2, $3, $4, $11}' | column -t | head -n $((processes_to_show + 1))
}

# Display the top processes by memory usage
display_top_processes mem

# Display the top processes by CPU usage
display_top_processes cpu

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
    ps -o pid= -o comm= -p $PIDS

    # Ask the user if they want to kill any of the processes
    read -p "Do you want to kill any of these processes? (y/n): " CHOICE

    if [ "$CHOICE" == "y" ]; then
        # Ask for the PID to kill
        read -p "Enter the PID to kill (or '*' to kill all): " KILL_PID

        if [ "$KILL_PID" == "*" ]; then
            # Kill all the matching processes
            echo "Killing all processes matching $PROCESS_NAME..."
            kill $PIDS
        else
            # Kill a single process gracefully (SIGTERM)
            kill "$KILL_PID"
        fi

        # Wait for the process(es) to terminate with a timeout
        TIMEOUT=3
        echo "Verifying if termination was successful in $TIMEOUT seconds..."
        sleep "$TIMEOUT"

        PIDS=$(pgrep -f "$PROCESS_NAME")
        echo "$PIDS"
        # Check if all processes have been terminated
        if [ ${#PIDS[@]} != 0 ] && [ "$KILL_PID" == "*" ]; then
            kill -9 $PIDS
            echo "Some processes were killed forcefully."
        elif ps -p "$KILL_PID" > /dev/null; then
            # If the process is still running, forcefully kill it (SIGKILL)
            kill -9 "$KILL_PID"
            echo "Process with PID $KILL_PID was killed forcefully."
        else
            echo "Termination was successful!"
        fi

    else
        echo "No process was killed."
    fi
fi
