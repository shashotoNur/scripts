#!/bin/bash

# --- Default Configuration ---
MIN_LENGTH=15
MAX_LENGTH=20
REQUIRED_UPPER=3
REQUIRED_LOWER=3
REQUIRED_SYMBOLS=3
REQUIRED_NUMBERS=3
SYMBOLS='!@+#$%^&*()_=<>-'

# --- Argument Parsing ---
while getopts "m:M:u:l:s:n:" opt; do
  case $opt in
    m) MIN_LENGTH=$OPTARG ;;
    M) MAX_LENGTH=$OPTARG ;;
    u) REQUIRED_UPPER=$OPTARG ;;
    l) REQUIRED_LOWER=$OPTARG ;;
    s) REQUIRED_SYMBOLS=$OPTARG ;;
    n) REQUIRED_NUMBERS=$OPTARG ;;
    *)
      echo "Usage: $0 [-m min_length] [-M max_length] [-u upper] [-l lower] [-s symbols] [-n numbers]"
      exit 1
      ;;
  esac
done

# --- Find reserved length ---
RESERVED_LENGTH=$((REQUIRED_UPPER + REQUIRED_LOWER + REQUIRED_SYMBOLS + REQUIRED_NUMBERS))
if (( MIN_LENGTH < RESERVED_LENGTH )); then
  MIN_LENGTH=$RESERVED_LENGTH
fi

# --- Random Length Selection ---
LENGTH=$(shuf -i "$MIN_LENGTH"-"$MAX_LENGTH" -n 1)

# --- Random Character Generation ---
generate_chars() {
  local CHARSET=$1
  local COUNT=$2
  LC_ALL=C tr -dc "$CHARSET" < /dev/urandom | head -c "$COUNT"
}

upper=$(generate_chars 'A-Z' "$REQUIRED_UPPER")
lower=$(generate_chars 'a-z' "$REQUIRED_LOWER")
symbols=$(generate_chars "$SYMBOLS" "$REQUIRED_SYMBOLS")
numbers=$(generate_chars '0-9' "$REQUIRED_NUMBERS")

# --- Calculate Remaining Characters ---
rest_length=$((LENGTH - RESERVED_LENGTH))
rest=$(generate_chars "A-Za-z0-9$SYMBOLS" "$rest_length")

# --- Assemble and Shuffle ---
PASSWORD=$(echo "$upper$lower$symbols$numbers$rest" | fold -w1 | shuf | tr -d '\n')

# --- Clipboard Copy ---
if command -v wl-copy >/dev/null 2>&1; then
    echo -n "$PASSWORD" | wl-copy
    echo "Password of length $LENGTH generated and copied to clipboard (wl-copy)!"
elif command -v xclip >/dev/null 2>&1; then
    echo -n "$PASSWORD" | xclip -selection clipboard
    echo "Password of length $LENGTH generated and copied to clipboard (xclip)!"
elif command -v xsel >/dev/null 2>&1; then
    echo -n "$PASSWORD" | xsel --clipboard --input
    echo "Password of length $LENGTH generated and copied to clipboard (xsel)!"
else
    echo "Password: $PASSWORD"
    echo "Warning: No clipboard utility found. Install wl-clipboard, xclip, or xsel."
fi
