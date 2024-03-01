#!/bin/bash

# Specify the directory to scan (change if needed)
directory_to_scan="$HOME/Documents/GitHub/"

# Recursively check each subdirectory for Git repos with uncommitted or unpushed changes
find "$directory_to_scan" -type d -exec bash -c '
  if [[ -d "$1/.git" ]]; then
    pushd "$1" > /dev/null

    # Check for uncommitted changes
    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
      echo "Uncommitted changes found in: $1"
    fi

    # Check for unpushed commits
    if [[ -n "$(git log @{u}.. 2>/dev/null)" ]]; then
      echo "Unpushed commits found in: $1"
    fi

    popd > /dev/null
  fi
' bash {} \;
