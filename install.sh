#!/bin/sh

# Enable strict error handling
set -eu

# Run shellcheck on the current script if available
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "$0" || echo "Shellcheck found issues."
else
    echo "Shellcheck not found, skipping..."
fi

# Function to print an error message
error() {
    printf "\033[31mError: %s\033[0m\n" "$1" >&2
}

# Determine the repository root
REPO_ROOT=$(git rev-parse --show-toplevel)

# Source the helper script
# shellcheck disable=SC1091
. "$REPO_ROOT/helpers.sh"

# Function to prompt the user for input
prompt_user() {
    while true; do
        echo "$1 (y/n): "
        read -r response
        case "$response" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) echo "Please answer yes or no." ;;
        esac
    done
}

# Ensure prerequisites are met
ensure_prerequisites git

# Prompt the user for each module
if prompt_user "\nRun git_config/install.sh"; then
    echo "Running git_config/install.sh..."
    "$REPO_ROOT/git_config/install.sh"
fi

if prompt_user "\nRun shell/install.sh"; then
    echo "Running shell/install.sh..."
    "$REPO_ROOT/shell/install.sh"
fi

if prompt_user "\nRun vscodium/install.sh"; then
    echo "Running vscodium/install.sh..."
    "$REPO_ROOT/vscodium/install.sh"
fi

echo "Setup complete."
