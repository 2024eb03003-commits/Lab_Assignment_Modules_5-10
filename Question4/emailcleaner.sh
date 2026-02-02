#!/bin/bash

# Check if input file exists
if [ ! -f "emails.txt" ]; then
    echo "Error: emails.txt not found" >&2
    exit 1
fi

echo "Processing emails.txt..."

# Clear output files
> valid.txt
> invalid.txt

# Extract VALID emails: <letters_and_digits>@<letters>.com
# Pattern: [a-zA-Z0-9]+@[a-zA-Z]+\.com
grep -E '[a-zA-Z0-9]+@[a-zA-Z]+\.com' emails.txt | sort | uniq > valid.txt

# Extract INVALID emails: everything else (non-empty lines)
grep -vE '[a-zA-Z0-9]+@[a-zA-Z]+\.com' emails.txt | grep -v '^$' | sort > invalid.txt

# Display summary
echo "Valid emails   : $(wc -l < valid.txt)"
echo "Invalid emails : $(wc -l < invalid.txt)"
echo "Results saved to valid.txt and invalid.txt"
