#!/bin/bash
set -e

# =============================================================================
# Database Benchmark Script
# =============================================================================
# Benchmarks DuckDB, Umbra, and FlowLog databases with configurable parameters

# Default timeout in seconds (15 minutes) and thread count
TIMEOUT_SECONDS=${1:-900}
THREAD_COUNT=${2:-64}

# Display usage if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [TIMEOUT_SECONDS] [THREAD_COUNT]"
    echo ""
    echo "Run database benchmarks with configurable timeout and thread count."
    echo ""
    echo "Arguments:"
    echo "  TIMEOUT_SECONDS  Timeout for each query execution in seconds (default: 900 = 15 minutes)"
    echo "  THREAD_COUNT     Number of threads/workers to use (default: 64)"
    echo ""
    echo "Examples:"
    echo "  $0                # Use default 15-minute timeout and 64 threads"
    echo "  $0 600            # Use 10-minute timeout and 64 threads"
    echo "  $0 1800 32        # Use 30-minute timeout and 32 threads"
    echo "  $0 900 4          # Use 15-minute timeout and 4 threads"
    exit 0
fi

# =============================================================================
# Configuration and Setup
# =============================================================================

CONFIG_FILE="./tool/config/benchmark.txt"
TEMP_SQL="tmp_sql"
DATASET_DIR="./dataset"
RESULT_FILE="benchmark.txt"
TEMP_RESULT_FILE="/tmp/benchmark_result.tmp"

# Initialize directories and files
mkdir -p "$DATASET_DIR"
rm -rf "$RESULT_FILE"
mkdir -p "./log/benchmark/${THREAD_COUNT}"

echo "=== Database Benchmark Configuration ==="
echo "Timeout: ${TIMEOUT_SECONDS} seconds ($(echo "scale=1; $TIMEOUT_SECONDS/60" | bc -l) minutes)"
echo "Thread count: ${THREAD_COUNT}"

# Generate CPU set for Umbra (0-based indexing)
if [[ $THREAD_COUNT -eq 1 ]]; then
    CPUSET="0"
else
    CPUSET="0-$((THREAD_COUNT-1))"
fi
echo "CPU set: ${CPUSET}"
echo ""

# Initialize result file with headers
if [[ ! -f "$RESULT_FILE" ]]; then
    printf "%-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s\n" \
        "Program" "Dataset" "Duck_Load(s)" "Duck_Exec(s)" \
        "Umbra_Load(s)" "Umbra_Exec(s)" "FlowLog_Load(s)" "FlowLog_Exec(s)" \
        "Souffle_Load(s)" "Souffle_Exec(s)" "DDlog_Load(s)" "DDlog_Exec(s)" \
        "RecStep_Load(s)" "RecStep_Exec(s)" \
        > "$RESULT_FILE"
    printf "%-20s %-20s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %-12s\n" \
        "--------------------" "--------------------" "--------------------" "--------------------" \
        "--------------------" "--------------------" "--------------------" "--------------------" \
        "--------------------" "--------------------" "--------------------" "--------------------" \
        "--------------------" "--------------------" \
        >> "$RESULT_FILE"
fi

# =============================================================================
# Database Benchmark Functions
# =============================================================================
# -----------------------------------------------------------------------------
# DuckDB Benchmark Function
# -----------------------------------------------------------------------------
run_duckdb() {
    local base=$1
    local dataset=$2
    local load_tpl="program/duck/${base}_load.sql"
    local exec_tpl="program/duck/${base}_execute.sql"
    local duckdb_db="temp.duckdb"

    echo "  Starting DuckDB benchmark: $base on $dataset"

    # Check if template files exist
    [[ ! -f "$load_tpl" || ! -f "$exec_tpl" ]] && { 
        echo "  ERROR: Template files not found"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        return 
    }

    # Prepare SQL files
    sed "s|{{DATASET_PATH}}|dataset/${dataset}|g" "$load_tpl" > "${TEMP_SQL}_load.sql"
    cp "$exec_tpl" "${TEMP_SQL}_exec.sql"

    # Add thread count pragma to DuckDB execution SQL
    echo "  Setting thread count: $THREAD_COUNT"
    sed -i "1i PRAGMA threads=$THREAD_COUNT;" "${TEMP_SQL}_load.sql"
    sed -i "1i PRAGMA threads=$THREAD_COUNT;" "${TEMP_SQL}_exec.sql"

    local fastest_exec=""

    # Load database
    echo "  Loading database..."
    load_time=$(/usr/bin/time -f "%e" duckdb "$duckdb_db" < "${TEMP_SQL}_load.sql" 2>&1 >/dev/null)
    echo "  Database loaded in $load_time seconds"

    # Run logging execution
    echo "  Running logging execution..."
    echo "=== DuckDB Execute Log for $base on $dataset ===" > "./log/benchmark/${THREAD_COUNT}/duckdb_${base}_${dataset}.log"
    timeout "$TIMEOUT_SECONDS" duckdb "$duckdb_db" < "${TEMP_SQL}_exec.sql" \
        >> "./log/benchmark/${THREAD_COUNT}/duckdb_${base}_${dataset}.log" 2>&1 || \
        echo "  WARNING: Logging execution failed or timed out"

    # Run timing executions
    echo "  Running timing executions..."
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local etime=""
        
        if timeout "$TIMEOUT_SECONDS" /usr/bin/time -f "%e" -o /tmp/duckdb_time.tmp \
                duckdb "$duckdb_db" < "${TEMP_SQL}_exec.sql" > /dev/null 2>&1; then
            if [[ -f /tmp/duckdb_time.tmp ]]; then
                etime=$(cat /tmp/duckdb_time.tmp)
                rm -f /tmp/duckdb_time.tmp
                # Validate that etime is a valid number
                if [[ "$etime" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                    echo "      Completed in $etime seconds"
                else
                    etime="$TIMEOUT_SECONDS"
                    echo "      Invalid time value, using timeout"
                fi
            else
                etime="$TIMEOUT_SECONDS"
                echo "      No time file found, using timeout value"
            fi
        else
            etime="$TIMEOUT_SECONDS"
            rm -f /tmp/duckdb_time.tmp
            echo "      Timed out"
        fi
        
        # Track fastest execution time
        if [[ -n "$etime" && "$etime" != "$TIMEOUT_SECONDS" ]]; then
            if [[ -z "$fastest_exec" || $(echo "$etime < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$etime"
            fi
        fi
    done

    # Set fallback if no valid execution time was recorded
    if [[ -z "$fastest_exec" ]]; then
        fastest_exec="$TIMEOUT_SECONDS"
    fi

    echo "  Fastest execution time: $fastest_exec seconds"
    rm -f "$duckdb_db"

    # Write results to temp file
    {
        echo "$load_time"
        echo "$fastest_exec"
    } > "$TEMP_RESULT_FILE"
    echo "  Results: load=$load_time exec=$fastest_exec"
}

# -----------------------------------------------------------------------------
# FlowLog Benchmark Function
# -----------------------------------------------------------------------------
run_flowlog() {
    echo "=== Building FlowLog ==="
    cd FlowLog
    git checkout nemo_arithmetic
    git pull
    cargo build --release
    cd ..
    echo "FlowLog build completed"
    echo ""

    local base=$1
    local dataset=$2
    local prog_file="program/flowlog/${base}.dl"
    local fact_path="dataset/${dataset}"
    local flowlog_binary="./FlowLog/target/release/executing"
    local workers=$THREAD_COUNT
    
    echo "  Starting FlowLog benchmark: $base on $dataset"
    echo "  Using $workers workers"
    
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
    local log_file="./log/benchmark/${THREAD_COUNT}/flowlog_${base}_${dataset}.log"
    echo "=== FlowLog Execute Log for $base on $dataset ===" > "$log_file"
    timeout "$TIMEOUT_SECONDS" "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$workers" \
        >> "$log_file" 2>&1 || echo "  WARNING: Logging execution failed or timed out"
    
    # Run timing executions
    echo "  Running timing executions..."
    local fastest_load=""
    local fastest_exec=""
    
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local temp_log="./log/benchmark/${THREAD_COUNT}/flowlog_${base}_${dataset}_${i}.log"
        
        # Run FlowLog with timeout and capture output
        if timeout "$TIMEOUT_SECONDS" "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$workers" \
            > "$temp_log" 2>&1; then
            echo "      Completed successfully"
        else
            echo "      Timed out"
            # Set timeout values and continue
            if [[ -z "$fastest_load" || $(echo "$TIMEOUT_SECONDS < $fastest_load" | bc -l) -eq 1 ]]; then
                fastest_load="$TIMEOUT_SECONDS"
            fi
            if [[ -z "$fastest_exec" || $(echo "$TIMEOUT_SECONDS < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$TIMEOUT_SECONDS"
            fi
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

    # Write results to temp file
    {
        echo "$formatted_load"
        echo "$formatted_exec"
    } > "$TEMP_RESULT_FILE"
    echo "  Results: load=$formatted_load exec=$formatted_exec"
    cd FlowLog
    cargo clean
    cd ..
}

# -----------------------------------------------------------------------------
# Umbra Benchmark Function
# -----------------------------------------------------------------------------
run_umbra() {
    local base=$1
    local dataset=$2
    local load_tpl="program/umbra/${base}_load.sql"
    local exec_tpl="program/umbra/${base}_execute.sql"

    echo "  Starting Umbra benchmark: $base on $dataset"
    
    echo "  Using CPU set: $CPUSET"

    # Check if template files exist
    [[ ! -f "$load_tpl" || ! -f "$exec_tpl" ]] && { 
        echo "  ERROR: Template files not found"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        return
    }

    # Create database
    echo "  Creating database..."
    sudo docker run --rm -v umbra-db:/var/db umbradb/umbra:latest \
        umbra-sql -createdb /var/db/umbra.db > /dev/null

    # Prepare SQL files
    sed "s|{{DATASET_PATH}}|/hostdata/dataset/${dataset}|g" "$load_tpl" > "${TEMP_SQL}_load.sql"
    cp "$exec_tpl" "${TEMP_SQL}_exec.sql"

    local fastest_exec=""
    local load_times=()

    # Run load database three times and get median
    echo "  Loading database (3 runs for median)..."
    for i in {1..3}; do
        echo "    Load run $i/3"
        # Create fresh database for each load test
        sudo docker run --rm -v umbra-db-load-${i}:/var/db umbradb/umbra:latest \
            umbra-sql -createdb /var/db/umbra.db > /dev/null
        
        local load_time_i=$(/usr/bin/time -f "%e" \
            bash -c "sudo docker run --rm \
                --cpuset-cpus='$CPUSET' \
                --memory='250g' \
                -v umbra-db-load-${i}:/var/db \
                -v \"$PWD\":/hostdata \
                --user root \
                umbradb/umbra:latest \
                bash -c 'umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_load.sql' \
                > /dev/null 2>&1" 2>&1)
        
        load_times+=("$load_time_i")
        echo "      Load completed in $load_time_i seconds"
        
        # Clean up load test database
        sudo docker volume rm umbra-db-load-${i} > /dev/null 2>&1 || true
    done
    
    # Calculate median of load times
    IFS=$'\n' sorted_load_times=($(sort -n <<<"${load_times[*]}"))
    load_time="${sorted_load_times[1]}"  # Middle value (0-indexed)
    echo "  Load times: ${load_times[*]}"
    echo "  Median load time: $load_time seconds"

    # Create final database for execution tests
    echo "  Creating final database for execution tests..."
    sudo docker run --rm -v umbra-db:/var/db umbradb/umbra:latest \
        umbra-sql -createdb /var/db/umbra.db > /dev/null
    
    # Load data into final database
    sudo docker run --rm \
        --cpuset-cpus="$CPUSET" \
        --memory='250g' \
        -v umbra-db:/var/db \
        -v "$PWD":/hostdata \
        --user root \
        umbradb/umbra:latest \
        bash -c "umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_load.sql" \
        > /dev/null 2>&1

    # Run logging execution
    echo "  Running logging execution..."
    echo "=== Umbra Execute Log for $base on $dataset ===" > "./log/benchmark/${THREAD_COUNT}/umbra_${base}_${dataset}.log"
    timeout "$TIMEOUT_SECONDS" sudo docker run --rm \
        --cpuset-cpus="$CPUSET" \
        --memory='250g' \
        -v umbra-db:/var/db \
        -v "$PWD":/hostdata \
        --user root \
        umbradb/umbra:latest \
        bash -c "umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_exec.sql" \
        >> "./log/benchmark/${THREAD_COUNT}/umbra_${base}_${dataset}.log" 2>&1 || \
        echo "  WARNING: Logging execution failed or timed out"

    # Run timing executions
    echo "  Running timing executions..."
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local etime=""
        
        if timeout "$TIMEOUT_SECONDS" /usr/bin/time -f "%e" -o /tmp/umbra_time.tmp \
                sudo docker run --rm \
                --cpuset-cpus="$CPUSET" \
                --memory='250g' \
                -v umbra-db:/var/db \
                -v "$PWD":/hostdata \
                --user root \
                umbradb/umbra:latest \
                bash -c "umbra-sql /var/db/umbra.db < /hostdata/${TEMP_SQL}_exec.sql" \
                > /dev/null 2>&1; then
            if [[ -f /tmp/umbra_time.tmp ]]; then
                etime=$(cat /tmp/umbra_time.tmp)
                rm -f /tmp/umbra_time.tmp
                # Validate timing result
                if [[ "$etime" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                    echo "      Completed in $etime seconds"
                else
                    etime="$TIMEOUT_SECONDS"
                    echo "      Invalid time value, using timeout"
                fi
            else
                etime="$TIMEOUT_SECONDS"
                echo "      No time file found, using timeout valu $etime"
            fi
        else
            etime="$TIMEOUT_SECONDS"
            rm -f /tmp/umbra_time.tmp
            echo "      Timed out"
        fi
        
        # Track fastest execution time
        if [[ -n "$etime" && "$etime" != "$TIMEOUT_SECONDS" ]]; then
            if [[ -z "$fastest_exec" || $(echo "$etime < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$etime"
            fi
        fi
    done

    # Set fallback if no valid execution time was recorded
    if [[ -z "$fastest_exec" ]]; then
        fastest_exec="$TIMEOUT_SECONDS"
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
# Souffle Benchmark Function
# -----------------------------------------------------------------------------
run_souffle() {
    local base=$1
    local dataset=$2
    local dl_src="program/souffle/${base}.dl"
    local fact_path="dataset/${dataset}"
    local bin="program/souffle/${base}_souffle"
    local profile_log="/tmp/souffle_${base}_${dataset}.prof"

    echo "  Starting Souffle benchmark: $base on $dataset"

    # Check files
    [[ ! -f "$dl_src" ]] && { 
        echo "  ERROR: Souffle program not found: $dl_src"; 
        echo "-1 -1" > "$TEMP_RESULT_FILE"; 
        return; 
    }
    [[ ! -d "$fact_path" ]] && { 
        echo "  ERROR: Dataset path not found: $fact_path"; 
        echo "-1 -1" > "$TEMP_RESULT_FILE"; 
        return; 
    }

    # Compile Souffle program
    echo "  Compiling Souffle program..."
    if ! souffle -o "$bin" -p /dev/null "$dl_src" -j "$THREAD_COUNT" >/dev/null 2>&1; then
        echo "  ERROR: Souffle compilation failed"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        return
    fi

    # Logging execution with profiling
    echo "  Running logging execution with profiling..."
    local log_file="./log/benchmark/${THREAD_COUNT}/souffle_${base}_${dataset}.log"
    echo "=== Souffle Execute Log for $base on $dataset ===" > "$log_file"
    timeout "$TIMEOUT_SECONDS" "$bin" -F "$fact_path" -j "$THREAD_COUNT" -p "$profile_log" \
        >> "$log_file" 2>&1 || echo "  WARNING: Logging execution failed or timed out"

    # Timing executions (3 runs): capture fastest total time and estimate load/exec via profiler
    echo "  Running timing executions..."
    local fastest_total=""
    local best_load=""
    local best_exec=""
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local prof_i="/tmp/souffle_${base}_${dataset}_${i}.prof"
        local etime=""
        if timeout "$TIMEOUT_SECONDS" /usr/bin/time -f "%e" -o /tmp/souffle_time.tmp \
            "$bin" -F "$fact_path" -j "$THREAD_COUNT" -p "$prof_i" > /dev/null 2>&1; then
            etime=$(cat /tmp/souffle_time.tmp 2>/dev/null || echo "")
            rm -f /tmp/souffle_time.tmp
            if [[ "$etime" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                echo "      Completed in $etime seconds"
                # Parse from souffleprof top: runtime loadtime savetime (first table row)
                local topout="$(souffleprof "$prof_i" -c top 2>/dev/null || true)"
                local vals
                vals=$(printf "%s\n" "$topout" | awk 'BEGIN{found=0} /(^|[[:space:]])runtime[[:space:]]+loadtime[[:space:]]+savetime([[:space:]]|$)/{found=1; next} found==1 && NF {print $1, $2, $3; exit}')

                local rt_raw="" ld_raw="" sv_raw=""
                if [[ -n "$vals" ]]; then
                    read -r rt_raw ld_raw sv_raw <<< "$vals"
                fi
                echo "      [DEBUG] vals: '$vals'"
                echo "      [DEBUG] rt_raw: '$rt_raw' ld_raw: '$ld_raw' sv_raw: '$sv_raw'"

                # Validate rt_raw is a time string before conversion
                if ! [[ "$rt_raw" =~ ^([0-9]+\.?[0-9]*|\.[0-9]+)(m|s|ms)$ ]]; then
                    echo "      [DEBUG] rt_raw is not a valid time string, skipping this run."
                    continue
                fi

                # Convert helper: supports values like .123s or 12.3ms
                convert_to_seconds() {
                    local val="$1"
                    if [[ -z "$val" ]]; then echo ""; return; fi
                    # Accept numbers like 12.3, .368, 3, .12300000000000000000
                    if [[ "$val" =~ ^([0-9]+\.?[0-9]*|\.[0-9]+)m$ ]]; then
                        # minutes to seconds
                        echo "$(echo \"${BASH_REMATCH[1]} * 60\" | bc -l)"
                    elif [[ "$val" =~ ^([0-9]+\.?[0-9]*|\.[0-9]+)s$ ]]; then
                        echo "${BASH_REMATCH[1]}"
                    elif [[ "$val" =~ ^([0-9]+\.?[0-9]*|\.[0-9]+)ms$ ]]; then
                        echo "$(echo \"${BASH_REMATCH[1]} / 1000\" | bc -l)"
                    else
                        echo ""
                    fi
                }
                local rt_sec="$(convert_to_seconds "$rt_raw")"
                local ld_sec="$(convert_to_seconds "$ld_raw")"
                local sv_sec="$(convert_to_seconds "$sv_raw")"

                # Compute exec for this run: runtime - loadtime (savetime included in exec since we output only size)

                local exec_run=""
                if [[ -n "$rt_sec" ]]; then
                    local sub_ld="${ld_sec:-0}"
                    exec_run=$(echo "$rt_sec - $sub_ld" | bc -l)
                fi

                echo "      [DEBUG] runtime (rt_sec): $rt_sec, load_run (ld_sec): $ld_sec, exec_run: $exec_run"

                # Track fastest total and corresponding load/exec
                if [[ -z "$fastest_total" || $(echo "$etime < $fastest_total" | bc -l) -eq 1 ]]; then
                    fastest_total="$etime"
                    best_load="${ld_sec:-}"
                    best_exec="${exec_run:-}"
                fi
            else
                echo "      Invalid time value, skipping"
            fi
        else
            rm -f /tmp/souffle_time.tmp
            echo "      Timed out"
        fi
        rm -f "$prof_i" 2>/dev/null || true
    done

    # If no valid total time, set to -1
    if [[ -z "$fastest_total" ]]; then
        fastest_total="$TIMEOUT_SECONDS"
        best_load="$TIMEOUT_SECONDS"
    fi

    # Compute execution time as total - load (if load available)
    local exec_time="$fastest_total"
    if [[ -n "$best_load" && "$fastest_total" != "-1" ]]; then
        exec_time=$(echo "$fastest_total - $best_load" | bc -l)
    fi

    # Write results
    {
        echo "$best_load"
        echo "$exec_time"
    } > "$TEMP_RESULT_FILE"
    echo "  Results: load=$best_load exec=$exec_time"
}

# -----------------------------------------------------------------------------
# RecStep Benchmark Function
# -----------------------------------------------------------------------------
run_recstep() {
    local base=$1
    local dataset=$2
    local prog_file="program/recstep/${base}.dl"
    local load_prog_file="program/recstep/${base}_load.dl"
    local fact_path="dataset/${dataset}"

    echo "  Starting RecStep benchmark: $base on $dataset"

    # Check files
    [[ ! -f "$prog_file" ]] && { 
        echo "  ERROR: RecStep program not found: $prog_file"; 
        echo "-1 -1" > "$TEMP_RESULT_FILE"; 
        return; 
    }
    [[ ! -f "$load_prog_file" ]] && { 
        echo "  ERROR: RecStep load-only program not found: $load_prog_file"; 
        echo "-1 -1" > "$TEMP_RESULT_FILE"; 
        return; 
    }
    [[ ! -d "$fact_path" ]] && { 
        echo "  ERROR: Dataset path not found: $fact_path"; 
        echo "-1 -1" > "$TEMP_RESULT_FILE"; 
        return; 
    }

    # Source environment lazily and non-destructively
    local OLD_PATH="$PATH"
    if [[ -f "$HOME/recstep_env" ]]; then
        # shellcheck disable=SC1090
        source "$HOME/recstep_env"
    fi
    if ! command -v recstep >/dev/null 2>&1; then
        echo "  ERROR: recstep CLI not found in PATH"
        echo "-1 -1" > "$TEMP_RESULT_FILE"
        PATH="$OLD_PATH"
        return
    fi

    # Optional: one logging run of full program
    echo "  Running RecStep logging run..."
    echo "=== RecStep Execute Log for $base on $dataset ===" > "./log/benchmark/${THREAD_COUNT}/recstep_${base}_${dataset}.log"
    timeout "$TIMEOUT_SECONDS" recstep --program "$prog_file" --input "$fact_path" --jobs "$THREAD_COUNT" \
        >> "./log/benchmark/${THREAD_COUNT}/recstep_${base}_${dataset}.log" 2>&1 || echo "  WARNING: RecStep logging execution failed or timed out"

    # Time load-only program (3 runs; fastest)
    local fastest_load=""
    for i in {1..3}; do
        echo "    Load-only timing run $i/3"
        # Clear date-stamped logs
        find ./log -maxdepth 1 -type f -regextype posix-extended -regex "\./log/[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]+" -delete 2>/dev/null || true
        local ltime=""
        if timeout "$TIMEOUT_SECONDS" /usr/bin/time -f "%e" -o /tmp/recstep_load_time.tmp \
            recstep --program "$load_prog_file" --input "$fact_path" --jobs "$THREAD_COUNT" >/dev/null 2>&1; then
            if [[ -f /tmp/recstep_load_time.tmp ]]; then
                ltime=$(cat /tmp/recstep_load_time.tmp)
                rm -f /tmp/recstep_load_time.tmp
                if [[ "$ltime" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                    echo "      Completed in $ltime seconds"
                    if [[ -z "$fastest_load" || $(echo "$ltime < $fastest_load" | bc -l) -eq 1 ]]; then
                        fastest_load="$ltime"
                    fi
                else
                    echo "      Invalid time value, skipping"
                fi
            else
                echo "      No time file found, skipping"
            fi
        else
            rm -f /tmp/recstep_load_time.tmp
            echo "      Timed out"
        fi

        sleep 2
    done

    # Time full program (3 runs; fastest total)
    local fastest_total=""
    for i in {1..3}; do
        echo "    Full-program timing run $i/3"
        # Clear date-stamped logs
        find ./log -maxdepth 1 -type f -regextype posix-extended -regex "\./log/[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]+" -delete 2>/dev/null || true
        local ttime=""
        if timeout "$TIMEOUT_SECONDS" /usr/bin/time -f "%e" -o /tmp/recstep_total_time.tmp \
            recstep --program "$prog_file" --input "$fact_path" --jobs "$THREAD_COUNT" >/dev/null 2>&1; then
            if [[ -f /tmp/recstep_total_time.tmp ]]; then
                ttime=$(cat /tmp/recstep_total_time.tmp)
                rm -f /tmp/recstep_total_time.tmp
                if [[ "$ttime" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                    echo "      Completed in $ttime seconds"
                    if [[ -z "$fastest_total" || $(echo "$ttime < $fastest_total" | bc -l) -eq 1 ]]; then
                        fastest_total="$ttime"
                    fi
                else
                    echo "      Invalid time value, skipping"
                fi
            else
                echo "      No time file found, skipping"
            fi
        else
            rm -f /tmp/recstep_total_time.tmp
            echo "      Timed out"
        fi

        sleep 2
    done

    # Restore PATH
    PATH="$OLD_PATH"

    # Fallbacks on complete timeout
    if [[ -z "$fastest_load" ]]; then fastest_load="$TIMEOUT_SECONDS"; fi
    if [[ -z "$fastest_total" ]]; then fastest_total="$TIMEOUT_SECONDS"; fi

    # Compute exec as fastest_total - fastest_load, unless timed out
    local out_load="${fastest_load}"
    local out_total="${fastest_total}"
    local out_exec="-1"
    if [[ "$out_total" == "$TIMEOUT_SECONDS" || "$out_load" == "$TIMEOUT_SECONDS" ]]; then
        out_exec="$TIMEOUT_SECONDS"
    elif [[ "$out_load" =~ ^[0-9]+\.?[0-9]*$ && "$out_total" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        out_exec=$(echo "$out_total - $out_load" | bc -l)
    fi

    # Format outputs
    if [[ "$out_load" =~ ^[0-9]+\.?[0-9]*$ ]]; then out_load=$(printf "%.4f" "$out_load"); else out_load="-1"; fi
    if [[ "$out_exec" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then out_exec=$(printf "%.4f" "$out_exec"); else out_exec="-1"; fi

    # Write results
    {
        echo "$out_load"
        echo "$out_exec"
    } > "$TEMP_RESULT_FILE"
    echo "  Results: load=$out_load exec=$out_exec"
}
# =============================================================================
# Main Benchmark Loop
# =============================================================================

while IFS='=' read -r program dataset; do
    [[ -z "$program" || "$program" =~ ^# ]] && continue

    DATASET_PATH="${DATASET_DIR}/${dataset}"
    ZIP_URL="https://pages.cs.wisc.edu/~m0riarty/dataset/${dataset}.zip"
    ZIP_PATH="/dev/shm/${dataset}.zip"

    # Download and extract dataset if needed
    if [[ -d "$DATASET_PATH" ]]; then
        echo "SKIP: Dataset already exists: $DATASET_PATH"
    else
        echo "PREP: Downloading and extracting dataset: $dataset"
        wget -O "$ZIP_PATH" "$ZIP_URL"
        unzip "$ZIP_PATH" -d "$DATASET_DIR"
    fi

    echo ""
    echo "=== RUNNING: $program on $dataset ==="

    # Run DuckDB benchmark
    echo ""
    echo "--- DuckDB Benchmark ---"
    run_duckdb "$program" "$dataset"
    mapfile -t lines < "$TEMP_RESULT_FILE"
    duck_load="${lines[0]}"
    duck_exec="${lines[1]}"
    echo "DuckDB completed: load=$duck_load exec=$duck_exec"
    
    # Run Umbra benchmark
    echo ""
    echo "--- Umbra Benchmark ---"
    run_umbra "$program" "$dataset"
    mapfile -t lines < "$TEMP_RESULT_FILE"
    umbra_load="${lines[0]}"
    umbra_exec="${lines[1]}"
    echo "Umbra completed: load=$umbra_load exec=$umbra_exec"
    
    # Run FlowLog benchmark
    echo ""
    echo "--- FlowLog Benchmark ---"
    run_flowlog "$program" "$dataset"
    mapfile -t lines < "$TEMP_RESULT_FILE"
    flowlog_load="${lines[0]}"
    flowlog_exec="${lines[1]}"
    echo "FlowLog completed: load=$flowlog_load exec=$flowlog_exec"

    # Run Souffle benchmark
    echo ""
    echo "--- Souffle Benchmark ---"
    run_souffle "$program" "$dataset"
    mapfile -t lines < "$TEMP_RESULT_FILE"
    souffle_load="${lines[0]}"
    souffle_exec="${lines[1]}"
    echo "Souffle completed: load=$souffle_load exec=$souffle_exec"

    # RecStep benchmark
    echo ""
    echo "--- RecStep Benchmark ---"
    run_recstep "$program" "$dataset"
    mapfile -t lines < "$TEMP_RESULT_FILE"
    recstep_load="${lines[0]}"
    recstep_exec="${lines[1]}"
    echo "RecStep completed: load=$recstep_load exec=$recstep_exec"

    # Write results to file
    printf "%-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s\n" \
        "$program" "$dataset" "$duck_load" "$duck_exec" \
        "$umbra_load" "$umbra_exec" "$flowlog_load" "$flowlog_exec" \
        "$souffle_load" "$souffle_exec" "$ddlog_load" "$ddlog_exec" \
        "$recstep_load" "$recstep_exec" \
        >> "$RESULT_FILE"

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
echo "           FINAL TIMING RESULTS"
echo "=============================================="
cat "$RESULT_FILE"