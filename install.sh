#!/bin/bash
set -e

INSTALL_DIR="$HOME/.local/bin"
BIN_NAME="mimir"

odin build src -out:mimir -o:aggressive

mkdir -p "$INSTALL_DIR"
mv mimir "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/$BIN_NAME"

echo "Installed to $INSTALL_DIR/$BIN_NAME"
echo "Make sure $INSTALL_DIR is in your PATH"
