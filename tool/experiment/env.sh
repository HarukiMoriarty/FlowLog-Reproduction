#!/bin/bash
set -e

# ============================================
# Datalog DB Benchmark Environment Setup
# ============================================

# Global configuration
WORK_DIR="${WORK_DIR:-$HOME}"
HOME_BIN_DIR="$HOME/bin"
CARGO_BIN_DIR="$HOME/.cargo/bin"
DDLOG_DIR="$HOME/ddlog"

# Available systems
AVAILABLE_SYSTEMS=("duckdb" "flowlog" "souffle" "umbra" "ddlog" "recstep")
SELECTED_SYSTEMS=()

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --all)
                SELECTED_SYSTEMS=("${AVAILABLE_SYSTEMS[@]}")
                shift
                ;;
            --systems)
                shift
                IFS=',' read -ra SELECTED_SYSTEMS <<< "$1"
                shift
                ;;
            --list)
                echo "Available systems: ${AVAILABLE_SYSTEMS[*]}"
                exit 0
                ;;
            *)
                # Check if it's a valid system name
                if [[ " ${AVAILABLE_SYSTEMS[*]} " =~ " $1 " ]]; then
                    SELECTED_SYSTEMS+=("$1")
                else
                    echo "Error: Unknown system '$1'"
                    echo "Use --list to see available systems"
                    exit 1
                fi
                shift
                ;;
        esac
    done
}

# Show help information
show_help() {
    cat << EOF
Datalog DB Benchmark Environment Setup

Usage: $0 [OPTIONS] [SYSTEMS...]

OPTIONS:
    --help, -h          Show this help message
    --all               Install all available systems
    --systems <list>    Install comma-separated list of systems
    --list              List all available systems

SYSTEMS:
    duckdb              DuckDB CLI
    flowlog             Rust/Cargo (for FlowLog)
    souffle             Souffle Datalog engine
    umbra               Umbra (Docker)
    ddlog               DDlog (Differential Datalog)
    recstep             RecStep (with Quickstep)

EXAMPLES:
    $0 --all                    # Install all systems
    $0 duckdb souffle           # Install only DuckDB and Souffle
    $0 --systems duckdb,flowlog # Install DuckDB and FlowLog
    $0                          # Install only basic environment

NOTES:
    - Basic system dependencies are always installed
    - Multiple systems can be specified
    - Invalid system names will show an error
EOF
}

# ============================================
# Helper Functions
# ============================================

# Add directory to PATH in .bashrc if not already present
add_to_path() {
    local dir="$1"
    local path_export="export PATH=\"$dir:\$PATH\""
    
    if ! grep -Fq "$path_export" "$HOME/.bashrc"; then
        echo "$path_export" >> "$HOME/.bashrc"
        echo "[INFO] Added $dir to PATH in .bashrc"
    fi
    
    # Export for current session
    export PATH="$dir:$PATH"
}

# Add environment variable to .bashrc if not already present
add_env_var() {
    local var_export="$1"
    
    if ! grep -Fq "$var_export" "$HOME/.bashrc"; then
        echo "$var_export" >> "$HOME/.bashrc"
        echo "[INFO] Added environment variable: $var_export"
    fi
}

# ============================================
# System Dependencies Setup (Always Required)
# ============================================

setup_basic_environment() {
    echo "[SETUP] Setting up basic environment..."
    echo "[SETUP] Updating system packages..."
    sudo apt update && sudo apt upgrade -y

    echo "[SETUP] Installing system dependencies..."
    # Check for required packages and add missing ones to install list
    packages=("curl" "unzip" "docker.io" "wget" "git" "build-essential")
    command -v htop >/dev/null 2>&1 || packages+=("htop")          # System monitor
    command -v dos2unix >/dev/null 2>&1 || packages+=("dos2unix")  # Line ending converter

    # Install packages if needed
    if [ ${#packages[@]} -gt 0 ]; then
        sudo apt install -y "${packages[@]}"
    fi

    echo "[SETUP] Configuring Docker service..."
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    
    echo "[OK] Basic environment setup completed!"
}

# ============================================
# DuckDB Setup
# ============================================

install_duckdb() {
    echo "[SETUP] Installing DuckDB CLI..."
    local duckdb_url="https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip"
    
    # Create bin directory
    mkdir -p "$HOME_BIN_DIR"
    
    # Download and install DuckDB
    curl -L "$duckdb_url" -o "$HOME_BIN_DIR/duckdb.zip"
    unzip -o "$HOME_BIN_DIR/duckdb.zip" -d "$HOME_BIN_DIR"
    chmod +x "$HOME_BIN_DIR/duckdb"
    rm "$HOME_BIN_DIR/duckdb.zip"
    
    # Add to PATH if not already present
    add_to_path "$HOME_BIN_DIR"
    
    # Create DuckDB data directory
    mkdir -p "$HOME/data/duckdb"
    
    echo "[OK] DuckDB installed successfully"
}

# ============================================
# FlowLog (Rust) Setup
# ============================================

install_flowlog() {
    echo "[SETUP] Ensuring FlowLog is cloned under $HOME/FlowLog ..."
    local FLOWLOG_ROOT="$HOME/FlowLog"
    if [ ! -d "$FLOWLOG_ROOT" ]; then
        echo "[CLONE] Cloning FlowLog into $FLOWLOG_ROOT ..."
        git clone https://github.com/hdz284/FlowLog.git "$FLOWLOG_ROOT"
    else
        echo "[OK] FlowLog already present at $FLOWLOG_ROOT"
    fi

    echo "[SETUP] Installing Rust toolchain for FlowLog..."
    # Check if Rust is already installed
    if ! command -v rustc >/dev/null 2>&1; then
        echo "[INSTALL] Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        add_to_path "$CARGO_BIN_DIR"
    else
        echo "[OK] Rust is already installed"
    fi

    # Ensure Rust is available in current session
    export PATH="$CARGO_BIN_DIR:$PATH"

    echo "[UPDATE] Updating Rust to latest stable version..."
    rustup update && rustup default stable

    echo "[OK] FlowLog environment ready!"
}

# ============================================
# Souffle Setup
# ============================================

install_souffle() {
    echo "[SETUP] Installing Souffle..."
    
    # Add Souffle repository key
    sudo wget -q https://souffle-lang.github.io/ppa/souffle-key.public \
        -O /usr/share/keyrings/souffle-archive-keyring.gpg
    
    # Add Souffle repository to sources list
    echo "deb [signed-by=/usr/share/keyrings/souffle-archive-keyring.gpg] https://souffle-lang.github.io/ppa/ubuntu/ stable main" \
        | sudo tee /etc/apt/sources.list.d/souffle.list > /dev/null
    
    # Update package list and install Souffle
    sudo apt update -q
    sudo apt install -y souffle
    
    echo "[OK] Souffle environment ready!"
}

# ============================================
# Umbra Setup
# ============================================

install_umbra() {
    echo "[SETUP] Pulling Umbra Docker image..."
    sudo docker pull umbradb/umbra:latest
    echo "[OK] Umbra Docker image ready!"
}

# ============================================
# DDlog Setup
# ============================================

install_ddlog() {
    echo "[SETUP] Installing DDlog..."
    
    local ddlog_version="v1.2.3"
    local ddlog_tar="ddlog-v1.2.3-20211213235218-Linux.tar.gz"
    local ddlog_url="https://github.com/vmware-archive/differential-datalog/releases/download/${ddlog_version}/${ddlog_tar}"
    
    # Create installation directory
    mkdir -p "$DDLOG_DIR"
    
    # Download and extract DDlog
    curl -L "$ddlog_url" -o "$HOME/$ddlog_tar"
    tar -xzf "$HOME/$ddlog_tar" -C "$DDLOG_DIR" --strip-components=1
    rm "$HOME/$ddlog_tar"
    
    # Add DDlog to PATH and set DDLOG_HOME
    add_to_path "$DDLOG_DIR/bin"
    add_env_var "export DDLOG_HOME=\"$DDLOG_DIR\""
    
    # Export for current session
    export PATH="$DDLOG_DIR/bin:$PATH"
    export DDLOG_HOME="$DDLOG_DIR"

    echo "[SETUP] Installing Rust toolchain for ddlog..."
    # Check if Rust is already installed
    if ! command -v rustc >/dev/null 2>&1; then
        echo "[INSTALL] Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        add_to_path "$CARGO_BIN_DIR"
    else
        echo "[OK] Rust is already installed"
    fi

    # Ensure Rust is available in current session
    export PATH="$CARGO_BIN_DIR:$PATH"

    echo "[UPDATE] Updating Rust to latest stable version..."
    rustup update && rustup default stable
    
    echo "[OK] DDlog environment ready!"
}

# ============================================
# RecStep Setup
# ============================================

install_recstep() {
    echo "[SETUP] Installing RecStep..."
    
    # Create work directory
    mkdir -p "$WORK_DIR"
    
    # Install Quickstep binaries
    install_quickstep
    
    # Install Python dependencies
    install_python_deps
    
    # Install GRPC dependencies if needed
    install_grpc_deps
    
    # Clone and configure RecStep
    setup_recstep
    
    echo "[OK] RecStep environment ready!"
}

install_quickstep() {
    local qs_url="https://pages.cs.wisc.edu/~m0riarty/quickstep_build_binary.zip"
    local qs_build_dir="$WORK_DIR/build"
    
    if [[ ! -x "$qs_build_dir/quickstep_cli_shell" ]]; then
        echo "[SETUP] Installing Quickstep binaries to $qs_build_dir..."
        local tmp_dir=$(mktemp -d)
        
        curl -fsSL "$qs_url" -o "$tmp_dir/quickstep.zip"
        unzip -q "$tmp_dir/quickstep.zip" -d "$tmp_dir"
        
        local ext_dir=$(find "$tmp_dir" -mindepth 1 -maxdepth 1 -type d | head -n1)
        mkdir -p "$qs_build_dir"
        cp -a "$ext_dir"/. "$qs_build_dir"/
        
        # Create symlinks if binaries are in bin/ subdirectory
        if [[ -x "$qs_build_dir/bin/quickstep_cli_shell" ]]; then
            ln -sf "bin/quickstep_cli_shell" "$qs_build_dir/quickstep_cli_shell"
            ln -sf "bin/quickstep_client" "$qs_build_dir/quickstep_client" 2>/dev/null || true
        fi
        
        rm -rf "$tmp_dir"
        echo "[OK] Quickstep installed successfully"
    else
        echo "[OK] Quickstep already installed"
    fi
}

install_python_deps() {
    # Install pip if not available
    if ! command -v pip3 >/dev/null 2>&1; then
        echo "[SETUP] Installing pip3..."
        sudo apt -qq update
        sudo apt -qq install python3-pip -y
    fi
    
    # Install Python dependencies
    echo "[SETUP] Installing Python dependencies..."
    sudo apt -qq update
    sudo apt -qq install -y python3-dev build-essential libjpeg-dev zlib1g-dev
    
    pip3 install --upgrade pip
    pip3 install cython matplotlib psutil antlr4-python3-runtime==4.8 networkx
}

install_grpc_deps() {
    if [[ ! -d "$WORK_DIR/grpc" ]]; then
        echo "[SETUP] Installing GRPC dependencies..."
        sudo apt -qq update
        sudo apt -qq install -y clang cmake autotools-dev automake libtool
        
        export CC=/usr/bin/clang
        export CXX=/usr/bin/clang++
        
        git clone --depth=1 -b v1.28.1 https://github.com/grpc/grpc "$WORK_DIR/grpc"
        
        cd "$WORK_DIR/grpc"
        git submodule update --init
        
        local build_workers=${build_workers:-$(nproc)}
        sudo make --silent -j "$build_workers"
        sudo make --silent install
        
        cd third_party/protobuf
        sudo make --silent install
        
        cd "$WORK_DIR"
        echo "[OK] GRPC installed successfully"
    else
        echo "[OK] GRPC already installed"
    fi
}

setup_recstep() {
    if [[ ! -d "$WORK_DIR/RecStep" ]]; then
        echo "[SETUP] Cloning and configuring RecStep..."
        git clone --depth=1 https://github.com/Hacker0912/RecStep "$WORK_DIR/RecStep"
        
        cd "$WORK_DIR/RecStep"
        
        # Update config to point to local Quickstep installation
        sed -i "s|/fastdisk/quickstep-datalog/build|$WORK_DIR/build|" Config.json
        
        # Create RecStep CLI
        echo "#! $(which python3)" > recstep
        cat interpreter.py >> recstep
        chmod +x recstep
        
        # Create environment file
        cat > "$WORK_DIR/recstep_env" << EOF
export CONFIG_FILE_DIR=$WORK_DIR/RecStep
export PATH=\$PATH:$WORK_DIR/RecStep
EOF
        
        echo "[OK] RecStep configured successfully"
    else
        echo "[OK] RecStep already installed"
    fi
    
    # Source environment and test
    source "$WORK_DIR/recstep_env"
    export CONFIG_FILE_DIR="$WORK_DIR/RecStep"
    export PATH="$PATH:$WORK_DIR/RecStep"
    
    echo "[TEST] Testing RecStep installation..."
    "$WORK_DIR/RecStep/recstep" --help >/dev/null 2>&1 && echo "[OK] RecStep test passed" || echo "[WARN] RecStep test failed"
}

# ============================================
# Main Installation Logic
# ============================================

# Check if a system should be installed
should_install() {
    local system="$1"
    # If no systems specified and no --all flag, don't install any specific systems
    if [ ${#SELECTED_SYSTEMS[@]} -eq 0 ]; then
        return 1
    fi
    
    # Check if system is in selected list
    for selected in "${SELECTED_SYSTEMS[@]}"; do
        if [ "$selected" = "$system" ]; then
            return 0
        fi
    done
    return 1
}

# Main installation function
main() {
    echo ""
    echo "============================================"
    echo "Datalog DB Benchmark Environment Setup"
    echo "============================================"
    echo ""
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Always setup basic environment
    setup_basic_environment
    
    # Show what will be installed
    if [ ${#SELECTED_SYSTEMS[@]} -gt 0 ]; then
        echo ""
        echo "[INFO] Selected systems for installation: ${SELECTED_SYSTEMS[*]}"
        echo ""
    else
        echo ""
        echo "[INFO] Only basic environment will be installed"
        echo "[INFO] Use --help to see how to install specific systems"
        echo ""
    fi
    
    # Install selected systems
    should_install "duckdb" && install_duckdb
    should_install "flowlog" && install_flowlog
    should_install "souffle" && install_souffle
    should_install "umbra" && install_umbra
    should_install "ddlog" && install_ddlog
    should_install "recstep" && install_recstep
    
    # Show completion summary
    show_completion_summary
}

# Show installation summary
show_completion_summary() {
    echo ""
    echo "============================================"
    echo "Environment setup completed successfully!"
    echo "============================================"
    echo ""
    echo "Installed components:"
    echo "  ✓ Basic system dependencies"
    
    should_install "duckdb" && echo "  ✓ DuckDB CLI"
    should_install "flowlog" && echo "  ✓ Rust/Cargo (for FlowLog)"
    should_install "souffle" && echo "  ✓ Souffle"
    should_install "umbra" && echo "  ✓ Umbra (Docker)"
    should_install "ddlog" && echo "  ✓ DDlog"
    should_install "recstep" && echo "  ✓ RecStep (with Quickstep)"
    
    echo ""
    echo "To use the new environment:"
    echo "  1. Restart your terminal session, or"
    echo "  2. Run: source ~/.bashrc"
    echo ""
    echo "Additional notes:"
    echo "  - Docker group membership requires re-login to take effect"
    echo "  - All tools have been added to your PATH"
    if should_install "recstep"; then
        echo "  - RecStep environment can be activated with: source $WORK_DIR/recstep_env"
    fi
    echo ""
}

# Run main function with all arguments
main "$@"