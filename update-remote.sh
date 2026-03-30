#!/bin/bash

# Remote update script for bash-library
# This script can be run with: curl -sSL https://raw.githubusercontent.com/hperezrodal/bash-library/main/update-remote.sh | bash

set -euo pipefail

# Configuration
REPO_URL="https://github.com/hperezrodal/bash-library"
SYSTEM_INSTALL=${SYSTEM_INSTALL:-false}

# Determine installation paths based on whether it's a system install
if [ "$SYSTEM_INSTALL" = "true" ]; then
	INSTALL_DIR="${BASH_LIBRARY_PATH:-/usr/local/lib/bash-library}"
	BIN_DIR="/usr/local/bin"
else
	INSTALL_DIR="${BASH_LIBRARY_PATH:-$HOME/.local/lib/bash-library}"
	BIN_DIR="$HOME/.local/bin"
fi

TEMP_DIR=$(mktemp -d)

# Cleanup function
cleanup() {
	rm -rf "$TEMP_DIR"
}

# Trap cleanup on exit
trap cleanup EXIT

# Check if installation exists
if [ ! -d "$INSTALL_DIR" ]; then
	echo "Error: bash-library is not installed."
	echo "Please run the installation script first:"
	echo "curl -sSL https://raw.githubusercontent.com/hperezrodal/bash-library/main/install-remote.sh | bash"
	exit 1
fi

# Check for required commands
for cmd in curl git; do
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "Error: $cmd is required but not installed."
		exit 1
	fi
done

# Clone the latest version
echo "Downloading latest version..."
if ! git clone "$REPO_URL" "$TEMP_DIR"; then
	echo "Error: Failed to download the repository."
	exit 1
fi

# Copy updated files
echo "Updating bash library..."
cp -r "$TEMP_DIR/modules"/* "$INSTALL_DIR/modules/"
cp -r "$TEMP_DIR/scripts"/* "$INSTALL_DIR/scripts/"
cp "$TEMP_DIR/lib-loader.sh" "$INSTALL_DIR/"
cp "$TEMP_DIR/version" "$INSTALL_DIR/"

# Update symlinks
echo "Updating symlinks..."
for script in "$INSTALL_DIR/scripts"/*.sh; do
	if [ -f "$script" ]; then
		script_name=$(basename "$script" .sh)
		ln -sf "$script" "$BIN_DIR/$script_name"
	fi
done

# Set permissions
echo "Setting permissions..."
chmod -R 755 "$INSTALL_DIR"
chmod 644 "$INSTALL_DIR/modules"/*.sh
chmod 755 "$INSTALL_DIR/scripts"/*.sh

# Read updated version
VERSION=$(cat "$INSTALL_DIR/version")
echo "Updated to version $VERSION!"
echo "You may need to restart your shell or run: source ~/.bashrc"
