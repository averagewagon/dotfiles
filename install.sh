#!/bin/sh

###########################################################################
# install.sh
#
# This script automates the setup of symlinks from the dotfiles 
# repository to the home directory. Pre-existing files will be backed up.
###########################################################################

# Define the source and destination paths
DOTFILES_DIR="$(pwd)"
ZSHRC_SRC="$DOTFILES_DIR/zsh/.zshrc"
ZSHRC_DST="$HOME/.zshrc"

# Check if the destination symlink already exists and remove it if it does
if [ -L "$ZSHRC_DST" ]; then
    echo "Removing existing symlink at $ZSHRC_DST"
    rm "$ZSHRC_DST"
elif [ -e "$ZSHRC_DST" ]; then
    echo "Backing up existing file at $ZSHRC_DST"
    mv "$ZSHRC_DST" "${ZSHRC_DST}.backup"
fi

# Create a new symlink
echo "Creating new symlink for .zshrc"
ln -s "$ZSHRC_SRC" "$ZSHRC_DST"


# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh not found, installing..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh already installed."
fi

echo "Installation completed successfully."
