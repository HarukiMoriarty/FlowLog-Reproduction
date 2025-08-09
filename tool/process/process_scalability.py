#!/usr/bin/env python3
"""
Script to process scalability benchmark results table.

This script:
1. Calculates total time for each system (Duck_Load + Duck_Exec, etc.)
2. Calculates speedup for each thread count relative to single-threaded performance
3. Outputs a clean table with speedup ratios
"""

import re
from collections import defaultdict
from typing import Dict, List, Tuple

def parse_scalability_file(filename: str) -> List[Tuple[str, str, int, float, float, float, float, float, float]]:
    """
    Parse the scalability table file and return a list of tuples containing:
    (program, dataset, threads, duck_load, duck_exec, umbra_load, umbra_exec, flowlog_load, flowlog_exec)
    Handle missing data by using None for missing values
    """
    results = []
    
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    # Skip header and separator lines
    data_lines = [line.strip() for line in lines[2:] if line.strip() and not line.startswith('-')]
    
    for line in data_lines:
        # Split by whitespace and filter out empty strings
        parts = [part for part in line.split() if part]
        
        if len(parts) >= 5:  # At least program, dataset, threads, and 2 time values
            program = parts[0]
            dataset = parts[1]
            threads = int(parts[2])
            
            # Initialize all values as None
            duck_load = duck_exec = umbra_load = umbra_exec = flowlog_load = flowlog_exec = None
            
            # Try to parse available columns, handling missing data gracefully
            try:
                if len(parts) >= 5:
                    duck_load = float(parts[3]) if parts[3] != 'N/A' and parts[3] != '-' else None
                    duck_exec = float(parts[4]) if parts[4] != 'N/A' and parts[4] != '-' else None
                if len(parts) >= 7:
                    umbra_load = float(parts[5]) if parts[5] != 'N/A' and parts[5] != '-' else None
                    umbra_exec = float(parts[6]) if parts[6] != 'N/A' and parts[6] != '-' else None
                if len(parts) >= 9:
                    flowlog_load = float(parts[7]) if parts[7] != 'N/A' and parts[7] != '-' else None
                    flowlog_exec = float(parts[8]) if parts[8] != 'N/A' and parts[8] != '-' else None
            except ValueError:
                continue  # Skip lines with invalid data
            
            results.append((program, dataset, threads, duck_load, duck_exec, 
                          umbra_load, umbra_exec, flowlog_load, flowlog_exec))
    
    return results

def calculate_total_times(results: List[Tuple[str, str, int, float, float, float, float, float, float]]):
    """
    Calculate total times and organize by program-dataset pairs
    Handle None values for missing systems
    """
    data = defaultdict(list)
    
    for program, dataset, threads, duck_load, duck_exec, umbra_load, umbra_exec, flowlog_load, flowlog_exec in results:
        # Calculate totals, handling None values
        duck_total = None
        if duck_load is not None and duck_exec is not None:
            duck_total = duck_load + duck_exec
            
        umbra_total = None
        if umbra_load is not None and umbra_exec is not None:
            umbra_total = umbra_load + umbra_exec
            
        flowlog_total = None
        if flowlog_load is not None and flowlog_exec is not None:
            flowlog_total = flowlog_load + flowlog_exec
        
        key = (program, dataset)
        data[key].append({
            'threads': threads,
            'duck_total': duck_total,
            'umbra_total': umbra_total,
            'flowlog_total': flowlog_total
        })
    
    # Sort by thread count for each program-dataset pair
    for key in data:
        data[key].sort(key=lambda x: x['threads'])
    
    return data

def calculate_speedups(data: Dict[Tuple[str, str], List[Dict]]):
    """
    Calculate speedup ratios relative to single-threaded performance
    Handle None values for missing systems
    """
    speedup_data = {}
    
    for (program, dataset), thread_data in data.items():
        # Find baseline (1 thread) performance
        baseline = None
        for entry in thread_data:
            if entry['threads'] == 1:
                baseline = entry
                break
        
        if baseline is None:
            continue
            
        speedups = []
        for entry in thread_data:
            # Calculate speedups, handling None values
            duck_speedup = None
            if baseline['duck_total'] is not None and entry['duck_total'] is not None:
                duck_speedup = baseline['duck_total'] / entry['duck_total']
                
            umbra_speedup = None
            if baseline['umbra_total'] is not None and entry['umbra_total'] is not None:
                umbra_speedup = baseline['umbra_total'] / entry['umbra_total']
                
            flowlog_speedup = None
            if baseline['flowlog_total'] is not None and entry['flowlog_total'] is not None:
                flowlog_speedup = baseline['flowlog_total'] / entry['flowlog_total']
            
            speedups.append({
                'threads': entry['threads'],
                'duck_speedup': duck_speedup,
                'umbra_speedup': umbra_speedup,
                'flowlog_speedup': flowlog_speedup
            })
        
        speedup_data[(program, dataset)] = speedups
    
    return speedup_data

def print_speedup_table(speedup_data: Dict[Tuple[str, str], List[Dict]]):
    """
    Print the speedup results in a clean table format
    Handle None values by displaying N/A
    """
    print("SCALABILITY ANALYSIS - SPEEDUP RATIOS")
    print("="*80)
    
    for (program, dataset), speedups in sorted(speedup_data.items()):
        print(f"\n{program.upper()} + {dataset}")
        print("-" * 60)
        print(f"{'Threads':<8} {'DuckDB':<12} {'Umbra':<12} {'FlowLog':<12}")
        print("-" * 60)
        
        for entry in speedups:
            threads = entry['threads']
            duck_speedup = f"{entry['duck_speedup']:.2f}" if entry['duck_speedup'] is not None else "N/A"
            umbra_speedup = f"{entry['umbra_speedup']:.2f}" if entry['umbra_speedup'] is not None else "N/A"
            flowlog_speedup = f"{entry['flowlog_speedup']:.2f}" if entry['flowlog_speedup'] is not None else "N/A"
            
            print(f"{threads:<8} {duck_speedup:<12} {umbra_speedup:<12} {flowlog_speedup:<12}")

def print_summary_table(speedup_data: Dict[Tuple[str, str], List[Dict]]):
    """
    Print a summary table showing best speedups achieved
    Handle None values by displaying N/A
    """
    print("\n" + "="*80)
    print("SUMMARY - BEST SPEEDUPS ACHIEVED")
    print("="*80)
    print(f"{'Program':<15} {'Dataset':<20} {'DuckDB Best':<12} {'Umbra Best':<12} {'FlowLog Best':<12}")
    print("-" * 80)
    
    for (program, dataset), speedups in sorted(speedup_data.items()):
        # Calculate best speedups, handling None values
        duck_speedups = [entry['duck_speedup'] for entry in speedups if entry['duck_speedup'] is not None]
        umbra_speedups = [entry['umbra_speedup'] for entry in speedups if entry['umbra_speedup'] is not None]
        flowlog_speedups = [entry['flowlog_speedup'] for entry in speedups if entry['flowlog_speedup'] is not None]
        
        duck_best = f"{max(duck_speedups):.2f}" if duck_speedups else "N/A"
        umbra_best = f"{max(umbra_speedups):.2f}" if umbra_speedups else "N/A"
        flowlog_best = f"{max(flowlog_speedups):.2f}" if flowlog_speedups else "N/A"
        
        print(f"{program:<15} {dataset:<20} {duck_best:<12} {umbra_best:<12} {flowlog_best:<12}")

def main():
    """
    Main function to process the scalability benchmark results
    """
    filename = "/users/hangdong/Datalog-DB-benchmark/scalability.txt"
    
    try:
        # Parse the table file
        results = parse_scalability_file(filename)
        
        # Calculate total times
        data = calculate_total_times(results)
        
        # Calculate speedups
        speedup_data = calculate_speedups(data)
        
        # Print detailed speedup table
        print_speedup_table(speedup_data)
        
        # Print summary
        print_summary_table(speedup_data)
        
    except FileNotFoundError:
        print(f"Error: File {filename} not found")
    except Exception as e:
        print(f"Error processing file: {e}")

if __name__ == "__main__":
    main()
