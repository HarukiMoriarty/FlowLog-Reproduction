#!/bin/bash
set -e

# ============================================
# Environment Setup for DuckDB, Umbra, and FlowLog
# ============================================

echo "[SETUP] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[SETUP] Installing dependencies..."
# Check for required packages and add missing ones to install list
packages=("curl" "unzip" "docker.io")
command -v htop >/dev/null || packages+=("htop")          # System monitor
command -v dos2unix >/dev/null || packages+=("dos2unix")  # Line ending converter

# Install packages
sudo apt install -y "${packages[@]}"

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
# FLOWLOG SETUP
# ============================================

echo "[SETUP] Installing Rust toolchain..."
# Check if Rust is already installed
if ! command -v rustc >/dev/null; then
    # Install Rust using the official installer
    echo "[INSTALL] Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Add Rust to PATH for current session and future sessions
    export PATH="$HOME/.cargo/bin:$PATH"
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
else
    echo "[OK] Rust is already installed"
fi

echo "[UPDATE] Moving Rust to latest version..."
rustup update && rustup default stable

source ~/.bashrc

echo "[SETUP] FlowLog environment ready!"

# ============================================
# UMBRA SETUP
# ============================================

echo "[SETUP] Pulling Umbra Docker image..."
sudo docker pull umbradb/umbra:latest

echo "[DONE] Environment setup complete. Restart your terminal or run:"
echo "  export PATH=\"$HOME/bin:\$PATH\""
echo "  export PATH=\"$HOME/.cargo/bin:\$PATH\""
