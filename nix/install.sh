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

# Determine the directory of the script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Determine the repository root relative to the script directory
REPO_ROOT=$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)

# Source the helper script
# shellcheck disable=SC1091
. "$REPO_ROOT/helpers.sh"

# Ensure prerequisites are met
ensure_prerequisites curl

# Ensure Nix is installed
if ! command_exists nix; then
    # Install Nix using detsys
    echo "Installing Nix using detsys..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    # Ensure Nix is installed
    if ! command_exists nix; then
        error "Nix installation failed. Please try again."
        exit 1
    fi
fi

echo "Nix installation complete."
