#!/bin/bash
set -e

# =============================================================================
# Database Scalability Testing Script
# =============================================================================
# Tests DuckDB, Umbra, and FlowLog databases across different thread counts

# Thread counts to test
THREAD_COUNTS=(1 2 4 8 16 32 64)

# Display usage if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0"
    echo ""
    echo "Run database scalability tests across multiple thread counts."
    echo ""
    echo "Thread counts tested: ${THREAD_COUNTS[*]}"
    echo ""
    echo "Note: No timeout is used - all queries run to completion."
    exit 0
fi

# =============================================================================
# Configuration and Setup
# =============================================================================

CONFIG_FILE="./tool/config/scalability.txt"
TEMP_SQL="tmp_sql"
DATASET_DIR="./dataset"
RESULT_FILE="scalability.txt"
TEMP_RESULT_FILE="/tmp/scalability_result.tmp"

# Initialize directories and files
mkdir -p "$DATASET_DIR"
rm -rf "$RESULT_FILE"
mkdir -p "./log/scalability"

echo "=== Database Scalability Testing Configuration ==="
echo "Thread counts: ${THREAD_COUNTS[*]}"
echo "No timeout - all queries run to completion"
echo ""

# echo "=== Building FlowLog ==="
# cd FlowLog
# git checkout nemo_arithmetic
# cargo build --release
# cd ..
# echo "FlowLog build completed"
# echo ""

# Initialize result file with headers
if [[ ! -f "$RESULT_FILE" ]]; then
    printf "%-20s %-20s %-8s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s\n" \
        "Program" "Dataset" "Threads" "Duck_Load(s)" "Duck_Exec(s)" \
        "Umbra_Load(s)" "Umbra_Exec(s)" "FlowLog_Load(s)" "FlowLog_Exec(s)" \
        "DDlog_Load(s)" "DDlog_Exec(s)" \
    printf "%-20s %-20s %-8s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s\n" \
        "--------------------" "--------------------" "--------" "--------------------" "--------------------" \
        "--------------------" "--------------------" "--------------------" "--------------------" \
        "--------------------" "--------------------" \
        >> "$RESULT_FILE"
fi

# =============================================================================
# Database Scalability Test Functions
# =============================================================================
# -----------------------------------------------------------------------------
# DuckDB Scalability Test Function
# -----------------------------------------------------------------------------
run_duckdb_scalability() {
    local base=$1
    local dataset=$2
    local thread_count=$3
    local load_tpl="program/duck/${base}_load.sql"
    local exec_tpl="program/duck/${base}_execute.sql"
    local duckdb_db="temp_${thread_count}.duckdb"

    echo "  Starting DuckDB test: $base on $dataset (${thread_count} threads)"

    # Check if template files exist
    [[ ! -f "$load_tpl" || ! -f "$exec_tpl" ]] && { 
        echo "  ERROR: Template files not found"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        return 
    }

    # Prepare SQL files
    sed "s|{{DATASET_PATH}}|dataset/${dataset}|g" "$load_tpl" > "${TEMP_SQL}_${thread_count}_load.sql"
    cp "$exec_tpl" "${TEMP_SQL}_${thread_count}_exec.sql"

    # Add thread count pragma to DuckDB execution SQL
    echo "  Setting thread count: $thread_count"
    sed -i "1i PRAGMA threads=$thread_count;" "${TEMP_SQL}_${thread_count}_load.sql"
    sed -i "1i PRAGMA threads=$thread_count;" "${TEMP_SQL}_${thread_count}_exec.sql"

    local fastest_exec=""

    # Load database
    echo "  Loading database..."
    load_time=$(/usr/bin/time -f "%e" duckdb "$duckdb_db" < "${TEMP_SQL}_${thread_count}_load.sql" 2>&1 >/dev/null)
    echo "  Database loaded in $load_time seconds"

    # Run logging execution
    echo "  Running logging execution..."
    echo "=== DuckDB Scalability Log for $base on $dataset (${thread_count} threads) ===" > "./log/scalability/duckdb_${base}_${dataset}_${thread_count}t.log"
    duckdb "$duckdb_db" < "${TEMP_SQL}_${thread_count}_exec.sql" \
        >> "./log/scalability/duckdb_${base}_${dataset}_${thread_count}t.log" 2>&1 || \
        echo "  WARNING: Logging execution failed"

    # Run timing executions
    echo "  Running timing executions..."
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local etime=""
        
        if /usr/bin/time -f "%e" -o /tmp/duckdb_time_${thread_count}.tmp \
                duckdb "$duckdb_db" < "${TEMP_SQL}_${thread_count}_exec.sql" > /dev/null 2>&1; then
            if [[ -f /tmp/duckdb_time_${thread_count}.tmp ]]; then
                etime=$(cat /tmp/duckdb_time_${thread_count}.tmp)
                rm -f /tmp/duckdb_time_${thread_count}.tmp
                # Validate that etime is a valid number
                if [[ "$etime" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                    echo "      Completed in $etime seconds"
                else
                    echo "      Invalid time value, skipping"
                    continue
                fi
            else
                echo "      No time file found, skipping"
                continue
            fi
        else
            rm -f /tmp/duckdb_time_${thread_count}.tmp
            echo "      Execution failed, skipping"
            continue
        fi
        
        # Track fastest execution time
        if [[ -n "$etime" ]]; then
            if [[ -z "$fastest_exec" || $(echo "$etime < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$etime"
            fi
        fi
    done

    # Set fallback if no valid execution time was recorded
    if [[ -z "$fastest_exec" ]]; then
        fastest_exec="-1"
    fi

    echo "  Fastest execution time: $fastest_exec seconds"

    # Cleanup
    rm -f "$duckdb_db"
    rm -f "${TEMP_SQL}_${thread_count}_load.sql" "${TEMP_SQL}_${thread_count}_exec.sql"

    # Write results to temp file
    {
        echo "$load_time"
        echo "$fastest_exec"
    } > "$TEMP_RESULT_FILE"
    echo "  Results: load=$load_time exec=$fastest_exec"
}

# -----------------------------------------------------------------------------
# FlowLog Scalability Test Function
# -----------------------------------------------------------------------------
run_flowlog_scalability() {
    local base=$1
    local dataset=$2
    local thread_count=$3
    local prog_file="program/flowlog/${base}.dl"
    local fact_path="dataset/${dataset}"
    local flowlog_binary="./FlowLog/target/release/executing"
    
    echo "  Starting FlowLog test: $base on $dataset (${thread_count} workers)"
    
    # Check if required files exist
    [[ ! -f "$prog_file" ]] && { 
        echo "  ERROR: Program file not found: $prog_file"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        return
    }
    
    [[ ! -d "$fact_path" ]] && { 
        echo "  ERROR: Dataset path not found: $fact_path"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        return
    }
    
    # Run logging execution
    echo "  Running logging execution..."
    local log_file="./log/scalability/flowlog_${base}_${dataset}_${thread_count}t.log"
    echo "=== FlowLog Scalability Log for $base on $dataset (${thread_count} workers) ===" > "$log_file"
    "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$thread_count" \
        >> "$log_file" 2>&1 || echo "  WARNING: Logging execution failed"
    
    # Run timing executions
    echo "  Running timing executions..."
    local fastest_load=""
    local fastest_exec=""
    
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local temp_log="./log/scalability/flowlog_${base}_${dataset}_${thread_count}t_${i}.log"
        
        # Run FlowLog and capture output
        if "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$thread_count" \
            > "$temp_log" 2>&1; then
            echo "      Completed successfully"
        else
            echo "      Execution failed, skipping"
            rm -f "$temp_log"
            continue
        fi
        
        # Extract timing information
        local load_line=$(grep "Data loaded for" "$temp_log" | tail -1)
        local load_time="-1"
        if [[ -n "$load_line" ]]; then
            if [[ "$load_line" =~ ([0-9]+\.?[0-9]*)ms ]]; then
                load_time=$(echo "${BASH_REMATCH[1]} / 1000" | bc -l)
            elif [[ "$load_line" =~ ([0-9]+\.?[0-9]*)s ]]; then
                load_time="${BASH_REMATCH[1]}"
            fi
        fi
        
        local exec_line=$(grep -E "(Dataflow executed|Fixpoint reached)" "$temp_log")
        local total_time="-1"
        if [[ -n "$exec_line" ]]; then
            if [[ "$exec_line" =~ ([0-9]+\.?[0-9]*)ms ]]; then
                total_time=$(echo "${BASH_REMATCH[1]} / 1000" | bc -l)
            elif [[ "$exec_line" =~ ([0-9]+\.?[0-9]*)s ]]; then
                total_time="${BASH_REMATCH[1]}"
            fi
        fi
        
        # Calculate execution time
        local exec_time="-1"
        if [[ "$load_time" != "-1" && "$total_time" != "-1" ]]; then
            exec_time=$(echo "$total_time - $load_time" | bc -l)
        fi
        
        # Track fastest times
        if [[ "$load_time" != "-1" ]]; then
            if [[ -z "$fastest_load" || $(echo "$load_time < $fastest_load" | bc -l) -eq 1 ]]; then
                fastest_load="$load_time"
            fi
        fi
        
        if [[ "$exec_time" != "-1" ]]; then
            if [[ -z "$fastest_exec" || $(echo "$exec_time < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$exec_time"
            fi
        fi
        
        rm -f "$temp_log"
    done
    
    # Format results
    local formatted_load="${fastest_load:-"-1"}"
    local formatted_exec="${fastest_exec:-"-1"}"
    
    if [[ "$formatted_load" != "-1" ]]; then
        formatted_load=$(printf "%.4f" "$formatted_load")
    fi
    
    if [[ "$formatted_exec" != "-1" ]]; then
        formatted_exec=$(printf "%.4f" "$formatted_exec")
    fi

    echo "  Fastest times: load=$formatted_load exec=$formatted_exec"

    # Write results to temp file
    {
        echo "$formatted_load"
        echo "$formatted_exec"
    } > "$TEMP_RESULT_FILE"
    echo "  Results: load=$formatted_load exec=$formatted_exec"
}

# -----------------------------------------------------------------------------
# Umbra Scalability Test Function
# -----------------------------------------------------------------------------
run_umbra_scalability() {
    local base=$1
    local dataset=$2
    local thread_count=$3
    local load_tpl="program/umbra/${base}_load.sql"
    local exec_tpl="program/umbra/${base}_execute.sql"

    echo "  Starting Umbra test: $base on $dataset (${thread_count} CPUs)"

    # Generate CPU set for Umbra (0-based indexing)
    local cpuset
    if [[ $thread_count -eq 1 ]]; then
        cpuset="0"
    else
        cpuset="0-$((thread_count-1))"
    fi
    echo "  Using CPU set: $cpuset"

    # Check if template files exist
    [[ ! -f "$load_tpl" || ! -f "$exec_tpl" ]] && { 
        echo "  ERROR: Template files not found"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        return
    }

    # Prepare SQL files
    sed "s|{{DATASET_PATH}}|/hostdata/dataset/${dataset}|g" "$load_tpl" > "${TEMP_SQL}_${thread_count}_load.sql"
    cp "$exec_tpl" "${TEMP_SQL}_${thread_count}_exec.sql"

    local fastest_exec=""
    local load_times=()

    # Run load database three times and get median
    echo "  Loading database (3 runs for median)..."
    for i in {1..3}; do
        echo "    Load run $i/3"
        # Create fresh database for each load test
        sudo docker run --rm -v umbra-db-${thread_count}-load-${i}:/var/db umbradb/umbra:latest \
            umbra-sql -createdb /var/db/umbra.db > /dev/null
        
        local load_time_i=$(/usr/bin/time -f "%e" \
            bash -c "sudo docker run --rm \
                --cpuset-cpus='$cpuset' \
                --memory='250g' \
                -v umbra-db-${thread_count}-load-${i}:/var/db \
                -v \"$PWD\":/hostdata \
                --user root \
                umbradb/umbra:latest \
                bash -c 'umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_${thread_count}_load.sql' \
                > /dev/null 2>&1" 2>&1)
        
        load_times+=("$load_time_i")
        echo "      Load completed in $load_time_i seconds"
        
        # Clean up load test database
        sudo docker volume rm umbra-db-${thread_count}-load-${i} > /dev/null 2>&1 || true
    done
    
    # Calculate median of load times
    IFS=$'\n' sorted_load_times=($(sort -n <<<"${load_times[*]}"))
    load_time="${sorted_load_times[1]}"  # Middle value (0-indexed)
    echo "  Load times: ${load_times[*]}"
    echo "  Median load time: $load_time seconds"

    # Create final database for execution tests
    echo "  Creating final database for execution tests..."
    sudo docker run --rm -v umbra-db-${thread_count}:/var/db umbradb/umbra:latest \
        umbra-sql -createdb /var/db/umbra.db > /dev/null
    
    # Load data into final database
    sudo docker run --rm \
        --cpuset-cpus="$cpuset" \
        --memory='250g' \
        -v umbra-db-${thread_count}:/var/db \
        -v "$PWD":/hostdata \
        --user root \
        umbradb/umbra:latest \
        bash -c "umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_${thread_count}_load.sql" \
        > /dev/null 2>&1

    # Run logging execution
    echo "  Running logging execution..."
    echo "=== Umbra Scalability Log for $base on $dataset (${thread_count} CPUs) ===" > "./log/scalability/umbra_${base}_${dataset}_${thread_count}t.log"
    sudo docker run --rm \
        --cpuset-cpus="$cpuset" \
        --memory='250g' \
        -v umbra-db-${thread_count}:/var/db \
        -v "$PWD":/hostdata \
        --user root \
        umbradb/umbra:latest \
        bash -c "umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_${thread_count}_exec.sql" \
        >> "./log/scalability/umbra_${base}_${dataset}_${thread_count}t.log" 2>&1 || \
        echo "  WARNING: Logging execution failed"

    # Run timing executions
    echo "  Running timing executions..."
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local etime=""
        
        if /usr/bin/time -f "%e" -o /tmp/umbra_time_${thread_count}.tmp \
                sudo docker run --rm \
                --cpuset-cpus="$cpuset" \
                --memory='250g' \
                -v umbra-db-${thread_count}:/var/db \
                -v "$PWD":/hostdata \
                --user root \
                umbradb/umbra:latest \
                bash -c "umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_${thread_count}_exec.sql" \
                > /dev/null 2>&1; then
            if [[ -f /tmp/umbra_time_${thread_count}.tmp ]]; then
                etime=$(cat /tmp/umbra_time_${thread_count}.tmp)
                rm -f /tmp/umbra_time_${thread_count}.tmp
                # Validate timing result
                if [[ "$etime" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                    echo "      Completed in $etime seconds"
                else
                    echo "      Invalid time value, skipping"
                    continue
                fi
            else
                echo "      No time file found, skipping"
                continue
            fi
        else
            rm -f /tmp/umbra_time_${thread_count}.tmp
            echo "      Execution failed, skipping"
            continue
        fi
        
        # Track fastest execution time
        if [[ -n "$etime" ]]; then
            if [[ -z "$fastest_exec" || $(echo "$etime < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$etime"
            fi
        fi
    done

    # Set fallback if no valid execution time was recorded
    if [[ -z "$fastest_exec" ]]; then
        fastest_exec="-1"
    fi

    echo "  Fastest execution time: $fastest_exec seconds"
    
    # Clean up Docker resources
    echo "  Waiting for Docker cleanup to complete..."
    sleep 10

    CONTAINER_ID=$(sudo docker ps -q --filter ancestor=umbradb/umbra:latest)

    if [ -n "$CONTAINER_ID" ]; then
        echo "[INFO] Stopping Umbra container: $CONTAINER_ID"
        sudo docker stop "$CONTAINER_ID"
    else
        echo "[INFO] No running Umbra container found."
    fi
    
    echo "  Removing Docker volume..."
    sudo docker volume rm umbra-db > /dev/null 2>&1 || echo "  WARNING: Could not remove volume"

    # Write results to temp file
    {
        echo "$load_time" 
        echo "$fastest_exec" 
    } > "$TEMP_RESULT_FILE"
    echo "  Results: load=$load_time exec=$fastest_exec"
}

# -----------------------------------------------------------------------------
# DDlog Scalability Test Function
# -----------------------------------------------------------------------------
run_ddlog_scalability() {
    local base=$1
    local dataset=$2
    local thread_count=$3
    local ddlog_prog="program/ddlog/${base}.dl"
    local fact_path="dataset/${dataset}/data.ddin"
    local build_dir="${base}_ddlog"
    local exe="${build_dir}/target/release/${base}_cli"
    local rust_v=1.76

    echo "  Starting DDlog test: $base on $dataset (${thread_count} workers)"

    # Check if required files exist
    [[ ! -f "$ddlog_prog" ]] && { 
        echo "  ERROR: DDlog program file not found: $ddlog_prog"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        return
    }
    [[ ! -f "$fact_path" ]] && { 
        echo "  ERROR: Dataset file not found: $fact_path"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        return
    }

    # Compile DDlog program if not already compiled
    if [[ ! -x "$exe" ]]; then
        echo "  Compiling DDlog program..."
        rm -rf "${build_dir}" || true
        ddlog -i "$ddlog_prog" -o ./
        pushd "$build_dir" >/dev/null
        RUSTFLAGS=-Awarnings cargo +$rust_v build --release --quiet
        popd >/dev/null
    fi

    # Run logging execution
    local log_file="./log/scalability/ddlog_${base}_${dataset}_${thread_count}t.log"
    echo "=== DDlog Scalability Log for $base on $dataset (${thread_count} workers) ===" > "$log_file"
    "$exe" -w "$thread_count" < "$fact_path" >> "$log_file" 2>&1 || echo "  WARNING: Logging execution failed"

    # Run timing executions
    echo "  Running timing executions..."
    local fastest_exec=""
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local temp_log="./log/scalability/ddlog_${base}_${dataset}_${thread_count}t_${i}.log"
        /usr/bin/time -f "LinuxRT: %e" "$exe" -w "$thread_count" < "$fact_path" > "$temp_log" 2>&1
        # Extract execution time
        local exec_time=$(grep "LinuxRT:" "$temp_log" | tail -1 | awk '{print $2}')
        if [[ "$exec_time" =~ ^[0-9]+\.?[0-9]*$ ]]; then
            echo "      Completed in $exec_time seconds"
            if [[ -z "$fastest_exec" || $(echo "$exec_time < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$exec_time"
            fi
        else
            echo "      Invalid or missing time, skipping"
        fi
        rm -f "$temp_log"
    done

    if [[ -z "$fastest_exec" ]]; then
        fastest_exec="-1"
    fi

    # DDlog does not have a separate load phase, so set load_time to -1
    local load_time="-1"

    echo "  Fastest execution time: $fastest_exec seconds"

    rm -f "${base}_ddlog"

    # Write results to temp file
    {
        echo "$load_time"
        echo "$fastest_exec"
    } > "$TEMP_RESULT_FILE"
    echo "  Results: load=$load_time exec=$fastest_exec"
}

# =============================================================================
# Main Scalability Testing Loop
# =============================================================================

while IFS='=' read -r program dataset; do
    [[ -z "$program" || "$program" =~ ^# ]] && continue

    DATASET_PATH="${DATASET_DIR}/${dataset}"
    ZIP_URL="https://pages.cs.wisc.edu/~m0riarty/dataset/${dataset}.zip"
    ZIP_PATH="/dev/shm/${dataset}.zip"

    # Download and extract dataset if needed
    # if [[ -d "$DATASET_PATH" ]]; then
    #     echo "SKIP: Dataset already exists: $DATASET_PATH"
    # else
    #     echo "PREP: Downloading and extracting dataset: $dataset"
    #     wget -O "$ZIP_PATH" "$ZIP_URL"
    #     unzip "$ZIP_PATH" -d "$DATASET_DIR"
    # fi

    echo ""
    echo "=== SCALABILITY TESTING: $program on $dataset ==="

    # Test each thread count
    for thread_count in "${THREAD_COUNTS[@]}"; do
        echo ""
        echo "--- Testing with $thread_count threads ---"

        # Run DuckDB scalability test
        echo ""
        echo "DuckDB ($thread_count threads):"
        run_duckdb_scalability "$program" "$dataset" "$thread_count"
        mapfile -t lines < "$TEMP_RESULT_FILE"
        duck_load="${lines[0]}"
        duck_exec="${lines[1]}"
        echo "DuckDB completed: load=$duck_load exec=$duck_exec"
        
        # Run Umbra scalability test
        echo ""
        echo "Umbra ($thread_count CPUs):"
        run_umbra_scalability "$program" "$dataset" "$thread_count"
        mapfile -t lines < "$TEMP_RESULT_FILE"
        umbra_load="${lines[0]}"
        umbra_exec="${lines[1]}"
        echo "Umbra completed: load=$umbra_load exec=$umbra_exec"
        
        # Run FlowLog scalability test
        echo ""
        echo "FlowLog ($thread_count workers):"
        run_flowlog_scalability "$program" "$dataset" "$thread_count"
        mapfile -t lines < "$TEMP_RESULT_FILE"
        flowlog_load="${lines[0]}"
        flowlog_exec="${lines[1]}"
        echo "FlowLog completed: load=$flowlog_load exec=$flowlog_exec"

        echo ""
        echo "DDlog ($thread_count workers):"
        run_ddlog_scalability "$program" "$dataset" "$thread_count"
        mapfile -t lines < "$TEMP_RESULT_FILE"
        ddlog_load="${lines[0]}"
        ddlog_exec="${lines[1]}"
        echo "DDlog completed: load=$ddlog_load exec=$ddlog_exec"

        # Write results to file
        printf "%-20s %-20s %-8s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s\n" \
            "$program" "$dataset" "$thread_count" "$duck_load" "$duck_exec" \
            "$umbra_load" "$umbra_exec" "$flowlog_load" "$flowlog_exec" \
            "$ddlog_load" "$ddlog_exec" \
            >> "$RESULT_FILE"

        echo "Results written for $thread_count threads"
    done

    # Cleanup
    echo ""
    echo "CLEANUP: Removing dataset: $dataset"
    rm -rf "$ZIP_PATH" "${DATASET_DIR:?}/${dataset}"

    # Show progress
    echo ""
    echo "=== RESULTS SO FAR ==="
    cat "$RESULT_FILE"
    echo ""
done < "$CONFIG_FILE"

# =============================================================================
# Cleanup and Final Results
# =============================================================================

# Clean up temporary files
rm -f "${TEMP_SQL}"_*.sql
rm -f "$TEMP_RESULT_FILE"

# Display final results
echo ""
echo "=============================================="
echo "         FINAL SCALABILITY RESULTS"
echo "=============================================="
cat "$RESULT_FILE"

echo ""
echo "=============================================="
echo "Scalability testing completed!"
echo "Results saved to: $RESULT_FILE"
echo "Logs saved to: ./log/scalability/"
echo "=============================================="
