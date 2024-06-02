#!/bin/sh
set -eu

##############################################################################
# install.sh
#
# This script automates the setup of symlinks from the dotfiles
# repository to the home directory. Pre-existing files will be backed up.
#
# Prerequisites:
# - zsh
# - vscodium
###########################################################################

#-----------------------------------------------------------------------------
# Helper functions
#-----------------------------------------------------------------------------
# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Creates a symbolic link and backups existing files
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

# Set up .zshrc
setup_symlink "${SCRIPT_DIR}/zsh/.zshrc" "${HOME}/.zshrc}"

# Ensure the ZSH_CUSTOM variable is set
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

# Clone zsh plugins
setup_repo "https://github.com/zsh-users/zsh-history-substring-search" "${ZSH_CUSTOM}/plugins/history-substring-search"
setup_repo "https://github.com/rupa/z.git" "${ZSH_CUSTOM}/plugins/z"
setup_repo "https://github.com/junegunn/fzf.git" "${HOME}/.fzf"

# Set up fzf
if [ -d "${HOME}/.fzf" ]; then
	echo "Installing fzf..."
	"${HOME}/.fzf/install" --all
fi

#-----------------------------------------------------------------------------
# VSCodium configuration
#-----------------------------------------------------------------------------
setup_symlink "${SCRIPT_DIR}/vscodium/settings.json" "${HOME}/.config/VSCodium/User/settings.json"

# Uncomment to use VSCode Marketplace
# setup_symlink "${SCRIPT_DIR}/vscodium/product.json" "${HOME}"/.config/VSCodium/product.json"

"${SCRIPT_DIR}/vscodium/install_extensions.sh"

echo "Installation completed successfully."
