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
ensure_prerequisites codium

# Creates a symbolic link and backs up existing files
setup_symlink() {
    src=$1
    dst=$2
    if [ -L "${dst}" ]; then
        echo "Removing existing symlink at ${dst}"
        rm "${dst}"
    elif [ -e "${dst}" ]; then
        echo "Backing up existing file at ${dst}"
        mv "${dst}" "${dst}.backup"
    fi
    echo "Creating new symlink for ${dst}"
    ln -s "${src}" "${dst}"
}

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

#-----------------------------------------------------------------------------
# vscodium configuration
#-----------------------------------------------------------------------------
setup_symlink "$REPO_ROOT/vscodium/settings.json" "$HOME/.config/VSCodium/User/settings.json"

# Prompt to use VSCode Marketplace
if prompt_user "Would you like to use VSCode Marketplace extensions?"; then
    setup_symlink "$REPO_ROOT/vscodium/product.json" "$HOME/.config/VSCodium/product.json"
fi

# Initialize an empty string to hold extensions to install
extensions_to_install=""

# Install extensions listed in vscodium_extensions.txt
EXTENSIONS_FILE="$REPO_ROOT/vscodium/vscodium_extensions.txt"
if [ -f "$EXTENSIONS_FILE" ]; then
    EXTENSIONS=$(cat "$EXTENSIONS_FILE")
    for extension in $EXTENSIONS; do
        if [ -n "$extension" ]; then
            if prompt_user "Would you like to install the extension: $extension?"; then
                extensions_to_install="$extensions_to_install $extension"
            fi
        fi
    done
else
    error "Extensions file not found: $EXTENSIONS_FILE"
fi

# Install all selected extensions
if [ -n "$extensions_to_install" ]; then
    echo "Installing selected extensions..."
    for extension in $extensions_to_install; do
        codium --install-extension "$extension" --force
    done
else
    echo "No extensions selected for installation."
fi

echo "VS Codium configuration complete."
