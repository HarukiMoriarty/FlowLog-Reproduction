#!/bin/bash
set -e

CONFIG_FILE="./tool/config/benchmark.txt"
TEMP_SQL="tmp_sql"
DATASET_DIR="./dataset"
RESULT_FILE="benchmark.txt"

mkdir -p "$DATASET_DIR"
rm -rf "$RESULT_FILE"
mkdir -p "./log/benchmark"

cd FlowLog
git checkout nemo_aggregation_new
cargo build --release
cd ..

# Write header if result file does not exist
if [[ ! -f "$RESULT_FILE" ]]; then
    printf "%-30s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" \
        "Program" "Dataset" "Duck_Load(s)" "Duck_Exec(s)" "Umbra_Load(s)" "Umbra_Exec(s)" "FlowLog_Load(s)" "FlowLog_Exec(s)" \
        > "$RESULT_FILE"
    printf "%-30s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" \
        "------------------------------" "---------------" "---------------" "---------------" "---------------" "---------------" "---------------" "---------------" \
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

    # Load database
    load_time=$(/usr/bin/time -f "%e" duckdb "$DUCKDB_DB" < "${TEMP_SQL}_load.sql" 2>&1 >/dev/null)

    # Execute query once for logging (to verify correctness)
    echo "=== DuckDB Execute Log for $base on $dataset ===" > "./log/benchmark/duckdb_${base}_${dataset}.log"
    duckdb "$DUCKDB_DB" < "${TEMP_SQL}_exec.sql" >> "./log/benchmark/duckdb_${base}_${dataset}.log" 2>&1

    # Execute query for timing (find fastest)
    for i in {1..3}; do
        # Run with 15-minute timeout
        local etime=""
        if timeout 900 /usr/bin/time -f "%e" duckdb "$DUCKDB_DB" < "${TEMP_SQL}_exec.sql" 2>/tmp/duckdb_time.tmp >/dev/null; then
            etime=$(cat /tmp/duckdb_time.tmp)
            rm -f /tmp/duckdb_time.tmp
        else
            etime="900"  # Set to 15 minutes if timeout
        fi
        
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
    local log_file="./log/benchmark/flowlog_${base}_${dataset}.log"
    echo "=== FlowLog Execute Log for $base on $dataset ===" > "$log_file"
    "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$workers" \
        >> "$log_file" 2>&1
    
    # Run FlowLog multiple times to find fastest execution time
    local fastest_load=""
    local fastest_exec=""
    
    for i in {1..3}; do
        # Create temporary log file for this timing run
        local temp_log="./log/benchmark/flowlog_${base}_${dataset}_${i}.log"
        
        # Run FlowLog with 15-minute timeout and capture output for timing analysis
        if timeout 900 "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$workers" \
            > "$temp_log" 2>&1; then
            # FlowLog completed successfully, proceed with timing extraction
            :
        else
            # Create a dummy log indicating timeout
            # Set default timeout values and skip timing extraction
            load_time="900"
            exec_time="900"
            
            # Track fastest times even for timeout
            if [[ -z "$fastest_load" || $(echo "$load_time < $fastest_load" | bc -l) -eq 1 ]]; then
                fastest_load="$load_time"
            fi
            if [[ -z "$fastest_exec" || $(echo "$exec_time < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$exec_time"
            fi
            
            rm -f "$temp_log"
            continue
        fi
        
        # Extract load time (latest "Data loaded for" line) - handle both ms and s
        local load_line=$(grep "Data loaded for" "$temp_log" | tail -1)
        local load_time="-1"
        if [[ -n "$load_line" ]]; then
            if [[ "$load_line" =~ ([0-9]+\.?[0-9]*)ms ]]; then
                # Convert milliseconds to seconds
                load_time=$(echo "${BASH_REMATCH[1]} / 1000" | bc -l)
            elif [[ "$load_line" =~ ([0-9]+\.?[0-9]*)s ]]; then
                # Already in seconds
                load_time="${BASH_REMATCH[1]}"
            fi
        fi
        
        # Extract total execution time ("Dataflow executed" or "Fixpoint reached" line) - handle both ms and s
        local exec_line=$(grep -E "(Dataflow executed|Fixpoint reached)" "$temp_log")
        local total_time="-1"
        if [[ -n "$exec_line" ]]; then
            if [[ "$exec_line" =~ ([0-9]+\.?[0-9]*)ms ]]; then
                # Convert milliseconds to seconds
                total_time=$(echo "${BASH_REMATCH[1]} / 1000" | bc -l)
            elif [[ "$exec_line" =~ ([0-9]+\.?[0-9]*)s ]]; then
                # Already in seconds
                total_time="${BASH_REMATCH[1]}"
            fi
        fi
        
        # Calculate pure execution time (total - load)
        local exec_time="-1"
        if [[ "$load_time" != "-1" && "$total_time" != "-1" ]]; then
            exec_time=$(echo "$total_time - $load_time" | bc -l)
        fi
        
        # Track fastest load time
        if [[ "$load_time" != "-1" ]]; then
            if [[ -z "$fastest_load" || $(echo "$load_time < $fastest_load" | bc -l) -eq 1 ]]; then
                fastest_load="$load_time"
            fi
        fi
        
        # Track fastest execution time
        if [[ "$exec_time" != "-1" ]]; then
            if [[ -z "$fastest_exec" || $(echo "$exec_time < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$exec_time"
            fi
        fi
        
        # Clean up temporary log
        rm -f "$temp_log"
    done
    
    # Return the fastest times, or -1 if no valid timing found
    # Format to 4 decimal places for better readability
    local formatted_load="${fastest_load:-"-1"}"
    local formatted_exec="${fastest_exec:-"-1"}"
    
    if [[ "$formatted_load" != "-1" ]]; then
        formatted_load=$(printf "%.4f" "$formatted_load")
    fi
    
    if [[ "$formatted_exec" != "-1" ]]; then
        formatted_exec=$(printf "%.4f" "$formatted_exec")
    fi
    
    echo "$formatted_load $formatted_exec"
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
    echo "=== Umbra Execute Log for $base on $dataset ===" > "./log/benchmark/umbra_${base}_${dataset}.log"
    sudo docker run --rm \
        --cpuset-cpus='0-63' \
        --memory='250g' \
        -v umbra-db:/var/db \
        -v "$PWD":/hostdata \
        --user root \
        umbradb/umbra:latest \
        bash -c "umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_exec.sql" \
        >> "./log/benchmark/umbra_${base}_${dataset}.log" 2>&1

    # Execute query for timing (find fastest)
    for i in {1..3}; do
        # Run with 15-minute timeout
        local etime=""
        if timeout 900 /usr/bin/time -f "%e" \
            bash -c "sudo docker run --rm \
                --cpuset-cpus='0-63' \
                --memory='250g' \
                -v umbra-db:/var/db \
                -v \"$PWD\":/hostdata \
                --user root \
                umbradb/umbra:latest \
                bash -c 'umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_exec.sql' \
                > /dev/null 2>&1" 2>/tmp/umbra_time.tmp; then
            etime=$(cat /tmp/umbra_time.tmp)
            rm -f /tmp/umbra_time.tmp
        else
            etime="900"  # Set to 15 minutes if timeout
        fi
        
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
        wget -O "$ZIP_PATH" "$ZIP_URL"
        unzip "$ZIP_PATH" -d "$DATASET_DIR"
    fi

    echo "[RUNNING] $program on $dataset"

    echo "[DUCKDB] Running DuckDB benchmark for $program on $dataset..."
    read duck_load duck_exec < <(run_duckdb "$program" "$dataset")
    
    echo "[UMBRA] Running Umbra benchmark for $program on $dataset..."
    read umbra_load umbra_exec < <(run_umbra "$program" "$dataset")
    
    echo "[FLOWLOG] Running FlowLog benchmark for $program on $dataset..."
    read flowlog_load flowlog_exec < <(run_flowlog "$program" "$dataset")

    printf "%-30s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n" \
        "$program" "$dataset" "$duck_load" "$duck_exec" "$umbra_load" "$umbra_exec" "$flowlog_load" "$flowlog_exec" \
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