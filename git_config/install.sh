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

# Ensure prerequisites are met
ensure_prerequisites git nvim diff3

# Check if delta is installed
if ! command_exists delta; then
    error "delta is not installed. Please install it and try again."
    exit 1
fi

# Function to prompt the user for Git configuration details
prompt_git_config() {
    echo "Setting up Git configuration..."

    # Prompt for user name
    echo "Enter your name to use with git:"
    read -r git_name
    git config --global user.name "$git_name"

    # Prompt for user email
    echo "Enter your email to use with git:"
    read -r git_email
    git config --global user.email "$git_email"

    echo "Git configuration completed."
}

# Set the global ignore file
echo "Setting up global .gitignore file..."
cp -n "$REPO_ROOT/git_config/.gitignore_global" ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

# Set the default branch to main
git config --global init.defaultBranch main

# Set the default editor to nvim
git config --global core.editor "nvim"

# Configure Delta settings
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.dark true
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global delta.hyperlinks true
git config --global merge.conflictStyle diff3

# Run the Git configuration prompt
prompt_git_config
