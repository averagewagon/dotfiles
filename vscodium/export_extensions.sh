#!/bin/sh
set -eu

###########################################################################
# export_extensions.sh
#
# Exports the list of installed extensions to vscodium_extensions.txt
###########################################################################

# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Path to the extensions file
EXTENSIONS_FILE="${SCRIPT_DIR}/vscodium_extensions.txt"

# Run VSCodium command to list extensions and save to a file
codium --list-extensions >"${EXTENSIONS_FILE}"

echo "Exported list of VSCodium extensions to ${EXTENSIONS_FILE}."
