#!/bin/bash

MIN_LENGTH=15
MAX_LENGTH=20
REQUIRED_UPPER=3
REQUIRED_LOWER=3
REQUIRED_SYMBOLS=3
REQUIRED_NUMBERS=3

SYMBOLS="!@+#$% ^&*(_)-=<>?"

LENGTH=$(shuf -i "$MIN_LENGTH"-"$MAX_LENGTH" -n 1)

# Generate required components
upper=$(tr -dc 'A-Z' < /dev/urandom | head -c "$REQUIRED_UPPER")
lower=$(tr -dc 'a-z' < /dev/urandom | head -c "$REQUIRED_LOWER")
symbols=$(tr -dc "$SYMBOLS" < /dev/urandom | head -c "$REQUIRED_SYMBOLS")
numbers=$(tr -dc '0-9' < /dev/urandom | head -c "$REQUIRED_NUMBERS")

# Calculate the length of the remaining characters
rest_length=$((LENGTH - REQUIRED_UPPER - REQUIRED_LOWER - REQUIRED_SYMBOLS - REQUIRED_NUMBERS))

# Generate the remaining characters
rest=$(tr -dc "A-Za-z0-9$SYMBOLS" < /dev/urandom | head -c "$rest_length")

# Combine and shuffle all components
PASSWORD=$(echo "$upper$lower$symbols$numbers$rest" | fold -w1 | shuf | tr -d '\n')

# Copy password to clipboard (requires xclip or xsel)
echo -n "$PASSWORD" | wl-copy
echo "Password generated and copied to clipboard!"
