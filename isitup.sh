#!/bin/bash

# Check if a website is up or down

if [ -z "$1" ]; then
    echo "Usage: $0 <website>"
    exit 1
fi

WEBSITE="$1"

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$WEBSITE")

if [ "$STATUS_CODE" == "200" ]; then
    echo "Website is up!"
else
    echo "Website is down! (Status Code: $STATUS_CODE)"
fi
