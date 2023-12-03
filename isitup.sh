#!/bin/bash
WEBSITE="example.com"
if curl -s --head $WEBSITE | grep "200 OK" > /dev/null; then
    echo "Website is up!"
else
    echo "Website is down!"
fi
