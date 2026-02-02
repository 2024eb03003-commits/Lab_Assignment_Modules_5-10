#!/bin/bash

# Check for exactly one argument
if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one argument (file or directory path) is required."
    exit 1
fi

path="$1"

# Check if path exists and is a file
if [ -f "$path" ]; then
    # Display number of lines, words, and characters
    wc "$path"
    exit 0

# Check if path exists and is a directory
elif [ -d "$path" ]; then
    # Total number of files (non-recursive)
    total_files=$(find "$path" -maxdepth 1 -type f -printf x | wc -c)

    # Number of .txt files (non-recursive)
    txt_files=$(find "$path" -maxdepth 1 -type f -name "*.txt" -printf x | wc -c)

    echo "Total files in directory: $total_files"
    echo "Number of .txt files: $txt_files"
    exit 0

# Path does not exist or is neither file nor directory
else
    echo "Error: Path does not exist or is not a regular file/directory."
    exit 1
fi
