#!/bin/sh

filesdir="$1"
searchstr="$2"

# Check for exactly 2 arguments
if [ $# -ne 2 ]; then
    echo "Required 2 arguments."
    exit 1
fi

# Check if the directory exists
if [ ! -d "$filesdir" ]; then
    echo "Directory '$filesdir' does not exist."
    exit 1
fi

# Count total number of files and directories inside the directory
entry_count=$(find "$filesdir" \( -type f \) | wc -l)

# Count total number of matching lines across all files
match=$(grep -rhi "$searchstr" "$filesdir" | wc -l)

# If no matches found, give a message
if [ "$match" -eq 0 ]; then
    echo "The search string was not matched in any file."
    exit 1
fi

echo "The number of files are ${entry_count} and the number of matching lines are ${match}"
