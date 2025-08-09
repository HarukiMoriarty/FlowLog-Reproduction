#!/usr/bin/env python3
"""
Script to process variant benchmark results table.

This script:
1. Calculates total time for each row (FlowLog_Load + FlowLog_Exec)
2. Groups results by program-dataset variant pairs
3. Finds the median time for each variant group
"""

import re
import statistics
from collections import defaultdict
from typing import Dict, List, Tuple

def parse_table_file(filename: str) -> List[Tuple[str, str, float, float, float]]:
    """
    Parse the table file and return a list of tuples containing:
    (program, dataset, load_time, exec_time, total_time)
    """
    results = []
    
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    # Skip header and separator lines
    data_lines = [line.strip() for line in lines[2:] if line.strip() and not line.startswith('-')]
    
    for line in data_lines:
        # Split by whitespace and filter out empty strings
        parts = [part for part in line.split() if part]
        
        if len(parts) >= 4:
            program = parts[0]
            dataset = parts[1]
            load_time = float(parts[2])
            exec_time = float(parts[3])
            total_time = load_time + exec_time
            
            results.append((program, dataset, load_time, exec_time, total_time))
    
    return results

def extract_base_program(program: str) -> str:
    """
    Extract the base program name by removing version suffixes (_v1, _v2, etc.)
    """
    # Remove version suffixes like _v1, _v2, _v3, _v4
    base_program = re.sub(r'_v\d+$', '', program)
    return base_program

def group_by_variants(results: List[Tuple[str, str, float, float, float]]) -> Dict[Tuple[str, str], List[float]]:
    """
    Group results by (base_program, dataset) pairs and collect total times
    """
    variant_groups = defaultdict(list)
    
    for program, dataset, load_time, exec_time, total_time in results:
        base_program = extract_base_program(program)
        key = (base_program, dataset)
        variant_groups[key].append(total_time)
    
    return dict(variant_groups)

def calculate_medians(variant_groups: Dict[Tuple[str, str], List[float]]) -> Dict[Tuple[str, str], float]:
    """
    Calculate median time for each variant group
    """
    medians = {}
    
    for (base_program, dataset), times in variant_groups.items():
        median_time = statistics.median(times)
        medians[(base_program, dataset)] = median_time
    
    return medians

def print_median_table(variant_groups: Dict[Tuple[str, str], List[float]], 
                       medians: Dict[Tuple[str, str], float]):
    """
    Print only the median results table
    """
    print("VARIANT GROUPS - MEDIAN TIMES")
    print("="*70)
    print(f"{'Base Program':<20} {'Dataset':<20} {'Variants':<10} {'Median Time(s)':<15}")
    print("-" * 70)
    
    # Sort by base program and dataset for better readability
    sorted_medians = sorted(medians.items(), key=lambda x: (x[0][0], x[0][1]))
    
    for (base_program, dataset), median_time in sorted_medians:
        variant_count = len(variant_groups[(base_program, dataset)])
        print(f"{base_program:<20} {dataset:<20} {variant_count:<10} {median_time:<15.4f}")

def main():
    """
    Main function to process the variant benchmark results
    """
    filename = "/users/hangdong/Datalog-DB-benchmark/table/variant_thread_64.txt"
    
    try:
        # Parse the table file
        results = parse_table_file(filename)
        
        # Group by variant pairs
        variant_groups = group_by_variants(results)
        
        # Calculate medians
        medians = calculate_medians(variant_groups)
        
        # Print only the median table
        print_median_table(variant_groups, medians)
        
    except FileNotFoundError:
        print(f"Error: File {filename} not found")
    except Exception as e:
        print(f"Error processing file: {e}")

if __name__ == "__main__":
    main()
