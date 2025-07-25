#!/bin/bash

writefile="$1"
writestr="$2"

if [ $# -ne 2 ]; then
    echo "Usage: finder-app/writer.sh <filepath> <data>"
    exit 1
fi

# Ensure directory exists
mkdir -p "$(dirname "$writefile")"

# Attempt to create file
touch "$writefile" 2>/dev/null
rc=$?
if [ $rc -ne 0 ]; then 
    echo "Operation failed with rc: $rc"
    exit 1
fi

# Write string to file
echo "$writestr" > "$writefile" 2>/dev/null
rc=$?
if [ $rc -ne 0 ]; then 
    echo "Operation failed with rc: $rc"
    exit 1
fi
