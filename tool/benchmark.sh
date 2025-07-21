#!/bin/bash
set -e

CONFIG_FILE="./tool/config.txt"
TEMP_SQL="tmp_sql"
DATASET_DIR="./dataset"
declare -a RESULTS

mkdir -p "$DATASET_DIR"

# ------------------------------
# Run DuckDB: returns load_time exec_time
# ------------------------------
run_duckdb() {
    local base=$1
    local dataset=$2
    local load_tpl="program/duck/${base}_load.sql"
    local exec_tpl="program/duck/${base}_execute.sql"

    DUCKDB_DB="temp.duckdb"

    [[ ! -f "$load_tpl" || ! -f "$exec_tpl" ]] && { echo "-1 -1"; return; }

    sed "s|{{DATASET_PATH}}|dataset/${dataset}|g" "$load_tpl" > "${TEMP_SQL}_load.sql"
    cp "$exec_tpl" "${TEMP_SQL}_exec.sql"

    local fastest_load=""
    local fastest_exec=""
    
    for i in {1..3}; do
        local ltime=$(/usr/bin/time -f "%e" duckdb "$DUCKDB_DB" < "${TEMP_SQL}_load.sql" 2>&1 >/dev/null)
        if [[ -z "$fastest_load" || $(echo "$ltime < $fastest_load" | bc -l) -eq 1 ]]; then
            fastest_load="$ltime"
        fi
    done

    for i in {1..3}; do
        local etime=$(/usr/bin/time -f "%e" duckdb "$DUCKDB_DB" < "${TEMP_SQL}_exec.sql" 2>&1 >/dev/null)
        if [[ -z "$fastest_exec" || $(echo "$etime < $fastest_exec" | bc -l) -eq 1 ]]; then
            fastest_exec="$etime"
        fi
    done

    rm -f "$DUCKDB_DB"

    echo "$fastest_load $fastest_exec"
}

# ------------------------------
# Run Umbra: returns load_time exec_time
# ------------------------------
run_umbra() {
    local base=$1
    local dataset=$2
    local load_tpl="program/umbra/${base}_load.sql"
    local exec_tpl="program/umbra/${base}_execute.sql"

    [[ ! -f "$load_tpl" || ! -f "$exec_tpl" ]] && { echo "-1 -1"; return; }

    sed "s|{{DATASET_PATH}}|/hostdata/dataset/${dataset}|g" "$load_tpl" > "${TEMP_SQL}_load.sql"
    cp "$exec_tpl" "${TEMP_SQL}_exec.sql"

    local fastest_load=""
    local fastest_exec=""

    for i in {1..3}; do
        local ltime=$(/usr/bin/time -f "%e" \
            bash -c "sudo docker run --rm \
                -e UMBRA_THREADS=64 \
                -e UMBRA_MEMORY_LIMIT='250GB' \
                -v umbra-db:/var/db \
                -v \"$PWD\":/hostdata \
                umbradb/umbra:latest \
                bash -c 'umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_load.sql' \
                > /dev/null 2>&1" 2>&1)
        if [[ -z "$fastest_load" || $(echo "$ltime < $fastest_load" | bc -l) -eq 1 ]]; then
            fastest_load="$ltime"
        fi
    done

    for i in {1..3}; do
        local etime=$(/usr/bin/time -f "%e" \
            bash -c "sudo docker run --rm \
                -e UMBRA_THREADS=64 \
                -e UMBRA_MEMORY_LIMIT='250GB' \
                -v umbra-db:/var/db \
                -v \"$PWD\":/hostdata \
                umbradb/umbra:latest \
                bash -c 'umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_exec.sql' \
                > /dev/null 2>&1" 2>&1)
        if [[ -z "$fastest_exec" || $(echo "$etime < $fastest_exec" | bc -l) -eq 1 ]]; then
            fastest_exec="$etime"
        fi
    done

    echo "$fastest_load $fastest_exec"
}

# ------------------------------
# Main benchmark loop
# ------------------------------
while IFS='=' read -r program dataset; do
    [[ -z "$program" || "$program" =~ ^# ]] && continue

    DATASET_PATH="${DATASET_DIR}/${dataset}"
    ZIP_URL="https://pages.cs.wisc.edu/~m0riarty/dataset/${dataset}.zip"
    ZIP_PATH="${DATASET_PATH}.zip"

    if [[ -d "$DATASET_PATH" ]]; then
        echo "[SKIP] Dataset already exists: $DATASET_PATH"
    else
        echo "[PREP] Downloading and extracting dataset: $dataset"
        wget -q -O "$ZIP_PATH" "$ZIP_URL"
        unzip -q "$ZIP_PATH" -d "$DATASET_DIR"
    fi

    echo "[RUNNING] $program on $dataset"

    read duck_load duck_exec < <(run_duckdb "$program" "$dataset")
    read umbra_load umbra_exec < <(run_umbra "$program" "$dataset")

    RESULTS+=("$program $dataset $duck_load $duck_exec $umbra_load $umbra_exec")

    echo "[CLEANUP] Removing dataset: $dataset"
    rm -rf "$ZIP_PATH" "${DATASET_DIR:?}/${dataset}"
    echo ""
done < "$CONFIG_FILE"

rm -f "${TEMP_SQL}"_*.sql

# ------------------------------
# Final result table
# ------------------------------
printf "\n==============================\n"
printf "Timing Results Table (Best of 5 runs)\n"
printf "==============================\n\n"
printf "%-30s %-15s %-15s %-15s %-15s %-15s\n" \
    "Program" "Dataset" "Duck_Load(s)" "Duck_Exec(s)" "Umbra_Load(s)" "Umbra_Exec(s)"
printf "%-30s %-15s %-15s %-15s %-15s %-15s\n" \
    "------------------------------" "---------------" "---------------" "---------------" "---------------" "---------------"

for result in "${RESULTS[@]}"; do
    read -r prog data dl de ul ue <<< "$result"
    printf "%-30s %-15s %-15s %-15s %-15s %-15s\n" "$prog" "$data" "$dl" "$de" "$ul" "$ue"
done
