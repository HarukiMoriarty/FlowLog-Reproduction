#!/bin/bash
set -e

CONFIG_FILE="./tool/config.txt"
TEMP_SQL="tmp_sql"
DATASET_DIR="./dataset"
RESULT_FILE="result.txt"

mkdir -p "$DATASET_DIR"
rm -rf "$RESULT_FILE"

cd FlowLog
cargo build --release
cd ..

# Write header if result file does not exist
if [[ ! -f "$RESULT_FILE" ]]; then
    printf "%-30s %-15s %-15s %-15s %-15s %-15s %-15s\n" \
        "Program" "Dataset" "Duck_Load(s)" "Duck_Exec(s)" "Umbra_Load(s)" "Umbra_Exec(s)" "FlowLog_Exec(s)" \
        > "$RESULT_FILE"
    printf "%-30s %-15s %-15s %-15s %-15s %-15s %-15s\n" \
        "------------------------------" "---------------" "---------------" "---------------" "---------------" "---------------" "---------------" \
        >> "$RESULT_FILE"
fi

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

    local fastest_exec=""
    
    # redirect log output 
    # duckdb "$DUCKDB_DB" < "${TEMP_SQL}_load.sql" > ./log

    # Load database
    load_time=$(/usr/bin/time -f "%e" duckdb "$DUCKDB_DB" < "${TEMP_SQL}_load.sql" 2>&1 >/dev/null)

    # Execute query once for logging (to verify correctness)
    echo "=== DuckDB Execute Log for $base on $dataset ===" > "./log/duckdb_${base}_${dataset}.log"
    duckdb "$DUCKDB_DB" < "${TEMP_SQL}_exec.sql" >> "./log/duckdb_${base}_${dataset}.log" 2>&1

    # Execute query for timing (find fastest)
    for i in {1..3}; do
        local etime=$(/usr/bin/time -f "%e" duckdb "$DUCKDB_DB" < "${TEMP_SQL}_exec.sql" 2>&1 >/dev/null)
        if [[ -z "$fastest_exec" || $(echo "$etime < $fastest_exec" | bc -l) -eq 1 ]]; then
            fastest_exec="$etime"
        fi
    done

    rm -f "$DUCKDB_DB"

    echo "$load_time $fastest_exec"
}

# ------------------------------
# Run FlowLog: returns load_time exec_time
# ------------------------------
run_flowlog() {
    local base=$1
    local dataset=$2
    local prog_file="program/flowlog/${base}.dl"
    local fact_path="dataset/${dataset}"
    local flowlog_binary="./FlowLog/target/release/executing"
    local workers=64
    
    # Check if program file exists
    [[ ! -f "$prog_file" ]] && { echo "-1 -1"; return; }
    
    # Check if dataset exists
    [[ ! -d "$fact_path" ]] && { echo "-1 -1"; return; }
    
    # Create log file for FlowLog output (run once for logging)
    echo "=== FlowLog Execute Log for $base on $dataset ===" > "./log/flowlog_${base}_${dataset}.log"
    "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$workers" \
        >> "./log/flowlog_${base}_${dataset}.log" 2>&1
    
    # Run FlowLog multiple times to find fastest execution time
    local fastest_exec=""
    local time_file="./result/time/${base}_${dataset}_none.txt"
    
    for i in {1..3}; do
        # Run FlowLog silently for timing
        "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$workers" \
            > /dev/null 2>&1
        
        # Read timing from result file
        if [[ -f "$time_file" ]]; then
            local exec_time=$(head -1 "$time_file" | grep -oP '^[0-9]+\.[0-9]+' || echo "-1")
            
            if [[ "$exec_time" != "-1" ]]; then
                if [[ -z "$fastest_exec" || $(echo "$exec_time < $fastest_exec" | bc -l) -eq 1 ]]; then
                    fastest_exec="$exec_time"
                fi
            fi
        fi
    done
    
    # Return the fastest execution time, or -1 if no valid timing found
    echo "${fastest_exec:-"-1"}"
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

    sudo docker run --rm -v umbra-db:/var/db umbradb/umbra:latest umbra-sql -createdb /var/db/umbra.db > /dev/null

    sed "s|{{DATASET_PATH}}|/hostdata/dataset/${dataset}|g" "$load_tpl" > "${TEMP_SQL}_load.sql"
    cp "$exec_tpl" "${TEMP_SQL}_exec.sql"

    local fastest_exec=""

    # Load database
    load_time=$(/usr/bin/time -f "%e" \
        bash -c "sudo docker run --rm \
            --cpuset-cpus='0-63' \
            --memory='250g' \
            -v umbra-db:/var/db \
            -v \"$PWD\":/hostdata \
            --user root \
            umbradb/umbra:latest \
            bash -c 'umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_load.sql' \
            > /dev/null 2>&1" 2>&1)

    # Execute query once for logging (to verify correctness)
    echo "=== Umbra Execute Log for $base on $dataset ===" > "./log/umbra_${base}_${dataset}.log"
    sudo docker run --rm \
        --cpuset-cpus='0-63' \
        --memory='250g' \
        -v umbra-db:/var/db \
        -v "$PWD":/hostdata \
        --user root \
        umbradb/umbra:latest \
        bash -c "umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_exec.sql" \
        >> "./log/umbra_${base}_${dataset}.log" 2>&1

    # Execute query for timing (find fastest)
    for i in {1..3}; do
        local etime=$(/usr/bin/time -f "%e" \
            bash -c "sudo docker run --rm \
                --cpuset-cpus='0-63' \
                --memory='250g' \
                -v umbra-db:/var/db \
                -v \"$PWD\":/hostdata \
                --user root \
                umbradb/umbra:latest \
                bash -c 'umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_exec.sql' \
                > /dev/null 2>&1" 2>&1)
        if [[ -z "$fastest_exec" || $(echo "$etime < $fastest_exec" | bc -l) -eq 1 ]]; then
            fastest_exec="$etime"
        fi
    done

    sudo docker volume rm umbra-db > /dev/null 2>&1

    echo "$load_time $fastest_exec"
}

# ------------------------------
# Main benchmark loop
# ------------------------------
while IFS='=' read -r program dataset; do
    [[ -z "$program" || "$program" =~ ^# ]] && continue

    DATASET_PATH="${DATASET_DIR}/${dataset}"
    ZIP_URL="https://pages.cs.wisc.edu/~m0riarty/dataset/${dataset}.zip"
    ZIP_PATH="/dev/shm/${dataset}.zip"

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
    flowlog_exec=$(run_flowlog "$program" "$dataset")

    printf "%-30s %-15s %-15s %-15s %-15s %-15s %-15s\n" \
        "$program" "$dataset" "$duck_load" "$duck_exec" "$umbra_load" "$umbra_exec" "$flowlog_exec" \
        >> "$RESULT_FILE"

    echo "[CLEANUP] Removing dataset: $dataset"
    rm -rf "$ZIP_PATH" "${DATASET_DIR:?}/${dataset}"
    echo ""

    echo "[RESULTS SO FAR]"
    cat "$RESULT_FILE"
    echo ""
done < "$CONFIG_FILE"

rm -f "${TEMP_SQL}"_*.sql

# ------------------------------
# Final display of all results
# ------------------------------
echo ""
echo "=============================="
echo "Final Timing Results Table"
echo "=============================="
cat "$RESULT_FILE"