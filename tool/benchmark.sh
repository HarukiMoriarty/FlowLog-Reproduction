#!/bin/bash
set -e

CONFIG_FILE="./tool/config.txt"
TEMP_SQL="tmp_sql"
DATASET_DIR="./dataset"
declare -a RESULTS

# ------------------------------
# Ensure dataset dir exists
# ------------------------------
mkdir -p "$DATASET_DIR"

# ------------------------------
# Run DuckDB with timing
# ------------------------------
run_duckdb() {
    local program=$1
    local dataset=$2
    local template="program/duck/${program}"

    if [[ ! -f "$template" ]]; then
        echo "-1"
        return
    fi

    sed "s|{{DATASET_PATH}}|dataset/${dataset}|g" "$template" > "$TEMP_SQL"

    /usr/bin/time -f "%e" duckdb :memory: < "$TEMP_SQL" 2>&1 >/dev/null
}

# ------------------------------
# Run Umbra with timing
# ------------------------------
run_umbra() {
    local program=$1
    local dataset=$2
    local template="program/umbra/${program}"

    if [[ ! -f "$template" ]]; then
        echo "-1"
        return
    fi

    sed "s|{{DATASET_PATH}}|/hostdata/dataset/${dataset}|g" "$template" > "$TEMP_SQL"

    /usr/bin/time -f "%e" \
        bash -c "sudo docker run --rm \
            -e UMBRA_THREADS=64 \
            -e UMBRA_MEMORY_LIMIT='250GB' \
            -v umbra-db:/var/db \
            -v \"$PWD\":/hostdata \
            umbradb/umbra:latest \
            bash -c 'umbra-sql /var/db/umbra.db < /hostdata/$TEMP_SQL' \
            > /dev/null 2>&1" 2>&1
}

# ------------------------------
# Main benchmark loop
# ------------------------------
while IFS='=' read -r program dataset; do
    [[ -z "$program" || "$program" =~ ^# ]] && continue

    DATASET_PATH="${DATASET_DIR}/${dataset}"

    if [[ -d "$DATASET_PATH" ]]; then
        echo "[SKIP] Dataset already exists: $DATASET_PATH"
    else
        echo "[PREP] Downloading and extracting dataset: $dataset"
        ZIP_URL="https://pages.cs.wisc.edu/~m0riarty/dataset/${dataset}.zip"
        ZIP_PATH="${DATASET_PATH}.zip"

        wget -q -O "$ZIP_PATH" "$ZIP_URL"
        unzip -q "$ZIP_PATH" -d "$DATASET_DIR"
    fi

    echo "[RUNNING] $program on $dataset"
    duck_time=$(run_duckdb "$program" "$dataset")
    umbra_time=$(run_umbra "$program" "$dataset")
    RESULTS+=("$program $dataset $duck_time $umbra_time")

    echo "[CLEANUP] Removing dataset: $dataset"
    rm -rf "$ZIP_PATH" "${DATASET_DIR:?}/${dataset}"

    echo ""
done < "$CONFIG_FILE"

rm -f "$TEMP_SQL"

# ------------------------------
# Final result table
# ------------------------------
printf "\n==============================\n"
printf "Timing Results Table\n"
printf "==============================\n\n"
printf "%-30s %-15s %-18s %-18s\n" "Program" "Dataset" "DuckDB_Time(s)" "Umbra_Time(s)"
printf "%-30s %-15s %-18s %-18s\n" "------------------------------" "---------------" "------------------" "------------------"

for result in "${RESULTS[@]}"; do
    read -r prog data duck umbra <<< "$result"
    printf "%-30s %-15s %-18s %-18s\n" "$prog" "$data" "$duck" "$umbra"
done
