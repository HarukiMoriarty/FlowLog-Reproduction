#!/bin/bash

# Script to add weight 1 to each line in Arc.csv
# Converts format from "x,y" to "x,y,1"

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file> [output_file]"
    echo "Example: $0 orkut/Arc.csv orkut/Arc_weighted.csv"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.*}_weighted.csv}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

echo "Processing $INPUT_FILE..."
echo "Output will be written to $OUTPUT_FILE"

# Add weight 1 to each line
# This assumes the format is "x,y" and converts it to "x,y,1"
sed 's/$/,1/' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Done! Lines processed:"
wc -l "$INPUT_FILE" "$OUTPUT_FILE"

echo "Sample of first 5 lines from output:"
head -n 5 "$OUTPUT_FILE"
