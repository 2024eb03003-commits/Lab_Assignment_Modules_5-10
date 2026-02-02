#!/usr/bin/env bash

FILE="marks.txt"
PASS_MARK=33

# Validate file
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found."
    exit 1
fi

if [ ! -r "$FILE" ]; then
    echo "Error: $FILE is not readable."
    exit 1
fi

echo "Students failed in exactly ONE subject:"
echo "--------------------------------------"

count_fail_one=0
count_pass_all=0
total_students=0

# Read file line by line
while IFS=',' read -r roll name m1 m2 m3; do
    # Skip empty lines
    [ -z "$roll" ] && continue

    # Trim leading/trailing spaces (simple approach)
    roll=$(echo "$roll" | xargs)
    name=$(echo "$name" | xargs)
    m1=$(echo "$m1" | xargs)
    m2=$(echo "$m2" | xargs)
    m3=$(echo "$m3" | xargs)

    # Ensure numeric marks
    # (basic guard; you can skip if input is guaranteed clean)
    for mark in "$m1" "$m2" "$m3"; do
        case "$mark" in
            ''|*[!0-9]*) 
                echo "Warning: Invalid marks for $roll $name, skipping."
                continue 2
                ;;
        esac
    done

    total_students=$((total_students + 1))

    fail_count=0
    [ "$m1" -lt "$PASS_MARK" ] && fail_count=$((fail_count + 1))
    [ "$m2" -lt "$PASS_MARK" ] && fail_count=$((fail_count + 1))
    [ "$m3" -lt "$PASS_MARK" ] && fail_count=$((fail_count + 1))

    if [ "$fail_count" -eq 1 ]; then
        echo "$roll - $name (Marks: $m1, $m2, $m3)"
        count_fail_one=$((count_fail_one + 1))
    elif [ "$fail_count" -eq 0 ]; then
        count_pass_all=$((count_pass_all + 1))
    fi

done < "$FILE"

echo
echo "Students passed in ALL subjects:"
echo "--------------------------------"

# Second pass to print pass‑all list (to keep logic simple)
while IFS=',' read -r roll name m1 m2 m3; do
    [ -z "$roll" ] && continue

    roll=$(echo "$roll" | xargs)
    name=$(echo "$name" | xargs)
    m1=$(echo "$m1" | xargs)
    m2=$(echo "$m2" | xargs)
    m3=$(echo "$m3" | xargs)

    for mark in "$m1" "$m2" "$m3"; do
        case "$mark" in
            ''|*[!0-9]*) 
                continue 2
                ;;
        esac
    done

    fail_count=0
    [ "$m1" -lt "$PASS_MARK" ] && fail_count=$((fail_count + 1))
    [ "$m2" -lt "$PASS_MARK" ] && fail_count=$((fail_count + 1))
    [ "$m3" -lt "$PASS_MARK" ] && fail_count=$((fail_count + 1))

    if [ "$fail_count" -eq 0 ]; then
        echo "$roll - $name (Marks: $m1, $m2, $m3)"
    fi

done < "$FILE"

echo
echo "Summary:"
echo "--------"
echo "Total students                 : $total_students"
echo "Failed in exactly ONE subject : $count_fail_one"
echo "Passed in ALL subjects        : $count_pass_all"
