#!/bin/sh
set -eu

###########################################################################
# install_extensions.sh
#
# Installs everything in vscodium_extensions.txt using the vscodium CLI
###########################################################################

echo "Installing VSCodium extensions..."

# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Path to the extensions file
EXTENSIONS_FILE="${SCRIPT_DIR}/vscodium_extensions.txt"

# Check if extensions.txt exists
if [ ! -f "${EXTENSIONS_FILE}" ]; then
	echo "Error: ${EXTENSIONS_FILE} not found."
	exit 1
fi

# Get the list of currently installed extensions and store it in a variable
INSTALLED_EXTENSIONS=$(codium --list-extensions)

# Function to check if an extension is already installed
is_installed() {
	echo "${INSTALLED_EXTENSIONS}" | grep -q "^$1\$"
}

# Read each line in extensions.txt and install the extension
while IFS= read -r extension; do
	if is_installed "${extension}"; then
		echo "VSCodium extension ${extension} is already installed."
	else
		codium --install-extension "${extension}" --force
	fi
done <"${EXTENSIONS_FILE}"

echo "All extensions listed in ${EXTENSIONS_FILE} have been installed."
