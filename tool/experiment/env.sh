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
# SOUFFLE SETUP
# ============================================

echo "[SETUP] Installing Souffle..."
# Add Souffle repository key
sudo wget https://souffle-lang.github.io/ppa/souffle-key.public -O /usr/share/keyrings/souffle-archive-keyring.gpg

# Add Souffle repository to sources list
echo "deb [signed-by=/usr/share/keyrings/souffle-archive-keyring.gpg] https://souffle-lang.github.io/ppa/ubuntu/ stable main" | sudo tee /etc/apt/sources.list.d/souffle.list

# Update package list and install Souffle
sudo apt update
sudo apt install -y souffle

echo "[SETUP] Souffle environment ready!"

# ============================================
# UMBRA SETUP
# ============================================

echo "[SETUP] Pulling Umbra Docker image..."
sudo docker pull umbradb/umbra:latest

echo "[DONE] Environment setup complete. Restart your terminal or run:"
echo "  export PATH=\"$HOME/bin:\$PATH\""
echo "  export PATH=\"$HOME/.cargo/bin:\$PATH\""

# ============================================
# DDLOG SETUP
# ============================================

echo "[SETUP] Installing DDlog..."
DDLOG_VERSION="v1.2.3"
DDLOG_TAR="ddlog-v1.2.3-20211213235218-Linux.tar.gz"
DDLOG_URL="https://github.com/vmware-archive/differential-datalog/releases/download/${DDLOG_VERSION}/${DDLOG_TAR}"
DDLOG_INSTALL_DIR="$HOME/ddlog"

mkdir -p "$DDLOG_INSTALL_DIR"
curl -L "$DDLOG_URL" -o "$HOME/$DDLOG_TAR"
tar -xzf "$HOME/$DDLOG_TAR" -C "$DDLOG_INSTALL_DIR" --strip-components=1
rm "$HOME/$DDLOG_TAR"

# Add ddlog/bin to PATH in .bashrc if missing
if ! grep -q 'export PATH="$HOME/ddlog/bin:$PATH"' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/ddlog/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Set DDLOG_HOME in .bashrc if missing
if ! grep -q 'export DDLOG_HOME="$HOME/ddlog"' "$HOME/.bashrc"; then
    echo 'export DDLOG_HOME="$HOME/ddlog"' >> "$HOME/.bashrc"
fi

# Export for current session
export PATH="$HOME/ddlog/bin:$PATH"
export DDLOG_HOME="$HOME/ddlog"

echo "[SETUP] DDlog environment ready!"