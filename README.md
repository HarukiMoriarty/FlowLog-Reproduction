# Datalog-DB Benchmark

Benchmarks FlowLog vs DuckDB vs Umbra.

## Quick Start

1. Setup environment:
```bash
./tool/env.sh
```
Installs DuckDB, Docker, Rust, pulls Umbra image, and shows FlowLog submodule setup.

2. Run benchmarks:
```bash
./tool/benchmark.sh
```
Downloads datasets, runs all systems, outputs timing table to `result.txt`.

## Configuration

- `tool/config.txt`: Which programs/datasets to run (comment with `#`)
- `program/duck/`: DuckDB SQL files
- `program/umbra/`: Umbra SQL files  
- `program/flowlog/`: FlowLog Datalog files

## How it works

The benchmark script:
1. Downloads datasets from hardcoded URLs
2. For each program+dataset: runs DuckDB CLI, Umbra Docker, FlowLog binary
3. Extracts timing from command output and logs
4. Runs each 3 times, takes fastest time
5. Outputs formatted table

## Modifying

- **Add new query**: Create SQL/Datalog files in all 3 `program/` dirs, add to `config.txt`
- **Change datasets**: Add new ones to `config.txt`
- **Fix timing issues**: Check `log/` files, FlowLog timing extracted from "Dataflow executed" logs
