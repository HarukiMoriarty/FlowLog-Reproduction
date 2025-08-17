#!/bin/bash
# monitor.sh: Monitor CPU/memory usage for all engines using dlbench, like benchmark.sh
# Usage: ./monitor.sh [THREAD_COUNT]

set -e

THREAD_COUNT=${1:-64}

CONFIG_FILE="./tool/config/monitor.txt"
TEMP_SQL="tmp_sql"
DATASET_DIR="./dataset"
RESULT_FILE="monitor.txt"
TEMP_RESULT_FILE="/tmp/monitor_result.tmp"

mkdir -p "$DATASET_DIR"
rm -rf "$RESULT_FILE"
mkdir -p "./log/monitor/${THREAD_COUNT}"

echo "=== Monitor Benchmark Configuration ==="
echo "Thread count: ${THREAD_COUNT}"

if [[ $THREAD_COUNT -eq 1 ]]; then
    CPUSET="0"
else
    CPUSET="0-$((THREAD_COUNT-1))"
fi

echo "CPU set: ${CPUSET}"
echo ""

# Check and install dlbench if not present
if ! command -v dlbench >/dev/null 2>&1; then
    echo "dlbench not found, installing..."
    if ! command -v pip >/dev/null 2>&1; then
        echo "ERROR: pip not found. Please install python3-pip (e.g., sudo apt-get install python3-pip) and rerun this script."
        exit 1
    fi
    if [[ ! -d "./dlbench" ]]; then
        git clone https://github.com/srinskit/dlbench.git ./dlbench
    fi
    pip install --user ./dlbench
    # Add user base binary path to PATH for this shell session
    export PATH="$PATH:$(python3 -m site --user-base)/bin"
    hash -r
fi

# echo "=== Building FlowLog ==="
# cd FlowLog
# git checkout nemo_aggregation
# git pull
# cargo build --release
# cd ..
# echo "FlowLog build completed"
# echo ""

while IFS='=' read -r program dataset; do
    [[ -z "$program" || "$program" =~ ^# ]] && continue

    # DATASET_PATH="${DATASET_DIR}/${dataset}"
    # ZIP_URL="https://pages.cs.wisc.edu/~m0riarty/dataset/${dataset}.zip"
    # ZIP_PATH="/dev/shm/${dataset}.zip"

    # if [[ -d "$DATASET_PATH" ]]; then
    #     echo "SKIP: Dataset already exists: $DATASET_PATH"
    # else
    #     echo "PREP: Downloading and extracting dataset: $dataset"
    #     wget -O "$ZIP_PATH" "$ZIP_URL"
    #     unzip "$ZIP_PATH" -d "$DATASET_DIR"
    # fi

    # echo ""
    # echo "=== MONITORING: $program on $dataset ==="

    # # DuckDB
    # echo "--- DuckDB ---"
    # sed "s|{{DATASET_PATH}}|dataset/${dataset}|g" "program/duck/${program}.sql" > "tmp.sql"
    # sed -i "1i PRAGMA threads=$THREAD_COUNT;" "tmp.sql"
    # dlbench run --suffix-time "duckdb temp.duckdb < tmp.sql" "duckdb_${program}_${dataset}_${THREAD_COUNT}t"
    # rm -rf temp.duckdb
    # rm -rf tmp.sql

    # # FlowLog
    # echo "--- FlowLog ---"
    # dlbench run --suffix-time "./FlowLog/target/release/executing --program program/flowlog/${program}.dl --facts dataset/${dataset} --workers ${THREAD_COUNT}" "flowlog_${program}_${dataset}_${THREAD_COUNT}t"

    # DDlog
    echo "--- DDlog ---"
    DDLOG_PROG="program/ddlog/${program}.dl"
    DDLOG_BUILD_DIR="${program}_ddlog"
    DDLOG_EXE="${DDLOG_BUILD_DIR}/target/release/${program}_cli"
    if [[ ! -x "$DDLOG_EXE" ]]; then
        echo "Compiling DDlog program for $program ..."
        rm -rf "$DDLOG_BUILD_DIR" || true
        ddlog -i $DDLOG_PROG -o ./
        pushd "$DDLOG_BUILD_DIR" >/dev/null
        RUSTFLAGS=-Awarnings cargo +1.76 build --release --quiet
        popd >/dev/null
    fi
    dlbench run --suffix-time "$DDLOG_EXE -w ${THREAD_COUNT} < dataset/${dataset}/data.ddin" "ddlog_${program}_${dataset}_${THREAD_COUNT}t"

    # # RecStep
    # echo "--- RecStep ---"
    # source "$HOME/recstep_env"
    # dlbench run --suffix-time "recstep --program program/recstep/${program}.dl --input dataset/${dataset} --jobs ${THREAD_COUNT}" "recstep_${program}_${dataset}_${THREAD_COUNT}t" --monitor quickstep_cli_shell

    # # Souffle (compile then run)
    # echo "--- Souffle ---"
    # SOUFFLE_SRC="program/souffle/${program}.dl"
    # SOUFFLE_BIN="program/souffle/${program}_souffle"
    # if [[ -f "$SOUFFLE_SRC" ]]; then
    #     souffle -o "$SOUFFLE_BIN" "$SOUFFLE_SRC" -j "$THREAD_COUNT"
    # else
    #     echo "Souffle program not found: $SOUFFLE_SRC"
    # fi

    # dlbench run --suffix-time "$SOUFFLE_BIN -F dataset/${dataset} -j ${THREAD_COUNT}" "souffle_${program}_${dataset}_${THREAD_COUNT}t"

    # Cleanup
    echo "CLEANUP: Removing dataset: $dataset"
    rm -rf "$ZIP_PATH" "${DATASET_DIR:?}/${dataset}"
    echo ""
done < "$CONFIG_FILE"

echo "=============================================="
echo "           MONITORING COMPLETE"
echo "=============================================="
