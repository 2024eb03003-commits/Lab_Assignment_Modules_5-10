#!/bin/bash

# Check for exactly one argument
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one log file as argument."
    exit 1
fi

LOGFILE="$1"

# Validate file existence
if [ ! -e "$LOGFILE" ]; then
    echo "Error: File does not exist."
    exit 1
fi

# Validate file readability
if [ ! -r "$LOGFILE" ]; then
    echo "Error: File is not readable."
    exit 1
fi

# Count total log entries
total_entries=$(wc -l < "$LOGFILE")

# Count log levels
info_count=$(grep -c " INFO " "$LOGFILE")
warning_count=$(grep -c " WARNING " "$LOGFILE")
error_count=$(grep -c " ERROR " "$LOGFILE")

# Get most recent ERROR message
recent_error=$(grep " ERROR " "$LOGFILE" | tail -n 1)

# Report file name
report_date=$(date +"%Y-%m-%d")
report_file="logsummary_${report_date}.txt"

# Display results
echo "Log File Analysis"
echo "-----------------"
echo "Total log entries : $total_entries"
echo "INFO messages     : $info_count"
echo "WARNING messages  : $warning_count"
echo "ERROR messages    : $error_count"

if [ -n "$recent_error" ]; then
    echo "Most recent ERROR : $recent_error"
else
    echo "Most recent ERROR : None found"
fi

# Generate report file
{
    echo "Log Summary Report - $report_date"
    echo "--------------------------------"
    echo "Log file          : $LOGFILE"
    echo "Total entries     : $total_entries"
    echo "INFO messages     : $info_count"
    echo "WARNING messages  : $warning_count"
    echo "ERROR messages    : $error_count"
    echo "Most recent ERROR :"
    echo "${recent_error:-None}"
} > "$report_file"

echo
echo "Report generated: $report_file"
