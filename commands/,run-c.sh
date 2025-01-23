#!/bin/sh

# Enable strict error handling
set -eu

# Run shellcheck on the current script if available
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "$0" || echo "Shellcheck found issues."
else
    echo "Shellcheck not found, skipping..."
fi

# Check if a filename is provided
if [ -z "$1" ]; then
    echo "Usage: run-c.sh <filename.c>"
    exit 1
fi

# Check if the provided file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found."
    exit 1
fi

# Create a unique name for the temporary executable in the /tmp directory
TEMP_EXECUTABLE="/tmp/temp_executable_$$"

# Compile the C file
gcc "$1" -o "$TEMP_EXECUTABLE"
if [ $? -eq 0 ]; then
    # Run the executable
    "$TEMP_EXECUTABLE"
    # Clean up by removing the temporary executable
    rm -f "$TEMP_EXECUTABLE"
else
    echo "Compilation failed."
    exit 1
fi
