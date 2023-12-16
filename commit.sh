#!/bin/bash

# Define a function to input a commit message
function getCommitMessage {
    echo ">> Press Ctrl+d on an empty line to submit your input."

    # Title of the code changes
    while true; do
        read -p "Enter the header (50 characters maximum): " header

        # Validate header length
        if [ ${#header} -gt 50 ]; then
            echo "Header length must be less than or equal to 50 characters."
        else
            break
        fi
    done

    # The changes made in the code, algorithm and/or configuration
    echo "Enter a summary of changes: "
    changes=$(cat | sed 's/^/\t\t\t/')

    # The dependencies of the changes
    echo "Enter the dependencies added to the project (external & internal): "
    dependencies=$(cat | sed 's/^/\t\t\t/')

    # References regarding the issues, documentations and code
    echo "Enter any relevant references: "
    references=$(cat | sed 's/^/\t\t\t/')

    # Specify why the changes were made
    echo "Enter the purpose of the changes: "
    purpose=$(cat | sed 's/^/\t\t\t/')

    # Specify the alternatives considered for the purpose and why they were abandoned
    echo "Enter the alternatives considered for the purpose and why they were abandoned: "
    alternatives=$(cat | sed 's/^/\t\t\t/')

    # State the result, side effect and limitations of the changes
    echo "Enter the effect of the changes: "
    effect=$(cat | sed 's/^/\t\t\t/')

    # Name/Alias of the contributor
    read -p "Enter the contributor name: " contributor

    # Whether or not the changes are experimental/regular and complete/incomplete
    read -p "Enter the flag (experimental/regular or complete/incomplete): " flag

    # Statement for any work that should/must be done regarding the changes
    echo "Enter any future work to be done: "
    future_work=$(cat | sed 's/^/\t\t\t/')

    # Generate commit message
    commit_message="$header
    TITLE: $header

    BODY:"

    # Add sections only if the corresponding variable is not empty
    if [ -n "$changes" ]; then
        commit_message="$commit_message
        Summary of changes:
    $changes"
    fi

    if [ -n "$dependencies" ]; then
        commit_message="$commit_message
        Dependencies:
    $dependencies"
    fi

    if [ -n "$references" ]; then
        commit_message="$commit_message
        References:
    $references"
    fi

    if [ -n "$purpose" ]; then
        commit_message="$commit_message
        Purpose:
    $purpose"
    fi

    if [ -n "$alternatives" ]; then
        commit_message="$commit_message
        Considered alternatives:
    $alternatives"
    fi

    if [ -n "$effect" ]; then
        commit_message="$commit_message
        Effect:
    $effect"
    fi

    commit_message="$commit_message

    FOOTER:
        Contributor: $contributor
        Flag: $flag
        Future work:
    $future_work"
}

# Main portion of the script

# Initial message to the user
echo ">> Make sure git is initialized and remote repo is added."

# Check if the directory path is provided
if [ -z "$1" ]; then
    echo -e "Usage: $0 /path/to/git_directory"
    read -p "Enter the path to the git initialized directory: " repo_dir
else
	repo_dir=$1
fi

# Change to directory path from the first argument
cd "$repo_dir"

# Commence Git actions
git add .
getCommitMessage
git commit -m "$commit_message"
git push -u origin main
