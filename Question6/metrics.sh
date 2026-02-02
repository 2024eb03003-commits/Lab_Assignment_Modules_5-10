#!/bin/bash

# Check if input file exists
INPUT_FILE="input.txt"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' does not exist."
    exit 1
fi

# Normalize text: lowercase, remove punctuation, one word per line
WORDS=$(tr '[:upper:]' '[:lower:]' < "$INPUT_FILE" \
        | tr -cd '[:alnum:][:space:]\n' \
        | tr ' ' '\n')

# Longest word
LONGEST=$(echo "$WORDS" | awk '{ print length, $0 }' | sort -nr | head -1 | awk '{print $2}')

# Shortest word
SHORTEST=$(echo "$WORDS" | awk '{ print length, $0 }' | sort -n | head -1 | awk '{print $2}')

# Average word length
AVG_LENGTH=$(echo "$WORDS" | awk '{ sum+=length; count++ } END { if(count>0) print sum/count; else print 0 }')

# Total number of unique words
UNIQUE_COUNT=$(echo "$WORDS" | sort | uniq | wc -l)

# Display metrics
echo "Text Metrics for '$INPUT_FILE'"
echo "-------------------------------"
echo "Longest word       : $LONGEST"
echo "Shortest word      : $SHORTEST"
echo "Average word length: $AVG_LENGTH"
echo "Unique words count : $UNIQUE_COUNT"