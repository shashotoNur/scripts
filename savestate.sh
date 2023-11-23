#!/bin/bash

# Define a function to input a commit message
function getCommitMessage {
	echo "Press Ctrl+d on an empty line to submit your input"

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
	changes=$(cat | sed 's/^/\t\t/')

	# References regarding the issues, documentations and code
	echo "Enter any relevant references: "
	references=$(cat | sed 's/^/\t\t/')

	# Specify why the changes were made
	echo "Enter the purpose of the changes: "
	purpose=$(cat | sed 's/^/\t\t/')

	# State the result, side effect and limitations of the changes
	echo "Enter the effect of the changes: "
	effect=$(cat | sed 's/^/\t\t/')

	# Name/Alias of the contributor
	read -p "Enter the contributor name: " contributor

	# Whether or not the changes are experimental/regular and complete/incomplete
	read -p "Enter the flag (experimental/regular or complete/incomplete): " flag

	# Statement for any work that should/must be done regarding the changes
	echo "Enter any future work to be done: "
	future_work=$(cat | sed 's/^/\t\t/')

	# Generate commit message
	commit_message="$header

	Body:

		Summary of changes:
		$changes

		References:
		$references

		Purpose:
		$purpose

		Effect:
		$effect

	Footer:

		Contributor: $contributor
		Flag: $flag
		Future work:
		$future_work"
}

# Check if the directory path is provided
if [ -z "$1" ]; then
	echo "Please provide a directory path as an argument."
	exit 1
fi

# Change to directory path from the first argument
repo_dir=$1
cd "$repo_dir"

# Commence Git actions
git add .
getCommitMessage
git commit -m "$commit_message"
git push -u origin main


# SAMPLE COMMIT MESSAGE
# Implement new caching mechanism

# Body:

# Summary of changes:
# - Introduced a caching layer to reduce database queries and improve performance
# - Implemented cache invalidation mechanism to ensure data consistency

# References:
# - Issue #123: Improve user registration performance
# - Documentation: https://github.com/project/docs/caching-mechanism

# Purpose:
# - Optimize user registration process by minimizing database interactions
# - Enhance overall system responsiveness and performance

# Effect:
# - Significantly reduces database load and query time
# - Improves user registration page loading speed
# - May introduce slight delays during cache invalidation

# Footer:

# Contributor: John Doe
# Flag: Experimental (incomplete)
# Future work:
# - Implement cache persistence for user data
# - Evaluate performance impact across different workloads
# - Explore alternative caching strategies for further optimization
