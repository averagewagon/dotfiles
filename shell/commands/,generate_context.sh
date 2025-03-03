#!/bin/sh

# Enable strict error handling for better script durability
set -eu

# Define the output file and temporary file
OUTPUT_FILE="context.txt"
TEMP_FILE="/tmp/context.tmp"

# Remove existing files
rm $OUTPUT_FILE $TEMP_FILE >/dev/null 2>&1 || true

# Function to recursively print file contents with headers
print_file_recursively() {
    entry="$1"
    strip="$2"

    if [ -f "$entry" ]; then
        relative_path="${entry#$strip/}"

        # Write the header and file contents to the temporary file
        {
            printf "==================================================\n"
            printf "Contents of %s:\n" "$relative_path"
            printf "==================================================\n"
            cat "$entry"
            printf "\n\n"
        } >>"$TEMP_FILE"
    elif [ -d "$entry" ]; then
        for sub_entry in "$entry"/*; do
            print_file_recursively "$sub_entry" "$strip"
        done
    fi
}

# Initialize the temporary file
{
    printf "Context Dump - %s\n" "$(date)"
    printf "Generated from directory: %s\n" "$(pwd)"
    printf "\n"
} >"$TEMP_FILE"

# Loop through all files and directories in the current directory
for entry in *; do
    exclude=false

    # Check if the entry should be excluded
    for exclude_arg in "$@"; do
        case "$entry" in
        *"$exclude_arg"*)
            exclude=true
            break
            ;;
        esac
    done

    if [ "$exclude" = false ]; then
        if [ -f "$entry" ] || [ -d "$entry" ]; then
            print_file_recursively "$entry" "$(pwd)"
        fi
    fi
done

# Move the temporary file to the output file
mv "$TEMP_FILE" "$OUTPUT_FILE"

printf "Context dump completed. Output written to %s\n" "$OUTPUT_FILE"
