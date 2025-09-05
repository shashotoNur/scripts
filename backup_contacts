#!/bin/bash

# Define the source and target directories
KDECONNECT_DIR="$HOME/.local/share/kpeoplevcard"
TARGET_DIR="$HOME/Backups/contacts"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Clear the target directory
echo "Clearing target directory: $TARGET_DIR"
rm -f "$TARGET_DIR"/*.vcf

# Loop through each phone's directory in KDE Connect
if [ -d "$KDECONNECT_DIR" ]; then
    for PHONE_DIR in "$KDECONNECT_DIR"/kdeconnect-*; do
        if [ -d "$PHONE_DIR" ]; then
            # Extract the phone's name
            PHONE_NAME=$(basename "$PHONE_DIR" | sed 's/^kdeconnect-//')
            OUTPUT_FILE="$TARGET_DIR/${PHONE_NAME}.vcf"

            echo "Processing contacts for phone: $PHONE_NAME"
            
            # Initialize an empty file for the combined contacts
            > "$OUTPUT_FILE"

            # Loop through each VCF file in the phone's directory
            for VCF_FILE in "$PHONE_DIR"/*.vcf; do
                if [ -f "$VCF_FILE" ]; then
                    # Filter out lines containing X-KDECONNECT- and append to the output file
                    grep -v "X-KDECONNECT-" "$VCF_FILE" >> "$OUTPUT_FILE"
                fi
            done
            echo "Saved combined contacts to: $OUTPUT_FILE"
        fi
    done
else
    echo "KDE Connect directory not found: $KDECONNECT_DIR"
fi

echo "Script finished."
