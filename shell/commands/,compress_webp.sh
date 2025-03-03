#!/bin/sh

# Enable strict error handling
set -eu

# Run shellcheck on the current script if available
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "$0" || echo "Shellcheck found issues."
else
    echo "Shellcheck not found, skipping..."
fi

# Function to print an error message and exit
error() {
    printf "\033[31mError: %s\033[0m\n" "$1" >&2
    exit 1
}

# Check arguments
if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
    error "Usage: $0 <quality_level> <num_iterations> <output_width> <input_file> [output_file]"
fi

quality_level="$1"
num_iterations="$2"
output_width="$3"
input_file="$4"
output_file="${5:-${input_file%.*}.webp}"

# Verify input file exists
if [ ! -f "$input_file" ]; then
    error "Input file not found: $input_file"
fi

# Verify quality_level is an integer between 0 and 100
if ! [ "$quality_level" -eq "$quality_level" ] 2>/dev/null || [ "$quality_level" -lt 0 ] || [ "$quality_level" -gt 100 ]; then
    error "Quality level must be an integer between 0 and 100."
fi

# Verify num_iterations is a positive integer
if ! [ "$num_iterations" -eq "$num_iterations" ] 2>/dev/null || [ "$num_iterations" -le 0 ]; then
    error "Number of iterations must be a positive integer."
fi

# Verify output_width is a positive integer
if ! [ "$output_width" -eq "$output_width" ] 2>/dev/null || [ "$output_width" -le 0 ]; then
    error "Output width must be a positive integer."
fi

# Create a temporary directory for intermediate files
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Copy the input file to start the compression chain
tmp_output_file="${tmp_dir}/0.webp"
cp "$input_file" "$tmp_output_file"

# Resize the image to the specified width
resized_file="${tmp_dir}/resized.webp"
cwebp -resize "$output_width" 0 "$tmp_output_file" -o "$resized_file" || error "Resizing failed"
tmp_output_file="$resized_file"

# Run the specified number of compression iterations
for i in $(seq 1 "$num_iterations"); do
    next_tmp_output_file="${tmp_dir}/${i}.webp"
    cwebp -q "$quality_level" "$tmp_output_file" -o "$next_tmp_output_file" || error "Compression failed at iteration $i"
    tmp_output_file="$next_tmp_output_file"
    echo "Iteration $i completed: $tmp_output_file"
done

# Move the final compressed file to the specified output location
mv "$tmp_output_file" "$output_file"
echo "Final file: $output_file"
