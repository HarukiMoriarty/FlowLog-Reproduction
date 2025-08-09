#!/usr/bin/env python3
"""
Script to format Umbra SSSP result file:
1. Convert space-separated format (e.g., "1072 6") to comma-separated ("1072,6")
2. Sort lines by the first column (node ID)
"""

import sys
from pathlib import Path

def format_umbra_result(input_file, output_file=None):
    """
    Format Umbra SSSP result file by converting spaces to commas and sorting by first column
    
    Args:
        input_file: Path to input result file
        output_file: Path to output CSV file (optional, defaults to input_file with _formatted suffix)
    """
    if output_file is None:
        input_path = Path(input_file)
        output_file = input_path.parent / f"{input_path.stem}_formatted{input_path.suffix}"
    
    # Read the result file
    rows = []
    
    with open(input_file, 'r') as f:
        # Skip empty lines and read data
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            # Split by whitespace and clean
            parts = line.split()
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
    
    # Write formatted CSV
    with open(output_file, 'w') as f:
        for node_id, distance in rows:
            f.write(f"{node_id},{distance}\n")
    
    print(f"Formatted {len(rows)} rows from {input_file}")
    print(f"Output written to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 format_umbra_result.py <input_file> [output_file]")
        print("Example: python3 format_umbra_result.py umbra_result.csv")
        print("Example: python3 format_umbra_result.py umbra_result.csv formatted_result.csv")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    if not Path(input_file).exists():
        print(f"Error: Input file {input_file} does not exist")
        sys.exit(1)
    
    format_umbra_result(input_file, output_file)