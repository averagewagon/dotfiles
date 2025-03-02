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
COMMANDS_DIR="$REPO_ROOT/shell/commands"

# Source the helper script
# shellcheck disable=SC1091
. "$REPO_ROOT/helpers.sh"

# Ensure prerequisites are met
ensure_prerequisites zsh

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

# Clone a git repository to a specified location. Pulls if it already exists.
setup_repo() {
    repo=$1
    dest=$2
    if [ ! -d "${dest}" ]; then
        echo "Cloning ${repo} into ${dest}..."
        git clone "${repo}" "${dest}"
    elif [ -d "${dest}/.git" ]; then
        echo "Updating ${dest} from ${repo}..."
        git -C "${dest}" pull
    else
        echo "${dest} exists but is not a Git repository. Skipping update."
    fi
}

#-----------------------------------------------------------------------------
# zsh configuration
#-----------------------------------------------------------------------------
# Install Oh My Zsh (must be done first, as it replaces .zshrc)
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    echo "Oh My Zsh not found, installing..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh || true)"
else
    echo "Oh My Zsh already installed."
fi

# Create .zshrc if it doesn't already exist
shared_rc="$REPO_ROOT/shell/.zshrc_shared"
if [ ! -f "${HOME}/.zshrc" ]; then
    echo "#!/bin/zsh" >"${HOME}/.zshrc"
    echo "Created new .zshrc file in ${HOME}."
fi

# Check if .zshrc already sources .zshrc_shared and add it if it doesn't
if ! grep -q "source ${shared_rc}" "${HOME}/.zshrc"; then
    echo "# Source .zshrc_shared from dotfiles" >>"${HOME}/.zshrc"
    echo "source ${shared_rc}" >>"${HOME}/.zshrc"
    echo "Added source command for .zshrc_shared in .zshrc."
fi

# Ensure the ZSH_CUSTOM variable is set
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

# Clone zsh plugins
setup_repo "https://github.com/zsh-users/zsh-history-substring-search.git" "${ZSH_CUSTOM}/plugins/history-substring-search"
setup_repo "https://github.com/rupa/z.git" "${ZSH_CUSTOM}/plugins/z"
setup_repo "https://github.com/zdharma-continuum/fast-syntax-highlighting.git" "${ZSH_CUSTOM}/plugins/fast-syntax-highlighting"
setup_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

#-----------------------------------------------------------------------------
# commands configuration
#-----------------------------------------------------------------------------
# Add the commands directory to PATH
if ! echo "$PATH" | grep -q "$COMMANDS_DIR"; then
    echo "export PATH=\"$COMMANDS_DIR:\$PATH\"" >>"${HOME}/.zshrc"
    echo "Added $COMMANDS_DIR to PATH in ~/.zshrc"
fi

#-----------------------------------------------------------------------------
# commands autocompletion configuration
#-----------------------------------------------------------------------------
COMPLETION_SCRIPT="${HOME}/.zsh/completions/_commands"

# Create the directory for Zsh completion scripts if it doesn't exist
mkdir -p "${HOME}/.zsh/completions"

# Generate the Zsh autocompletion script
cat <<'EOF' >"$COMPLETION_SCRIPT"
#compdef _commands

# Dynamically fetch all executable scripts in the commands/ folder
COMMANDS_DIR=${COMMANDS_DIR}
_arguments '*:script:($(find $COMMANDS_DIR -maxdepth 1 -type f -executable -exec basename {} \;))'
EOF

# Ensure Zsh knows where to find the completion script
if ! grep -q "fpath+=${HOME}/.zsh/completions" "${HOME}/.zshrc"; then
    echo "fpath+=${HOME}/.zsh/completions" >>"${HOME}/.zshrc"
    echo "Added ${HOME}/.zsh/completions to fpath in ~/.zshrc"
fi

# Load and enable autocompletion
if ! grep -q "autoload -Uz compinit && compinit" "${HOME}/.zshrc"; then
    echo "autoload -Uz compinit && compinit" >>"${HOME}/.zshrc"
    echo "Enabled Zsh autocompletion in ~/.zshrc"
fi

echo "Setup complete for shell."
