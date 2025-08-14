#!/bin/bash
set -e



# ============================================
# RECSTEP SETUP
# ============================================

WORK_DIR=${WORK_DIR:-$HOME}
mkdir -p "$WORK_DIR"

# Minimal Quickstep install: download, unzip, move under WORK_DIR/build
QS_URL="https://pages.cs.wisc.edu/~m0riarty/quickstep_build_binary.zip"
QS_BUILD_DIR="$WORK_DIR/build"
if [[ ! -x "$QS_BUILD_DIR/quickstep_cli_shell" ]]; then
	echo "[SETUP] Installing Quickstep binaries to $QS_BUILD_DIR..."
	TMP_DIR=$(mktemp -d)
	curl -fsSL "$QS_URL" -o "$TMP_DIR/quickstep.zip"
	unzip -q "$TMP_DIR/quickstep.zip" -d "$TMP_DIR"
	EXTDIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n1)
	mkdir -p "$QS_BUILD_DIR"
	cp -a "$EXTDIR"/. "$QS_BUILD_DIR"/
	# If binaries live under bin/, expose them at build/ to match expected layout
	if [[ -x "$QS_BUILD_DIR/bin/quickstep_cli_shell" ]]; then
		ln -sf "bin/quickstep_cli_shell" "$QS_BUILD_DIR/quickstep_cli_shell"
		ln -sf "bin/quickstep_client" "$QS_BUILD_DIR/quickstep_client" 2>/dev/null || true
	fi
	rm -rf "$TMP_DIR"
fi

if command -v pip3 >/dev/null 2>&1; then
	echo "[img-setup] pip exists, skipping install."
else
	sudo apt -qq update
	sudo apt -qq install python3-pip -y
fi

if [[ ! -d $WORK_DIR/RecStep ]]; then

	# Skipping GRPC C++ from-source build; using Quickstep prebuilt binaries instead.

	sudo apt -qq update -y
	sudo apt -qq install -y python3-pip python3-dev build-essential libjpeg-dev zlib1g-dev
	pip3 install --upgrade pip
	pip3 install cython
	pip3 install matplotlib
	pip3 install psutil
	pip3 install antlr4-python3-runtime==4.8
	pip3 install networkx

	git clone --depth=1 https://github.com/Hacker0912/RecStep $WORK_DIR/RecStep

	pushd $WORK_DIR/RecStep

	# Point config to Quickstep under WORK_DIR/build
	sed -i "s|/fastdisk/quickstep-datalog/build|$WORK_DIR/build|" "$WORK_DIR/RecStep/Config.json"

	# Install CLI and env
	echo "#! $(which python3)" > recstep
	cat interpreter.py >> recstep
	chmod +x recstep
	{
	  echo "export CONFIG_FILE_DIR=$WORK_DIR/RecStep"
	  echo "export PATH=$PATH:$WORK_DIR/RecStep"
	} >> "$WORK_DIR/recstep_env"
	source "$WORK_DIR/recstep_env"

	popd
fi

source "$WORK_DIR/recstep_env"
recstep --help
