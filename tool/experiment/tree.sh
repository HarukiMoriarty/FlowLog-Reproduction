#!/bin/bash

# Usage: ./generate_tree.sh 15 > tree.csv

if [ -z "$1" ]; then
  echo "Usage: $0 <odd_number_of_nodes>"
  exit 1
fi

n=$1
if (( n % 2 == 0 )); then
  echo "Error: n must be an odd number to form a full binary tree."
  exit 1
fi

node_id=1  # Start from 1 (0 is root)
declare -a queue=(0)

while [ $node_id -lt $n ]; do
  parent=${queue[0]}
  queue=("${queue[@]:1}")  # dequeue

  # Create exactly 2 children if there’s enough room
  for i in 1 2; do
    if [ $node_id -ge $n ]; then
      break
    fi

    child=$node_id
    echo "${parent},${child}"
    queue+=($child)
    ((node_id++))
  done
done
