#!/bin/bash
set -e

# =============================================================================
# Database Benchmark Script
# =============================================================================
# Benchmarks DuckDB, Umbra, and FlowLog databases with configurable parameters

# Default timeout in seconds (15 minutes), thread count and engines to run
TIMEOUT_SECONDS=900
THREAD_COUNT=64
# Comma-separated list: duckdb,umbra,flowlog,souffle,ddlog,recstep (default: all)
ENGINES="duckdb,umbra,flowlog,souffle,ddlog,recstep"

# Parse CLI args (flags) while keeping backward-compatible positional usage
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Usage: $0 [OPTIONS] [TIMEOUT_SECONDS] [THREAD_COUNT]"
            echo ""
            echo "Run database benchmarks with configurable timeout, thread count, and engine selection."
            echo ""
            echo "Options:"
            echo "  -t, --timeout SECONDS    Timeout for each query execution in seconds (default: 900)"
            echo "  -n, --threads N          Number of threads/workers to use (default: 64)"
            echo "  -e, --engines LIST       Comma-separated engines to run: duckdb,umbra,flowlog,souffle,ddlog,recstep (default: all)"
            echo "  -h, --help               Show this help message and exit"
            echo ""
            echo "Examples:"
            echo "  $0                      # Use defaults (15-minute timeout, 64 threads, all engines)"
            echo "  $0 -t 600 -n 32 -e duckdb,flowlog"
            echo "  $0 600 32               # Backward-compatible: timeout=600, threads=32"
            exit 0
            ;;
        -t|--timeout)
            TIMEOUT_SECONDS="$2"; shift 2;;
        -n|--threads)
            THREAD_COUNT="$2"; shift 2;;
        -e|--engines)
            ENGINES="$2"; shift 2;;
        --)
            shift; break;;
        -*|--*)
            echo "Unknown option: $1"; exit 1;;
        *)
            POSITIONAL+=("$1"); shift;;
    esac
done

# If positional args (legacy) provided, map them to timeout and threads
if [[ ${#POSITIONAL[@]} -ge 1 ]]; then
    if [[ "${POSITIONAL[0]}" =~ ^[0-9]+$ ]]; then
        TIMEOUT_SECONDS=${POSITIONAL[0]}
    fi
fi
if [[ ${#POSITIONAL[@]} -ge 2 ]]; then
    if [[ "${POSITIONAL[1]}" =~ ^[0-9]+$ ]]; then
        THREAD_COUNT=${POSITIONAL[1]}
    fi
fi

# Normalize engines string (lowercase, remove spaces)
ENGINES=$(echo "$ENGINES" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

# =============================================================================
# Configuration and Setup
# =============================================================================

CONFIG_FILE="./tool/config/benchmark.txt"
TEMP_SQL="tmp_sql"
DATASET_DIR="./dataset"
RESULT_FILE="./result/benchmark.txt"
TEMP_RESULT_FILE="/tmp/benchmark_result.tmp"

# Initialize directories and files
mkdir -p "$DATASET_DIR"
rm -rf "$RESULT_FILE"
mkdir -p "./log/benchmark/${THREAD_COUNT}"
mkdir -p "./result"

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

# Helper: check if an engine is selected in the ENGINES list
engine_selected() {
    local want="$1"
    [[ ",${ENGINES}," == *",${want},"* ]]
}
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
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
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
    FLOWLOG_DIR="$HOME/FlowLog"
    if [ ! -d "$FLOWLOG_DIR" ]; then
        echo "[ERROR] FlowLog directory not found at $FLOWLOG_DIR. Please run env.sh first."
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
        return
    fi
    pushd "$FLOWLOG_DIR" > /dev/null
    git checkout main
    git pull
    cargo build --release
    popd > /dev/null
    echo "FlowLog build completed"
    echo ""

    local base=$1
    local dataset=$2
    local prog_file="program/flowlog/${base}.dl"
    local fact_path="dataset/${dataset}"
    local flowlog_binary="$HOME/FlowLog/target/release/executing"
    if [ ! -x "$flowlog_binary" ]; then
        echo "  ERROR: FlowLog binary not found at $flowlog_binary. Please build FlowLog first."
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
        return
    fi
    local workers=$THREAD_COUNT
    
    echo "  Starting FlowLog benchmark: $base on $dataset"
    echo "  Using $workers workers"
    
    # Check if required files exist
    [[ ! -f "$prog_file" ]] && { 
        echo "  ERROR: Program file not found: $prog_file"
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
        return
    }
    
    [[ ! -d "$fact_path" ]] && { 
        echo "  ERROR: Dataset path not found: $fact_path"
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
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
    
    # Clean FlowLog build artifacts
    pushd "$HOME/FlowLog" > /dev/null
    cargo clean
    popd > /dev/null
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
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
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
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"; 
        return; 
    }
    [[ ! -d "$fact_path" ]] && { 
        echo "  ERROR: Dataset path not found: $fact_path"; 
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"; 
        return; 
    }

    # Compile Souffle program
    echo "  Compiling Souffle program..."
    if ! souffle -o "$bin" -p /dev/null "$dl_src" -j "$THREAD_COUNT" >/dev/null 2>&1; then
        echo "  ERROR: Souffle compilation failed"
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
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
# DDlog Benchmark Function
# -----------------------------------------------------------------------------
run_ddlog() {
    local base=$1
    local dataset=$2
    local ddlog_prog="program/ddlog/${base}.dl"
    local fact_path="dataset/${dataset}-${base}/data.ddin"
    local build_dir="${base}_ddlog"
    local exe="${build_dir}/target/release/${base}_cli"
    local rust_v=1.76

    echo "  Starting DDlog benchmark: $base on $dataset (${THREAD_COUNT} workers)"

    # Check if required files exist
    [[ ! -f "$ddlog_prog" ]] && { 
        echo "  ERROR: DDlog program file not found: $ddlog_prog"
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
        return
    }
    [[ ! -f "$fact_path" ]] && { 
        echo "  ERROR: Dataset file not found: $fact_path"
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
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
    local log_file="./log/benchmark/${THREAD_COUNT}/ddlog_${base}_${dataset}.log"
    echo "=== DDlog Execute Log for $base on $dataset (${THREAD_COUNT} workers) ===" > "$log_file"
    timeout "$TIMEOUT_SECONDS" "$exe" -w "$THREAD_COUNT" < "$fact_path" >> "$log_file" 2>&1 || echo "  WARNING: Logging execution failed or timed out"

    # Run timing executions
    echo "  Running timing executions..."
    local fastest_exec=""
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local temp_log="./log/benchmark/${THREAD_COUNT}/ddlog_${base}_${dataset}_${i}.log"
        local etime=""
        
        if timeout "$TIMEOUT_SECONDS" /usr/bin/time -f "LinuxRT: %e" "$exe" -w "$THREAD_COUNT" < "$fact_path" > "$temp_log" 2>&1; then
            # Extract execution time
            local exec_time=$(grep "LinuxRT:" "$temp_log" | tail -1 | awk '{print $2}')
            if [[ "$exec_time" =~ ^[0-9]+\.?[0-9]*$ ]]; then
                echo "      Completed in $exec_time seconds"
                etime="$exec_time"
            else
                echo "      Invalid or missing time, using timeout"
                etime="$TIMEOUT_SECONDS"
            fi
        else
            echo "      Timed out"
            etime="$TIMEOUT_SECONDS"
        fi
        
        # Track fastest execution time
        if [[ -n "$etime" && "$etime" != "$TIMEOUT_SECONDS" ]]; then
            if [[ -z "$fastest_exec" || $(echo "$etime < $fastest_exec" | bc -l) -eq 1 ]]; then
                fastest_exec="$etime"
            fi
        fi
        
        rm -f "$temp_log"
    done

    # Set fallback if no valid execution time was recorded
    if [[ -z "$fastest_exec" ]]; then
        fastest_exec="$TIMEOUT_SECONDS"
    fi

    # DDlog does not have a separate load phase, so set load_time to -1
    local load_time="-1"

    echo "  Fastest execution time: $fastest_exec seconds"

    # Clean up build directory
    rm -rf "${build_dir}" 2>/dev/null || true

    # Write results to temp file
    {
        echo "$load_time"
        echo "$fastest_exec"
    } > "$TEMP_RESULT_FILE"
    echo "  Results: load=$load_time exec=$fastest_exec"
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
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"; 
        return; 
    }
    [[ ! -d "$fact_path" ]] && { 
        echo "  ERROR: Dataset path not found: $fact_path"; 
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"; 
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
        {
            echo "-1"
            echo "-1"
        } > "$TEMP_RESULT_FILE"
        PATH="$OLD_PATH"
        return
    fi

    # one logging run of full program
    echo "  Running RecStep logging run..."
    echo "=== RecStep Execute Log for $base on $dataset ===" > "./log/benchmark/${THREAD_COUNT}/recstep_${base}_${dataset}.log"
    timeout "$TIMEOUT_SECONDS" recstep --program "$prog_file" --input "$fact_path" --jobs "$THREAD_COUNT" \
        >> "./log/benchmark/${THREAD_COUNT}/recstep_${base}_${dataset}.log" 2>&1 || echo "  WARNING: RecStep logging execution failed or timed out"

    # For RecStep we skip separate load timing: load time is treated as 0 and
    # we only time the full program runs (execution time = full run time).

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

    # Fallback on complete timeout
    if [[ -z "$fastest_total" ]]; then fastest_total="$TIMEOUT_SECONDS"; fi

    # For simplified RecStep reporting: load time = 0, exec time = fastest_total
    local out_load=0
    local out_exec="$fastest_total"

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

# Helper function to download and extract dataset
download_dataset() {
    local program=$1
    local dataset=$2
    local for_ddlog=$3
    
    local ZIP_URL
    local ZIP_PATH
    local DATASET_PATH
    
    if [[ "$for_ddlog" == "true" ]]; then
        # DDlog datasets extract to dataset/${dataset}-${program}/ directory
        DATASET_PATH="${DATASET_DIR}/${dataset}-${program}"
        local ZIP_FILENAME="${dataset}-${program}.zip"
        ZIP_PATH="/dev/shm/${ZIP_FILENAME}"
        
        # Try two possible URLs for DDlog datasets
        local URL1="https://pages.cs.wisc.edu/~hangdong/data/ddin/${ZIP_FILENAME}"
        local URL2="https://pages.cs.wisc.edu/~m0riarty/dataset/ddin/${ZIP_FILENAME}"
        local URL3="https://pages.cs.wisc.edu/~simonfrisk/${ZIP_FILENAME}"
        
    else
        # Other engines extract to dataset/${dataset}/ directory
        DATASET_PATH="${DATASET_DIR}/${dataset}"
        ZIP_URL="https://pages.cs.wisc.edu/~m0riarty/dataset/csv/${dataset}.zip"
        ZIP_PATH="/dev/shm/${dataset}.zip"
    fi
    
    # Download and extract dataset if needed
    if [[ -d "$DATASET_PATH" ]]; then
        echo "SKIP: Dataset already exists: $DATASET_PATH"
    else
        echo "PREP: Downloading and extracting dataset: $dataset (for_ddlog=$for_ddlog)"
        
        if [[ "$for_ddlog" == "true" ]]; then
            # Try three URLs for DDlog datasets
            echo "      Trying URL1: $URL1"
            if wget -O "$ZIP_PATH" "$URL1"; then
                echo "      Successfully downloaded from URL1"
                ZIP_URL="$URL1"  # For logging purposes
            else
                echo "      URL1 failed, trying URL2: $URL2"
                if wget -O "$ZIP_PATH" "$URL2"; then
                    echo "      Successfully downloaded from URL2"
                    ZIP_URL="$URL2"  # For logging purposes
                else
                    echo "      URL2 failed, trying URL3: $URL3"
                    if wget -O "$ZIP_PATH" "$URL3"; then
                        echo "      Successfully downloaded from URL3"
                        ZIP_URL="$URL3"  # For logging purposes
                    else
                        echo "      ERROR: All three URLs failed for DDlog dataset: $ZIP_FILENAME"
                        rm -f "$ZIP_PATH"  # Clean up partial download
                        return 1
                    fi
                fi
            fi
        else
            # Single URL for non-DDlog datasets
            echo "      URL: $ZIP_URL"
            if ! wget -O "$ZIP_PATH" "$ZIP_URL"; then
                echo "      ERROR: Failed to download dataset: $ZIP_URL"
                rm -f "$ZIP_PATH"  # Clean up partial download
                return 1
            fi
        fi
        
        echo "      Downloaded from: $ZIP_URL"
        unzip "$ZIP_PATH" -d "$DATASET_DIR"
        rm -f "$ZIP_PATH"  # Clean up zip immediately
    fi
}


# =============================================================================
# Main Benchmark Loop - Process each program-dataset pair completely
# =============================================================================

echo ""
echo "========================================"
echo "Processing program-dataset pairs"
echo "========================================"

while IFS='=' read -r program dataset; do
    [[ -z "$program" || "$program" =~ ^# ]] && continue

    echo ""
    echo "==============================================="
    echo "=== PROCESSING: $program on $dataset ==="
    echo "==============================================="
    
    # Initialize default values for all engines
    duck_load="-1"; duck_exec="-1"
    umbra_load="-1"; umbra_exec="-1"
    flowlog_load="-1"; flowlog_exec="-1"
    souffle_load="-1"; souffle_exec="-1"
    ddlog_load="-1"; ddlog_exec="-1"
    recstep_load="-1"; recstep_exec="-1"

    # Check if we need non-ddlog dataset
    need_regular_dataset=false
    if engine_selected duckdb || engine_selected umbra || engine_selected flowlog || engine_selected souffle || engine_selected recstep; then
        need_regular_dataset=true
    fi

    # Download and run non-ddlog engines
    if [[ "$need_regular_dataset" == "true" ]]; then
        echo ""
        echo "--- Downloading dataset for non-ddlog engines ---"
        download_dataset "$program" "$dataset" "false"
        
        # Run DuckDB benchmark (if requested)
        if engine_selected duckdb; then
            echo ""
            echo "--- DuckDB Benchmark ---"
            run_duckdb "$program" "$dataset"
            mapfile -t lines < "$TEMP_RESULT_FILE"
            duck_load="${lines[0]}"
            duck_exec="${lines[1]}"
            echo "DuckDB completed: load=$duck_load exec=$duck_exec"
        else
            echo "--- DuckDB skipped ---"
        fi

        # Run Umbra benchmark (if requested)
        if engine_selected umbra; then
            echo ""
            echo "--- Umbra Benchmark ---"
            run_umbra "$program" "$dataset"
            mapfile -t lines < "$TEMP_RESULT_FILE"
            umbra_load="${lines[0]}"
            umbra_exec="${lines[1]}"
            echo "Umbra completed: load=$umbra_load exec=$umbra_exec"
        else
            echo "--- Umbra skipped ---"
        fi

        # Run FlowLog benchmark (if requested)
        if engine_selected flowlog; then
            echo ""
            echo "--- FlowLog Benchmark ---"
            run_flowlog "$program" "$dataset"
            mapfile -t lines < "$TEMP_RESULT_FILE"
            flowlog_load="${lines[0]}"
            flowlog_exec="${lines[1]}"
            echo "FlowLog completed: load=$flowlog_load exec=$flowlog_exec"
        else
            echo "--- FlowLog skipped ---"
        fi

        # Run Souffle benchmark (if requested)
        if engine_selected souffle; then
            echo ""
            echo "--- Souffle Benchmark ---"
            run_souffle "$program" "$dataset"
            mapfile -t lines < "$TEMP_RESULT_FILE"
            souffle_load="${lines[0]}"
            souffle_exec="${lines[1]}"
            echo "Souffle completed: load=$souffle_load exec=$souffle_exec"
        else
            echo "--- Souffle skipped ---"
        fi

        # RecStep benchmark (if requested)
        if engine_selected recstep; then
            echo ""
            echo "--- RecStep Benchmark ---"
            run_recstep "$program" "$dataset"
            mapfile -t lines < "$TEMP_RESULT_FILE"
            recstep_load="${lines[0]}"
            recstep_exec="${lines[1]}"
            echo "RecStep completed: load=$recstep_load exec=$recstep_exec"
        else
            echo "--- RecStep skipped ---"
        fi
        
        # Cleanup regular dataset to save space
        echo ""
        echo "CLEANUP: Removing dataset: $dataset"
        rm -rf "${DATASET_DIR:?}/${dataset}"
    fi

    # Download and run ddlog engine
    if engine_selected ddlog; then
        echo ""
        echo "--- Downloading dataset for DDlog engine ---"
        # Strip version suffix (_v1, _v2, etc.) from program name for dataset download
        base_program="${program%_v*}"
        download_dataset "$base_program" "$dataset" "true"
        
        echo ""
        echo "--- DDlog Benchmark ---"
        run_ddlog "$program" "$dataset"
        mapfile -t lines < "$TEMP_RESULT_FILE"
        ddlog_load="${lines[0]}"
        ddlog_exec="${lines[1]}"
        echo "DDlog completed: load=$ddlog_load exec=$ddlog_exec"
        
        # Cleanup DDlog dataset to save space
        echo ""
        echo "CLEANUP: Removing DDlog dataset: ${dataset}-${base_program}"
        rm -rf "${DATASET_DIR:?}/${dataset}-${base_program}"
        rm -rf "${DATASET_DIR:?}/${dataset}"
    else
        echo "--- DDlog skipped ---"
    fi

    # Write results immediately to result file
    echo ""
    echo "--- Writing results for $program on $dataset ---"
    printf "%-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s\n" \
        "$program" "$dataset" "$duck_load" "$duck_exec" \
        "$umbra_load" "$umbra_exec" "$flowlog_load" "$flowlog_exec" \
        "$souffle_load" "$souffle_exec" "$ddlog_load" "$ddlog_exec" \
        "$recstep_load" "$recstep_exec" \
        >> "$RESULT_FILE"

    echo "Results written for $program on $dataset"
    
    # Show current complete results
    echo ""
    echo "=== CURRENT RESULTS ==="
    cat "$RESULT_FILE"
    echo ""
    echo "Completed: $program on $dataset"
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