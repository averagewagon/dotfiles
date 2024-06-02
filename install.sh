#!/bin/sh
set -eu

###########################################################################
# install.sh
#
# This script automates the setup of symlinks from the dotfiles
# repository to the home directory. Pre-existing files will be backed up.
###########################################################################

# Install Oh My Zsh (must be done first, as it replaces .zshrc)
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
	echo "Oh My Zsh not found, installing..."
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh || true)"
else
	echo "Oh My Zsh already installed."
fi

# Define the source and destination paths for zshrc
DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
ZSHRC_SRC="${DOTFILES_DIR}/zsh/.zshrc"
ZSHRC_DST="${HOME}/.zshrc"

# Check if the destination symlink already exists and remove it if it does
if [ -L "${ZSHRC_DST}" ]; then
	echo "Removing existing symlink at ${ZSHRC_DST}"
	rm "${ZSHRC_DST}"
elif [ -e "${ZSHRC_DST}" ]; then
	echo "Backing up existing file at ${ZSHRC_DST}"
	mv "${ZSHRC_DST}" "${ZSHRC_DST}.backup"
fi

# Create a new symlink
echo "Creating new symlink for .zshrc"
ln -s "${ZSHRC_SRC}" "${ZSHRC_DST}"

echo "Installation completed successfully."
