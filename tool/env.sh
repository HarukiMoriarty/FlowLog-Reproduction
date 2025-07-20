#!/bin/bash
set -e

# ============================================
# Environment Setup for DuckDB and Umbra
# ============================================

echo "[SETUP] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[SETUP] Installing dependencies..."
sudo apt install -y curl unzip docker.io

# Enable and start Docker
sudo systemctl enable --now docker

# ============================================
# DUCKDB SETUP
# ============================================

echo "[SETUP] Setting up DuckDB..."

# Download DuckDB
DUCKDB_CLI_URL="https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip"
DUCKDB_INSTALL_DIR="$HOME/bin"
mkdir -p "$DUCKDB_INSTALL_DIR"
curl -L "$DUCKDB_CLI_URL" -o "$DUCKDB_INSTALL_DIR/duckdb.zip"
unzip -o "$DUCKDB_INSTALL_DIR/duckdb.zip" -d "$DUCKDB_INSTALL_DIR"
chmod +x "$DUCKDB_INSTALL_DIR/duckdb"
rm "$DUCKDB_INSTALL_DIR/duckdb.zip"

# Add to PATH
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Create DuckDB data dir
export DUCKDB_DATA_DIR="$HOME/data/duckdb"
mkdir -p "$DUCKDB_DATA_DIR"

# ============================================
# UMBRA SETUP
# ============================================

echo "[SETUP] Setting up Umbra..."

# Pull the Umbra Docker image
docker pull umbradb/umbra:latest

# Setup Umbra data directory
export HOSTDATA="$HOME/data/umbra"
mkdir -p "$HOSTDATA"

# ============================================
# ENVIRONMENT EXPORTS
# ============================================

echo "[SETUP] Writing environment setup to ~/.duck_umbra_env"

cat <<'EOF' > "$HOME/.duck_umbra_env"
# ========== DUCKDB ==========
export DUCKDB_CLI_PATH="$HOME/bin/duckdb"
export PATH="$DUCKDB_CLI_PATH:$PATH"
export DUCKDB_DATA_DIR="$HOME/data/duckdb"
alias duckdb='duckdb'

# ========== UMBRA ==========
export UMBRA_IMAGE="umbradb/umbra:latest"
export UMBRA_DB="/var/db/umbra.db"
export HOSTDATA="$HOME/data/umbra"
alias umbra_run='docker run --rm -e UMBRA_THREADS=64 -v umbra-db:/var/db -v $HOSTDATA:/hostdata $UMBRA_IMAGE bash -c'
EOF

# Append to .bashrc if not already sourced
if ! grep -q 'source ~/.duck_umbra_env' "$HOME/.bashrc"; then
    echo 'source ~/.duck_umbra_env' >> "$HOME/.bashrc"
fi

echo "[DONE] Environment setup complete."
