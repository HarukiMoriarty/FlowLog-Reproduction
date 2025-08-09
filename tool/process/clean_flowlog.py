#!/usr/bin/env python3
"""
Script to clean up flowlog result CSV file:
1. Remove spaces around commas (e.g., "33, 6" -> "33,6")
2. Sort lines by the first column (node ID)
"""

import csv
import sys
from pathlib import Path

def clean_sssp_csv(input_file, output_file=None):
    """
    Clean up SSSP CSV file by removing spaces and sorting by first column
    
    Args:
        input_file: Path to input CSV file
        output_file: Path to output CSV file (optional, defaults to input_file)
    """
    if output_file is None:
        output_file = input_file
    
    # Read the CSV file
    rows = []
    
    with open(input_file, 'r') as f:
        # Skip empty lines and read data
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            # Remove spaces around comma and split
            parts = [part.strip() for part in line.split(',')]
            if len(parts) >= 2:
                try:
                    # Convert first column to int for proper sorting
                    node_id = int(parts[0])
                    distance = parts[1]
                    rows.append((node_id, distance))
                except ValueError:
                    # Skip lines that don't have valid integers
                    print(f"Skipping invalid line: {line}")
                    continue
    
    # Sort by first column (node ID)
    rows.sort(key=lambda x: x[0])
    
    # Write cleaned CSV
    with open(output_file, 'w') as f:
        for node_id, distance in rows:
            f.write(f"{node_id},{distance}\n")
    
    print(f"Cleaned {len(rows)} rows from {input_file}")
    if output_file != input_file:
        print(f"Output written to {output_file}")
    else:
        print(f"File updated in place")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 clean_sssp.py <input_csv> [output_csv]")
        print("Example: python3 clean_sssp.py sssp.csv")
        print("Example: python3 clean_sssp.py sssp.csv sssp_cleaned.csv")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else input_file
    
    if not Path(input_file).exists():
        print(f"Error: Input file {input_file} does not exist")
        sys.exit(1)
    
    clean_sssp_csv(input_file, output_file)
