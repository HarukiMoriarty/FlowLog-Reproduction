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
from typing import Dict, List, Tuple, Optional

def parse_scalability_file(filename: str) -> List[Tuple[str, str, int, Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float]]]:
    """
    Parse the scalability table file and return a list of tuples containing:
    (program, dataset, threads, duck_load, duck_exec, umbra_load, umbra_exec, flowlog_load, flowlog_exec, souffle_load, souffle_exec, ddlog_load, ddlog_exec, recstep_load, recstep_exec)
    Handle missing data by using None for missing values
    """
    results = []
    with open(filename, 'r') as f:
        lines = f.readlines()
    # Skip header and separator lines
    data_lines = [line.strip() for line in lines[2:] if line.strip() and not line.startswith('-')]
    for line in data_lines:
        parts = [part for part in line.split() if part]
        if len(parts) >= 5:
            program = parts[0]
            dataset = parts[1]
            threads = int(parts[2])
            duck_load = duck_exec = umbra_load = umbra_exec = flowlog_load = flowlog_exec = None
            souffle_load = souffle_exec = ddlog_load = ddlog_exec = recstep_load = recstep_exec = None
            try:
                if len(parts) >= 5:
                    duck_load = float(parts[3]) if parts[3] not in ['N/A', '-', 'NULL', ''] else None
                    duck_exec = float(parts[4]) if parts[4] not in ['N/A', '-', 'NULL', ''] else None
                if len(parts) >= 7:
                    umbra_load = float(parts[5]) if parts[5] not in ['N/A', '-', 'NULL', ''] else None
                    umbra_exec = float(parts[6]) if parts[6] not in ['N/A', '-', 'NULL', ''] else None
                if len(parts) >= 9:
                    flowlog_load = float(parts[7]) if parts[7] not in ['N/A', '-', 'NULL', ''] else None
                    flowlog_exec = float(parts[8]) if parts[8] not in ['N/A', '-', 'NULL', ''] else None
                if len(parts) >= 11:
                    souffle_load = float(parts[9]) if parts[9] not in ['N/A', '-', 'NULL', ''] else None
                    souffle_exec = float(parts[10]) if parts[10] not in ['N/A', '-', 'NULL', ''] else None
                if len(parts) >= 13:
                    ddlog_load = float(parts[11]) if parts[11] not in ['N/A', '-', 'NULL', ''] else None
                    ddlog_exec = float(parts[12]) if parts[12] not in ['N/A', '-', 'NULL', ''] else None
                if len(parts) >= 15:
                    recstep_load = float(parts[13]) if parts[13] not in ['N/A', '-', 'NULL', ''] else None
                    recstep_exec = float(parts[14]) if parts[14] not in ['N/A', '-', 'NULL', ''] else None
            except ValueError:
                continue
            results.append((program, dataset, threads, duck_load, duck_exec, umbra_load, umbra_exec, 
                          flowlog_load, flowlog_exec, souffle_load, souffle_exec, ddlog_load, ddlog_exec, recstep_load, recstep_exec))
    return results

def calculate_total_times(results: List[Tuple[str, str, int, Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float], Optional[float]]]):
    """
    Calculate total times and organize by program-dataset pairs
    Handle None values for missing systems
    """
    data = defaultdict(list)
    
    for program, dataset, threads, duck_load, duck_exec, umbra_load, umbra_exec, flowlog_load, flowlog_exec, souffle_load, souffle_exec, ddlog_load, ddlog_exec, recstep_load, recstep_exec in results:
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
            
        souffle_total = None
        if souffle_load is not None and souffle_exec is not None:
            souffle_total = souffle_load + souffle_exec
            
        ddlog_total = None
        if ddlog_load is not None and ddlog_exec is not None:
            ddlog_total = ddlog_load + ddlog_exec
        
        recstep_total = None
        if recstep_load is not None and recstep_exec is not None:
            recstep_total = recstep_load + recstep_exec
        key = (program, dataset)
        data[key].append({
            'threads': threads,
            'duck_total': duck_total,
            'umbra_total': umbra_total,
            'flowlog_total': flowlog_total,
            'souffle_total': souffle_total,
            'ddlog_total': ddlog_total,
            'recstep_total': recstep_total
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
                
            souffle_speedup = None
            if baseline['souffle_total'] is not None and entry['souffle_total'] is not None:
                souffle_speedup = baseline['souffle_total'] / entry['souffle_total']
                
            ddlog_speedup = None
            if baseline['ddlog_total'] is not None and entry['ddlog_total'] is not None:
                ddlog_speedup = baseline['ddlog_total'] / entry['ddlog_total']
            
            recstep_speedup = None
            if baseline.get('recstep_total') is not None and entry.get('recstep_total') is not None:
                recstep_speedup = baseline['recstep_total'] / entry['recstep_total']
            speedups.append({
                'threads': entry['threads'],
                'duck_speedup': duck_speedup,
                'umbra_speedup': umbra_speedup,
                'flowlog_speedup': flowlog_speedup,
                'souffle_speedup': souffle_speedup,
                'ddlog_speedup': ddlog_speedup,
                'recstep_speedup': recstep_speedup
            })
        
        speedup_data[(program, dataset)] = speedups
    
    return speedup_data

def print_speedup_table(speedup_data: Dict[Tuple[str, str], List[Dict]]):
    """
    Print the speedup results in a clean table format
    Handle None values by displaying N/A
    """
    print("SCALABILITY ANALYSIS - SPEEDUP RATIOS")
    print("="*100)
    
    for (program, dataset), speedups in sorted(speedup_data.items()):
        print(f"\n{program.upper()} + {dataset}")
        print("-" * 80)
        print(f"{'Threads':<8} {'DuckDB':<12} {'Umbra':<12} {'FlowLog':<12} {'Souffle':<12} {'DDlog':<12} {'RecStep':<12}")
        print("-" * 92)
        for entry in speedups:
            threads = entry['threads']
            duck_speedup = f"{entry['duck_speedup']:.2f}" if entry['duck_speedup'] is not None else "N/A"
            umbra_speedup = f"{entry['umbra_speedup']:.2f}" if entry['umbra_speedup'] is not None else "N/A"
            flowlog_speedup = f"{entry['flowlog_speedup']:.2f}" if entry['flowlog_speedup'] is not None else "N/A"
            souffle_speedup = f"{entry['souffle_speedup']:.2f}" if entry['souffle_speedup'] is not None else "N/A"
            ddlog_speedup = f"{entry['ddlog_speedup']:.2f}" if entry['ddlog_speedup'] is not None else "N/A"
            recstep_speedup = f"{entry['recstep_speedup']:.2f}" if entry['recstep_speedup'] is not None else "N/A"
            print(f"{threads:<8} {duck_speedup:<12} {umbra_speedup:<12} {flowlog_speedup:<12} {souffle_speedup:<12} {ddlog_speedup:<12} {recstep_speedup:<12}")

def print_summary_table(speedup_data: Dict[Tuple[str, str], List[Dict]]):
    """
    Print a summary table showing best speedups achieved
    Handle None values by displaying N/A
    """
    print("\n" + "="*100)
    print("SUMMARY - BEST SPEEDUPS ACHIEVED")
    print("="*100)
    print(f"{'Program':<15} {'Dataset':<20} {'DuckDB Best':<12} {'Umbra Best':<12} {'FlowLog Best':<12} {'Souffle Best':<12} {'DDlog Best':<12} {'RecStep Best':<12}")
    print("-" * 112)
    for (program, dataset), speedups in sorted(speedup_data.items()):
        duck_speedups = [entry['duck_speedup'] for entry in speedups if entry['duck_speedup'] is not None]
        umbra_speedups = [entry['umbra_speedup'] for entry in speedups if entry['umbra_speedup'] is not None]
        flowlog_speedups = [entry['flowlog_speedup'] for entry in speedups if entry['flowlog_speedup'] is not None]
        souffle_speedups = [entry['souffle_speedup'] for entry in speedups if entry['souffle_speedup'] is not None]
        ddlog_speedups = [entry['ddlog_speedup'] for entry in speedups if entry['ddlog_speedup'] is not None]
        recstep_speedups = [entry['recstep_speedup'] for entry in speedups if entry['recstep_speedup'] is not None]
        duck_best = f"{max(duck_speedups):.2f}" if duck_speedups else "N/A"
        umbra_best = f"{max(umbra_speedups):.2f}" if umbra_speedups else "N/A"
        flowlog_best = f"{max(flowlog_speedups):.2f}" if flowlog_speedups else "N/A"
        souffle_best = f"{max(souffle_speedups):.2f}" if souffle_speedups else "N/A"
        ddlog_best = f"{max(ddlog_speedups):.2f}" if ddlog_speedups else "N/A"
        recstep_best = f"{max(recstep_speedups):.2f}" if recstep_speedups else "N/A"
        print(f"{program:<15} {dataset:<20} {duck_best:<12} {umbra_best:<12} {flowlog_best:<12} {souffle_best:<12} {ddlog_best:<12} {recstep_best:<12}")

def main():
    """
    Main function to process the scalability benchmark results
    """
    filename = "/users/hangdong/Datalog-DB-benchmark/table/scalability.txt"
    
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