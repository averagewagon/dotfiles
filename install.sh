#!/bin/sh
set -eu

##############################################################################
# install.sh
#
# This script automates the setup of symlinks from the dotfiles
# repository to the home directory. Pre-existing files will be backed up.
#
# Prerequisites for VSCodium extensions:
# - zsh
# - vscodium
# - rustup
# - cppcheck
# - flawfinder
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

# Create .zshrc if it doesn't already exist
shared_rc="${SCRIPT_DIR}/zsh/.zshrc_shared"
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
setup_repo "https://github.com/junegunn/fzf.git" "${HOME}/.fzf"
setup_repo "https://github.com/zdharma-continuum/fast-syntax-highlighting.git" "${ZSH_CUSTOM}/plugins/fast-syntax-highlighting"
setup_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

# Set up fzf
if [ -d "${HOME}/.fzf" ]; then
	echo "Installing fzf..."
	"${HOME}/.fzf/install" --all
fi

#-----------------------------------------------------------------------------
# git configuration
#-----------------------------------------------------------------------------
git config --global core.excludesfile "${SCRIPT_DIR}"/git/.gitignore_global

#-----------------------------------------------------------------------------
# vscodium configuration
#-----------------------------------------------------------------------------
setup_symlink "${SCRIPT_DIR}/vscodium/settings.json" "${HOME}/.config/VSCodium/User/settings.json"

# Uncomment to use VSCode Marketplace
# setup_symlink "${SCRIPT_DIR}/vscodium/product.json" "${HOME}"/.config/VSCodium/product.json"

"${SCRIPT_DIR}/vscodium/install_extensions.sh"

echo "Installation completed successfully."
