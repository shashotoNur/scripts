#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- Find Git Changes ---${NC}"

echo -e "${YELLOW}Select an ignore file (e.g. .reposignore) or press ESC to skip:${NC}"
ignore_file=$(find "$HOME" -maxdepth 3 -type f \( -name ".*ignore" -o -name ".git*" \) -not -path '*/\.*/*' -print 2>/dev/null |
  fzf --prompt="Select ignore file: " --cycle --height=10% --layout=reverse --border)

ignore_paths=()
if [[ -n "$ignore_file" && -f "$ignore_file" ]]; then
  echo -e "${BLUE}Using ignore file: ${ignore_file}${NC}"
  while IFS= read -r line; do
    # Expand tilde (~) to full home directory path for each line
    expanded_path="${line/#~/$HOME}"
    ignore_paths+=("$expanded_path")
  done < "$ignore_file"
else
  echo -e "${YELLOW}No ignore file selected or found. Proceeding without ignore paths.${NC}"
fi

echo -e "${YELLOW}Select directories to scan (Tab to select multiple, Enter to confirm):${NC}"

mapfile -d $'\0' -t directories_to_scan < <(find "$HOME" -maxdepth 3 -type d -not -path '*/\.*/*' 2>/dev/null | \
  fzf --prompt="Select directories: " --multi --cycle --height=30% --layout=reverse --border --print0)

if [[ ${#directories_to_scan[@]} -eq 0 ]]; then
  echo -e "${RED}No directories selected. Exiting.${NC}"
  exit 1
fi

for dir in "${directories_to_scan[@]}"; do
  echo -e "${GREEN}- $dir${NC}"
done

echo -e "${BLUE}Scanning Repositories:${NC}"

for directory_to_scan in "${directories_to_scan[@]}"; do
  find "$directory_to_scan" -name ".git" -prune -print0 | while IFS= read -r -d '' git_dir; do
    repo_dir=$(dirname "$git_dir")

    ignored=false
    for ignore_path in "${ignore_paths[@]}"; do
      if [[ "$repo_dir" == "$ignore_path" ]]; then
        echo -e "${YELLOW}Ignoring: ${repo_dir}${NC}"
        ignored=true
        break
      fi
    done

    if "$ignored"; then
      continue
    fi

    pushd "$repo_dir" >/dev/null || {
      echo -e "${RED}Error: Could not enter ${repo_dir}. Skipping.${NC}"
      continue
    }

    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
      echo -e "${RED}Uncommitted changes found in: ${repo_dir}${NC}"
    fi

    if git rev-parse --abbrev-ref --symbolic-full-name @{u} &>/dev/null; then
      if [[ -n "$(git log @{u}.. 2>/dev/null)" ]]; then
        echo -e "${YELLOW}Unpushed commits found in: ${repo_dir}${NC}"
      fi
    fi

    popd >/dev/null
  done
done
