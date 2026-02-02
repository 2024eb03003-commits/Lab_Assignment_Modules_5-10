#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <dirA> <dirB>" >&2
    exit 1
fi

dirA="$1"
dirB="$2"

# Validate directories
[ ! -d "$dirA" ] && { echo "Error: $dirA is not a directory" >&2; exit 1; }
[ ! -d "$dirB" ] && { echo "Error: $dirB is not a directory" >&2; exit 1; }
[ ! -r "$dirA" ] || [ ! -r "$dirB" ] && { echo "Error: Directories must be readable" >&2; exit 1; }

echo "Comparing directories: $dirA vs $dirB"
echo "=============================================="

# Extract BASENAMES for comparison
echo "Files ONLY in $dirA:"
comm -23 <(find "$dirA" -type f | sed "s|$dirA/||" | sort) \
        <(find "$dirB" -type f | sed "s|$dirB/||" | sort) | sed 's|^|  |'

echo
echo "Files ONLY in $dirB:"
comm -13 <(find "$dirA" -type f | sed "s|$dirA/||" | sort) \
        <(find "$dirB" -type f | sed "s|$dirB/||" | sort) | sed 's|^|  |'

echo
echo "Common files with DIFFERENT contents:"
common_files=$(comm -12 <(find "$dirA" -type f | sed "s|$dirA/||" | sort) \
                       <(find "$dirB" -type f | sed "s|$dirB/||" | sort))

if [ -n "$common_files" ]; then
    echo "$common_files" | while IFS= read -r basename; do
        fileA="$dirA/$basename"
        fileB="$dirB/$basename"
        if [ -f "$fileA" ] && [ -f "$fileB" ] && ! diff -q "$fileA" "$fileB" >/dev/null 2>&1; then
            echo "  $basename"
        fi
    done
else
    echo "  None"
fi

echo "=============================================="
