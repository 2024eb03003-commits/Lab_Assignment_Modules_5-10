#!/bin/bash

# Check if input file is provided as argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"

# Validate that file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' does not exist."
    exit 1
fi

# Clear previous output files
> vowels.txt
> consonants.txt
> mixed.txt

# Process words
tr '[:upper:]' '[:lower:]' < "$INPUT_FILE" \
| tr -s '[:space:]' '\n' \
| tr -d '[:punct:]' \
| while read word; do
    [ -z "$word" ] && continue  # Skip empty lines

    if [[ $word =~ ^[aeiou]+$ ]]; then
        # Only vowels
        echo "$word" >> vowels.txt
    elif [[ $word =~ ^[^aeiou]+$ ]]; then
        # Only consonants
        echo "$word" >> consonants.txt
    elif [[ $word =~ ^[^aeiou] ]]; then
        # Mixed words starting with consonant
        echo "$word" >> mixed.txt
    fi
done

echo "Classification complete!"
echo "Vowels only words        -> vowels.txt"
echo "Consonants only words    -> consonants.txt"
echo "Mixed words starting with consonant -> mixed.txt"
