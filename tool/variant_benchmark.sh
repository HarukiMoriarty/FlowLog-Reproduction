#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

############################################################
# VARIANT BENCHMARK SCRIPT
# This script measures execution time for different variants
# of FlowLog programs with O3 optimization only
# 
# For each program family (e.g., tc.dl, tc_v1.dl), it runs
# all variants 3 times each, keeps the fastest time per variant,
# and calculates the median execution time across variants
# 
# Execution logs are saved to ./log/ directory
# Results include individual variant times (fastest of 3 runs) and medians
############################################################

############################################################
# CONFIGURATION
# Define paths and parameters for benchmark tests
############################################################

CONFIG_FILE="./tool/config/variant_benchmark.txt"     # Program/dataset pairs configuration
PROG_DIR="./program"                                    # Program files directory
FACT_DIR="./dataset"                                    # Dataset files directory
LOG_DIR="./log/variant_benchmark"                       # Log output directory
BINARY_PATH="./FlowLog/target/release/executing"        # Path to compiled binary
DEFAULT_WORKERS=64                                      # Default number of worker threads
OPTIMIZATION_FLAG="-O3"                                 # Only use O3 optimization

############################################################
# DATASET SETUP
# Functions to download, extract, and clean up datasets
############################################################

setup_dataset() {
    # Download and extract dataset if not already present
    local dataset_name="$1"
    local dataset_zip="/dev/shm/${dataset_name}.zip"
    local extract_path="${FACT_DIR}/${dataset_name}"
    local dataset_url="https://pages.cs.wisc.edu/~m0riarty/dataset/${dataset_name}.zip"

    # Check if dataset is already extracted
    if [ -d "$extract_path" ]; then
        echo "[OK] Dataset $dataset_name already extracted. Skipping."
        return
    fi

    mkdir -p "$FACT_DIR"

    # Download dataset if zip file doesn't exist
    if [ ! -f "$dataset_zip" ]; then
        echo "[DOWNLOAD] Downloading $dataset_name.zip from $dataset_url..."
        mkdir -p "$(dirname "$dataset_zip")"
        wget -O "$dataset_zip" "$dataset_url" || {
            echo "[ERROR] Failed to download dataset: $dataset_name"
            exit 1
        }
    fi

    # Extract the dataset
    echo "[EXTRACT] Extracting $dataset_name..."
    unzip -q "$dataset_zip" -d "$FACT_DIR"
    rm -f "$dataset_zip"  # Remove zip file after extraction
    echo "[OK] Dataset $dataset_name ready."
}

cleanup_dataset() {
    # Remove extracted dataset to save space
    local dataset_name="$1"
    local extract_path="${FACT_DIR}/${dataset_name}"

    echo "[CLEANUP] Removing dataset $dataset_name..."
    rm -rf "$extract_path"
}

############################################################
# BENCHMARK FUNCTIONS
# Functions to run benchmark tests and measure performance
############################################################

run_single_benchmark_test() {
    # Run a single benchmark test for a program/dataset combination (3 times, keep fastest)
    local prog_name="$1"
    local dataset_name="$2"

    # Set up program file paths
    local prog_file=$(basename "$prog_name")
    local prog_path="${PROG_DIR}/flowlog/${prog_file}"
    
    # Set up paths for benchmark test
    local fact_path="${FACT_DIR}/${dataset_name}"
    local program_stem="${prog_name%.*}"
    local log_file="${LOG_DIR}/${program_stem}_${dataset_name}_O3.log"

    echo "[BENCHMARK] Running $prog_name with $dataset_name (O3) - 3 runs, keeping fastest"

    # Ensure log directory exists
    mkdir -p "$LOG_DIR"

    local best_time=""
    local best_run=0
    local run_times=()

    # Run 3 times and keep the fastest
    for run in 1 2 3; do
        echo "[RUN $run/3] Benchmark test: $prog_name (O3)"
        local temp_log="${log_file}.run${run}"
        
        RUST_LOG=info "$BINARY_PATH" --program "$prog_path" --facts "$fact_path" --workers "$WORKERS" "$OPTIMIZATION_FLAG" > "$temp_log" 2>&1

        local exit_code=$?

        if [ $exit_code -ne 0 ]; then
            echo "[ERROR] Run $run failed with exit code $exit_code: $prog_name"
            echo "ERROR: Run $run failed with exit code $exit_code" > "$temp_log"
            run_times+=("ERROR")
        else
            # Extract time from this run
            local run_time=$(extract_time_from_temp_log "$temp_log")
            run_times+=("$run_time")
            
            if [[ "$run_time" =~ ^[0-9]+\.[0-9]+$ ]]; then
                if [ -z "$best_time" ] || (( $(echo "$run_time < $best_time" | bc -l) )); then
                    best_time="$run_time"
                    best_run=$run
                fi
            fi
            echo "[RUN $run/3] Completed in ${run_time}s"
        fi
        
        sleep 1 # Brief pause between runs
    done

    # Copy the best run to the final log file
    if [ $best_run -gt 0 ]; then
        cp "${log_file}.run${best_run}" "$log_file"
        echo "[BEST] Run $best_run was fastest (${best_time}s) for $prog_name"
    else
        # All runs failed, copy the first run's log
        cp "${log_file}.run1" "$log_file"
        echo "[ERROR] All runs failed for $prog_name"
    fi

    # Clean up temporary log files
    rm -f "${log_file}".run*

    echo "[BENCHMARK] Completed $prog_name (best: ${best_time:-ERROR}s)"
}

get_program_base_name() {
    # Extract base program name (e.g., "tc" from "tc.dl" or "tc_v1.dl")
    local prog_name="$1"
    local base_name="${prog_name%.*}"  # Remove .dl extension
    
    # Remove version suffix if present (e.g., _v1, _v2, etc.)
    echo "$base_name" | sed 's/_v[0-9]\+$//'
}

group_programs_by_base() {
    # Group programs by their base name AND dataset, return unique program-dataset variant groups
    declare -A program_groups
    declare -A datasets_for_program
    
    # Read config file and group by base program name AND dataset
    while IFS='=' read -r prog_name dataset_name; do
        # Skip empty lines and comment lines starting with #
        if [ -z "$prog_name" ] || [ -z "$dataset_name" ] || [[ "$prog_name" =~ ^#.* ]]; then
            continue
        fi
        
        local base_name=$(get_program_base_name "$prog_name")
        # Key is base_program + dataset combination
        local key="${base_name}_${dataset_name}"
        
        # Add this variant to the group
        if [ -z "${program_groups[$key]}" ]; then
            program_groups["$key"]="$prog_name"
            datasets_for_program["$key"]="$dataset_name"
        else
            program_groups["$key"]="${program_groups[$key]} $prog_name"
        fi
    done < "$CONFIG_FILE"
    
    # Output the grouped results
    for key in "${!program_groups[@]}"; do
        echo "$key|${program_groups[$key]}|${datasets_for_program[$key]}"
    done
}

run_all_benchmark_tests() {
    # Run benchmark tests for all program variants
    echo "[BENCHMARK] Running variant benchmark tests..."

    # Clean previous logs
    rm -rf "$LOG_DIR"
    mkdir -p "$LOG_DIR"

    # Group programs and run tests
    group_programs_by_base | while IFS='|' read -r key variants dataset_name; do
        local base_name="${key%_*}"
        
        echo "[PROGRAM GROUP] Benchmarking $base_name variants with $dataset_name"
        echo "Variants: $variants"
        echo "========================================"

        # Setup dataset once for all variants
        setup_dataset "$dataset_name"

        # Run tests for all variants in this group
        for variant in $variants; do
            run_single_benchmark_test "$variant" "$dataset_name"
            sleep 2 # Brief pause between tests
        done

        # Cleanup dataset after all variant tests
        cleanup_dataset "$dataset_name"
    done

    echo "[OK] All benchmark tests completed!"
}

############################################################
# TIMING EXTRACTION FUNCTIONS
# Functions to extract timing information from log files
############################################################

extract_time_from_temp_log() {
    # Extract timing information from temporary log file (used during multiple runs)
    local log_file="$1"
    
    if [ ! -f "$log_file" ]; then
        echo "N/A"
        return
    fi
    
    # Look for the "Dataflow executed" line and extract the duration
    local time_line=$(grep "Dataflow executed" "$log_file" 2>/dev/null | tail -1)
    
    if [ -z "$time_line" ]; then
        echo "N/A"
        return
    fi
    
    # Extract time value using grep and sed
    local extracted_time=$(echo "$time_line" | grep -oE '[0-9]+\.[0-9]+s:' | sed 's/s://' 2>/dev/null || echo "N/A")
    echo "$extracted_time"
}

extract_time_from_log() {
    # Extract timing information from log file by parsing "Dataflow executed" line
    local log_file="$1"
    
    if [ ! -f "$log_file" ]; then
        echo "N/A"
        return
    fi
    
    # Check for timeout or error messages first
    if grep -q "TIMEOUT:" "$log_file" 2>/dev/null; then
        echo "TIMEOUT"
        return
    fi
    
    if grep -q "ERROR:" "$log_file" 2>/dev/null; then
        echo "ERROR"
        return
    fi
    
    # Look for the "Dataflow executed" line and extract the duration
    local time_line=$(grep "Dataflow executed" "$log_file" 2>/dev/null | tail -1)
    
    if [ -z "$time_line" ]; then
        echo "N/A"
        return
    fi
    
    # Extract time value using grep and sed
    local extracted_time=$(echo "$time_line" | grep -oE '[0-9]+\.[0-9]+s:' | sed 's/s://' 2>/dev/null || echo "N/A")
    echo "$extracted_time"
}

calculate_median_time() {
    # Calculate median time for a list of time values
    local times=("$@")
    local valid_times=()
    
    # Filter valid numeric times
    for time in "${times[@]}"; do
        if [[ "$time" =~ ^[0-9]+\.[0-9]+$ ]]; then
            valid_times+=("$time")
        fi
    done
    
    local count=${#valid_times[@]}
    
    if [ $count -eq 0 ]; then
        echo "N/A"
        return
    fi
    
    # Sort the times using sort command
    local sorted_times=($(printf '%s\n' "${valid_times[@]}" | sort -n))
    
    if [ $((count % 2)) -eq 1 ]; then
        # Odd number of elements, take the middle one
        local middle_index=$((count / 2))
        echo "${sorted_times[$middle_index]}"
    else
        # Even number of elements, take average of two middle elements
        local middle1_index=$((count / 2 - 1))
        local middle2_index=$((count / 2))
        local median=$(echo "scale=6; (${sorted_times[$middle1_index]} + ${sorted_times[$middle2_index]}) / 2" | bc -l)
        echo "$median"
    fi
}

############################################################
# RESULT GENERATION FUNCTIONS
# Functions to generate benchmark results table and CSV
############################################################

generate_benchmark_table() {
    # Generate and display a formatted table of benchmark results
    echo ""
    echo "============================"
    echo "[SUMMARY] Variant Benchmark Results"
    echo "============================"

    # Group programs and display results
    group_programs_by_base | while IFS='|' read -r key variants dataset_name; do
        local base_name="${key%_*}"
        
        echo ""
        echo "Program: $base_name, Dataset: $dataset_name"
        echo "----------------------------------------"
        printf "| %-25s | %-17s |\n" "Variant" "Time (seconds)"
        printf "|---------------------------|-------------------|\n"
        
        local times=()
        
        # Display timing for each variant
        for variant in $variants; do
            local variant_stem="${variant%.*}"
            local log_file="${LOG_DIR}/${variant_stem}_${dataset_name}_O3.log"
            local elapsed_time=$(extract_time_from_log "$log_file")
            
            printf "| %-25s " "$variant_stem"
            if [[ "$elapsed_time" =~ ^[0-9] ]]; then
                printf "| %17.6f |\n" "$elapsed_time"
                times+=("$elapsed_time")
            else
                printf "| %-17s |\n" "$elapsed_time"
            fi
        done
        
        # Calculate and display median
        local median=$(calculate_median_time "${times[@]}")
        printf "|---------------------------|-------------------|\n"
        printf "| %-25s " "MEDIAN"
        if [[ "$median" =~ ^[0-9] ]]; then
            printf "| %17.6f |\n" "$median"
        else
            printf "| %-17s |\n" "$median"
        fi
        
        echo ""
    done
}

generate_benchmark_csv() {
    # Generate CSV file with benchmark results for analysis
    echo ""
    echo "[CSV] Generating benchmark CSV file..."

    local csv_file="${LOG_DIR}/variant_benchmark_results.csv"

    # Write CSV header
    echo "Program_Base,Dataset,Variant,Time_Seconds" > "$csv_file"

    # Group programs and write data
    group_programs_by_base | while IFS='|' read -r key variants dataset_name; do
        local base_name="${key%_*}"
        local times=()
        
        # Write data for each variant
        for variant in $variants; do
            local variant_stem="${variant%.*}"
            local log_file="${LOG_DIR}/${variant_stem}_${dataset_name}_O3.log"
            local elapsed_time=$(extract_time_from_log "$log_file")
            
            echo "$base_name,$dataset_name,$variant_stem,$elapsed_time" >> "$csv_file"
            
            if [[ "$elapsed_time" =~ ^[0-9] ]]; then
                times+=("$elapsed_time")
            fi
        done
        
        # Write median
        local median=$(calculate_median_time "${times[@]}")
        echo "$base_name,$dataset_name,MEDIAN,$median" >> "$csv_file"
    done

    echo "[CSV] Benchmark results saved to: $csv_file"
}

############################################################
# USAGE AND PARAMETER HANDLING
# Functions to handle command line arguments and display usage
############################################################

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -t, --threads NUM    Number of worker threads (default: $DEFAULT_WORKERS)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                   # Run with default $DEFAULT_WORKERS threads"
    echo "  $0 -t 32            # Run with 32 threads"
    echo "  $0 --threads 128    # Run with 128 threads"
}

parse_arguments() {
    # Set default values
    WORKERS="$DEFAULT_WORKERS"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--threads)
                if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                    WORKERS="$2"
                    shift 2
                else
                    echo "[ERROR] Invalid thread number: $2"
                    show_usage
                    exit 1
                fi
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "[ERROR] Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    echo "[CONFIG] Using $WORKERS worker threads"
}

############################################################
# MAIN EXECUTION
# Entry point for the script
############################################################

main() {
    # Parse command line arguments
    parse_arguments "$@"

    # Print start message
    echo "[START] FlowLog Variant Benchmark Test"

    echo "=== SETUP COMPLETE ==="

    # Check if bc is available for calculations
    if ! command -v bc &> /dev/null; then
        echo "[ERROR] bc (basic calculator) is required but not installed."
        echo "Please install bc: sudo apt-get install bc"
        exit 1
    fi

    # Build the Rust binary
    echo "[BUILD] Building the project..."
    cd FlowLog
    git pull && git checkout nemo_arithmetic
    cargo clean && cargo build --release
    cd ..

    # Run all benchmark tests
    run_all_benchmark_tests

    # Generate results in table and CSV format
    generate_benchmark_table
    generate_benchmark_csv

    # Print finish message
    echo "[FINISH] All variant benchmark tests completed successfully."
}

# Call main function with all script arguments
main "$@"
