#!/bin/bash

# Function to display top processes
display_top_processes() {
    local SORT_OPTION=$1
    local SHOW=$2

    echo -e "\nTop processes by $SORT_OPTION usage:"
    ps aux --sort=-%$SORT_OPTION | awk '{print $1, $2, $3, $4, $11}' | column -t | head -n $((SHOW + 1))
}

# Function to wait for the process(es) to terminate with a timeout
wait_for_termination() {
    local TIMEOUT=2
    echo "Verifying if termination was successful in $TIMEOUT seconds..."
    sleep "$TIMEOUT"
}

# Function to kill multiple proccesses
kill_proccesses() {
    local PIDS=$1
    local PROCESS_NAME=$2

    echo "Killing all processes matching the specified name..."
    kill $PIDS

    wait_for_termination
    PIDS=$(pgrep -f "$PROCESS_NAME")

    if [ -z "$PIDS" ]; then
        echo "All processes found with the name '$PROCESS_NAME' were terminated gracefully."
    else
        kill -9 $PIDS
        echo "Some processes were killed forcefully."
    fi
}

# Function to kill a process
kill_process() {
    local PID=$1

    echo "Killing the process with PID '$PID'"
    kill "$PID"

    wait_for_termination

    if ps -p "$PID" > /dev/null; then
        kill -9 "$PID"
        echo "Process with PID $PID was killed forcefully."
    else
        echo "Process with PID $PID was killed gracefully."
    fi
}

# Main function to find process(es) and kill them
main() {
    echo
    read -p "Enter a process name to see if it is active: " PROCESS_NAME

    # Search for the processes and get their PIDs
    PIDS=$(pgrep -f "$PROCESS_NAME")

    if [ -z "$PIDS" ]; then
        echo "No processes found with the specified name."
        return
    fi

    echo -e "\nProcesses matching '$PROCESS_NAME' found:"
    ps -o pid= -o comm= -p $PIDS

    read -p "Do you want to kill any of these processes? (y/n): " CHOICE

    if [ "$CHOICE" != "y" ]; then
        echo "No process was killed."
        return
    fi

    read -p "Enter the PID to kill (or '*' to kill all): " KILL_PID

    if [ "$KILL_PID" == "*" ]; then
        kill_proccesses "$PIDS" "$PROCESS_NAME"
    else
        kill_process "$KILL_PID"
    fi
}

# Declare the number of processes to display initially
TO_SHOW=5

# Display the top processes by memory and CPU usage
display_top_processes mem "$TO_SHOW"
display_top_processes cpu "$TO_SHOW"

# Execute the main function
main
