#!/bin/bash

# 1. Prompt for ignore file path
read -p "Enter the path to the ignore file (leave blank to skip): " ignore_file
echo -e "\n"

# 2. Check if ignore file exists
if [[ -f "$ignore_file" ]]; then
  # 2.1 Read ignore paths into an array
  mapfile -t ignore_paths < "$ignore_file"
else
  # 2.2 No ignore file, proceed as usual
  ignore_paths=()
fi

# 3. Specify the directory to scan (change if needed)
directory_to_scan="$HOME/Workspace/"

# Recursively check each subdirectory for Git repos with uncommitted or unpushed changes
find "$directory_to_scan" -type d -name ".git" -prune -print0 | while IFS= read -r -d '' git_dir; do
  repo_dir=$(dirname "$git_dir")

  # Check if the repo_dir should be ignored
  for ignore_path in "${ignore_paths[@]}"; do
    if [[ "$repo_dir" == "$ignore_path" ]]; then
      continue 2 # Continue to the next iteration of the outer loop
    fi
  done

  pushd "$repo_dir" > /dev/null

  # Check for uncommitted changes
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    echo "Uncommitted changes found in: $repo_dir"
  fi

  # Check for unpushed commits
  if [[ -n "$(git log @{u}.. 2>/dev/null)" ]]; then
    echo "Unpushed commits found in: $repo_dir"
  fi

  popd > /dev/null
done

echo -e "\nIgnored paths:"
printf '%s\n' "${ignore_paths[@]}"
