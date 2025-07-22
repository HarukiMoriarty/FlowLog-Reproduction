#!/bin/bash
set -e

# ============================================
# Environment Setup for DuckDB and Umbra
# ============================================

echo "[SETUP] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[SETUP] Installing dependencies..."
sudo apt install -y curl unzip docker.io

echo "[SETUP] Starting Docker service..."
sudo systemctl enable --now docker

# ============================================
# DUCKDB SETUP
# ============================================

echo "[SETUP] Installing DuckDB CLI..."
DUCKDB_CLI_URL="https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip"
DUCKDB_INSTALL_DIR="$HOME/bin"
mkdir -p "$DUCKDB_INSTALL_DIR"
curl -L "$DUCKDB_CLI_URL" -o "$DUCKDB_INSTALL_DIR/duckdb.zip"
unzip -o "$DUCKDB_INSTALL_DIR/duckdb.zip" -d "$DUCKDB_INSTALL_DIR"
chmod +x "$DUCKDB_INSTALL_DIR/duckdb"
rm "$DUCKDB_INSTALL_DIR/duckdb.zip"

# Add $HOME/bin to PATH in .bashrc if missing
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Create DuckDB data directory
mkdir -p "$HOME/data/duckdb"

# ============================================
# UMBRA SETUP
# ============================================

echo "[SETUP] Pulling Umbra Docker image..."
sudo docker pull umbradb/umbra:latest

echo "[DONE] Environment setup complete. Restart your terminal or run:"
echo "  export PATH=\"$HOME/bin:\$PATH\""
