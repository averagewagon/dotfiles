#!/bin/sh
set -eu

###########################################################################
# install.sh
#
# This script automates the setup of symlinks from the dotfiles
# repository to the home directory. Pre-existing files will be backed up.
#
# Prerequisites:
# - zsh
###########################################################################

# Function to create a symbolic link and backup existing files
create_symlink() {
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

# Function to clone a git repository to a specified location
clone_repo() {
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

# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Install Oh My Zsh (must be done first, as it replaces .zshrc)
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
	echo "Oh My Zsh not found, installing..."
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh || true)"
else
	echo "Oh My Zsh already installed."
fi

# Set up .zshrc
create_symlink "${SCRIPT_DIR}/zsh/.zshrc" "${HOME}/.zshrc}"

# Ensure the ZSH_CUSTOM variable is set
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

# Clone zsh plugins
clone_repo "https://github.com/zsh-users/zsh-history-substring-search" "${ZSH_CUSTOM}/plugins/history-substring-search"
clone_repo "https://github.com/rupa/z.git" "${ZSH_CUSTOM}/plugins/z"
clone_repo "https://github.com/junegunn/fzf.git" "${HOME}/.fzf"

# Set up fzf
if [ -d "${HOME}/.fzf" ]; then
	echo "Installing fzf..."
	"${HOME}/.fzf/install" --all
fi

echo "Installation completed successfully."
