#! /bin/bash

# This script checks for new SSH connections using 'who'
# and sends a desktop notification with formatted details.

who | awk '
  # This pattern specifically looks for lines containing an IPv4 address in parentheses
  /\([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\)/ {
    # Extract raw data
    user = $1
    tty = $2
    login_date_raw = $3 # e.g., 2025-07-26
    login_time_raw = $4 # e.g., 14:02
    
    # Extract and clean IP address
    ip_with_parens = $NF
    ip_address = substr(ip_with_parens, 2, length(ip_with_parens)-2)

    # --- Reformat date and time using the "date" command ---
    timestamp_str = login_date_raw " " login_time_raw ":00"
    
    # Get formatted time (e.g., "02:14 pm")
    sprintf("date -d \"%s\" \"+%%I:%%M %%P\"", timestamp_str) | getline formatted_time
    close("date -d \"" timestamp_str "\" \"+%I:%M %P\"") # Close the pipe

    # Get formatted date (e.g., "26 July, 2025")
    sprintf("date -d \"%s\" \"+%%d %%B, %%Y\"", timestamp_str) | getline formatted_date
    close("date -d \"" timestamp_str "\" \"+%d %B, %Y\"") # Close the pipe
    # --- End of date/time reformatting ---

    # Construct the notification message (can be multiline using backslash escapes)
    message = "User: " user "\\n" \
              "Terminal: " tty "\\n" \
              "Login Time: " formatted_time " on " formatted_date "\\n" \
              "Client IP: " ip_address

    # Construct the notify-send command using sprintf for robustness
    # Ensure all arguments to sprintf are on a single logical line
    sprintf("notify-send -t 10000 -a \"SSH Client Info\" -u normal -i network-transmit-receive \"New SSH Connection Detected\" \"%s\"", message) | getline notify_cmd_string
    close("notify-send -t 10000 -a \"SSH Client Info\" -u normal -i network-transmit-receive \"New SSH Connection Detected\" \"" message "\"")

    # Execute the notification command
    system(notify_cmd_string)

    # Exit after finding the first SSH connection (remove if you want all)
    exit 
  }
'
