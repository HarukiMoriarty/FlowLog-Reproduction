#!/bin/bash
set -e

# =============================================================================
# FlowLog Variants Benchmark Script
# =============================================================================

# Thread count
THREAD_COUNT=${1:-64}

# Display usage if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [THREAD_COUNT]"
    echo ""
    echo "Run FlowLog benchmarks with configurable thread count."
    echo ""
    echo "Arguments:"
    echo "  THREAD_COUNT     Number of threads/workers to use (default: 64)"
    echo ""
    echo "Examples:"
    echo "  $0                # Use default 64 threads"
    echo "  $0 4              # Use 4 threads"
    exit 0
fi

# =============================================================================
# Configuration and Setup
# =============================================================================

CONFIG_FILE="./tool/config/variant_benchmark.txt"
DATASET_DIR="./dataset"
RESULT_FILE="variant.txt"
TEMP_RESULT_FILE="/tmp/benchmark_result.tmp"

# Initialize directories and files
mkdir -p "$DATASET_DIR"
rm -rf "$RESULT_FILE"
mkdir -p "./log/variant_benchmark/${THREAD_COUNT}"

echo "=== FlowLog Benchmark Configuration ==="
echo "Thread count: ${THREAD_COUNT}"
echo ""

echo "=== Building FlowLog ==="
cd FlowLog
git checkout nemo_aggregation
cargo build --release
cd ..
echo "FlowLog build completed"
echo ""

# Initialize result file with headers
if [[ ! -f "$RESULT_FILE" ]]; then
    printf "%-20s %-20s %-20s %-20s\n" \
        "Program" "Dataset" "FlowLog_Load(s)" "FlowLog_Exec(s)" \
        > "$RESULT_FILE"
    printf "%-20s %-20s %-20s %-20s\n" \
        "--------------------" "--------------------" "--------------------" "--------------------" \
        >> "$RESULT_FILE"
fi

# -----------------------------------------------------------------------------
# FlowLog Benchmark Function
# -----------------------------------------------------------------------------
run_flowlog() {
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
    local log_file="./log/variant_benchmark/${THREAD_COUNT}/flowlog_${base}_${dataset}.log"
    echo "=== FlowLog Execute Log for $base on $dataset ===" > "$log_file"
    RUST_LOG=info "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$workers" -O3 \
        >> "$log_file" 2>&1 || echo "  WARNING: Logging execution failed"
    
    # Run timing executions
    echo "  Running timing executions..."
    local fastest_load=""
    local fastest_exec=""
    
    for i in {1..3}; do
        echo "    Timing run $i/3"
        local temp_log="./log/variant_benchmark/${THREAD_COUNT}/flowlog_${base}_${dataset}_${i}.log"
        
        # Run FlowLog and capture output
        if RUST_LOG=info "$flowlog_binary" --program "$prog_file" --facts "$fact_path" --workers "$workers" -O3 \
            > "$temp_log" 2>&1; then
            echo "      Completed successfully"
        else
            echo "      Execution failed"
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
    
    # Run FlowLog benchmark
    echo ""
    echo "--- FlowLog Benchmark ---"
    run_flowlog "$program" "$dataset"
    mapfile -t lines < "$TEMP_RESULT_FILE"
    flowlog_load="${lines[0]}"
    flowlog_exec="${lines[1]}"
    echo "FlowLog completed: load=$flowlog_load exec=$flowlog_exec"

    # Write results to file
    printf "%-20s %-20s %-20s %-20s\n" \
        "$program" "$dataset" "$flowlog_load" "$flowlog_exec" \
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
rm -f "$TEMP_RESULT_FILE"

# Display final results
echo ""
echo "=============================================="
echo "           FINAL TIMING RESULTS"
echo "=============================================="
cat "$RESULT_FILE"