#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

DIR="$1"

# Validate directory exists and is writable
if [ ! -d "$DIR" ]; then
    echo "Error: $DIR is not a directory" >&2
    exit 1
fi

if [ ! -w "$DIR" ]; then
    echo "Error: $DIR is not writable" >&2
    exit 1
fi

# Create backup subdirectory if it doesn't exist
mkdir -p "$DIR/backup"

# Counter for process tracking
pid_count=0
pids=()

echo "Moving files from $DIR to $DIR/backup in background..."
echo "Script PID: $$"

# Loop through regular files and move in background
for file in "$DIR"/*; do
    # Skip if not a regular file or backup dir
    [ ! -f "$file" ] && continue
    [ "$(basename "$file")" = "backup" ] && continue
    
    pid_count=$((pid_count + 1))
    echo "Starting background move #$pid_count: $(basename "$file")"
    
    # Move in background, capture PID with $!
    mv "$file" "$DIR/backup/" &
    pids[$pid_count]=$!
    echo "  PID: ${pids[$pid_count]}"
done

echo
echo "Started $pid_count background processes. Waiting for completion..."

# Wait for ALL background processes
for pid in "${pids[@]}"; do
    if [ -n "$pid" ]; then
        wait "$pid"
        echo "Process PID $pid completed"
    fi
done

echo "All background moves completed!"
echo "Backup directory: $DIR/backup"
ls -l "$DIR/backup/"
