#!/bin/bash

# If the secret key is provided as an argument, take input
if [ -z "$1" ]; then
    echo -e ">> USAGE: $0 <your_secret_key>"

    # Ask for input until secret key is provided
    until [ -n "$secret_key" ]; do
        read -p "Enter your totp secret: " secret_key

        if [ -z "$secret_key" ]; then
            echo "[ERROR] Secret key cannot be empty!"
        fi

    done

else
    # Take secret key from system argument
    secret_key=$1
fi

# Get the current Unix timestamp
current_time=$(date +%s)

# Define the time step (in seconds) for generating the code (e.g., 30 seconds)
time_step=30

# Calculate the counter and time to TOTP expiration based on the current time and time step
counter=$((current_time / time_step))
expiring_in=$((time_step - (current_time % time_step)))

# Use oathtool to generate the TOTP code with the provided secret key and counter
output=$(oathtool -b --totp "$secret_key" -c "$counter" 2>&1)

# Echo error and exit if exit status `?` is not equal to 0
if [ $? -ne 0 ]; then
    echo -e "[ERROR] $output!\nProgram terminated."
    exit 1
fi

# Display the generated TOTP code
totp_code="$output"
echo "Your TOTP code: $totp_code"
echo "This code is expiring in $expiring_in seconds."

# Copy the code to the clipboard (requires wl-copy)
if [ -x "$(command -v wl-copy)" ]; then
    echo -n "$totp_code" | wl-copy
    echo "Code copied to clipboard!"
fi
