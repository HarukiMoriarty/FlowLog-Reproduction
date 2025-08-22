# FlowLog: Efficient and Extensible Datalog via Incrementality

This repository contains scripts to reproduce results for the paper “FlowLog: Efficient and Extensible Datalog via Incrementality.”

For now, this repository is scoped to paper reproduction. Start with the environment setup below, then run the reproduction steps for each table/figure.

## Recommended environment

- CloudLab Clem cluster, type 6525
- CPU: AMD EPYC 7543, 32-core processors (64 physical cores total), hyper-threading
- OS: Ubuntu 22.04
- Memory: 256 GiB

We highly recommend using the same or similar hardware/OS to match performance characteristics reported in the paper.

## Environment setup (Step 1)

Install prerequisites and toolchains. You can install everything at once (recommended), or select specific systems.

- Install all supported systems:
```bash
# syntax: env.sh [--all | --systems LIST]
./tool/experiment/env.sh --all
```

- Or install selected systems (comma-separated):
```bash
# syntax: env.sh --systems duckdb,flowlog,umbra,souffle,ddlog,recstep
./tool/experiment/env.sh --systems duckdb,flowlog,umbra,souffle,ddlog,recstep
```

Notes:
- You need sudo privileges; the script installs packages and configures Docker.
- After the script completes, re-login (or reboot) so docker group membership takes effect, and run: `source ~/.bashrc` to pick up PATH updates.

## Reproduce Table 1

Run the main benchmark (defaults: 900s timeout, 64 threads, all engines). You can override via flags.
```bash
# syntax: benchmark.sh [-t SECONDS] [-n THREADS] [-e ENGINES]
# ENGINES: duckdb,umbra,flowlog,souffle,recstep
./tool/experiment/benchmark.sh -t 900 -n 64 -e duckdb,umbra,flowlog,souffle,recstep
```

Configuration:
- Program/dataset pairs: `./tool/config/benchmark.txt` (one `program=dataset` per line, `#` for comments). The default file lists the pairs used for Table 1; add more if needed.

Results:
- Output table: `./result/benchmark.txt`
- For some engines, Load(s) and Exec(s) are reported separately; sum Load + Exec if you need a single total time.
- Logs: `./log/benchmark/<threads>/`

## Reproduce Figure 6

1) Ensure environment and datasets are prepared (same usage as Table 1):
```bash
# syntax: benchmark.sh [-t SECONDS] [-n THREADS]
./tool/experiment/benchmark.sh -t 900 -n 64
```

2) Plot stacked Exec+Load bars for selected programs:
```bash
# syntax: plot_stack.py --file FILE --programs P1 P2 ... --out OUT --threads N
python3 tool/plot/plot_stack.py --file table/stack_plot.txt \
  --programs SSSP Reach Bipartite Polonius CC Andersen \
  --out figure6.pdf --threads 64
```

Inputs and behavior:
- The plotting script reads a whitespace-separated file with Load/Exec columns for each engine (an example is provided at `table/stack_plot.txt`).
- Values `-1` are treated as unsupported; values `>= 900` seconds are treated as timeouts (annotated as TO).

Output:
- The figure is saved to `figure6.pdf` (or the path you pass via `--out`).
- Note: The camera-ready Figure 6 is typeset in LaTeX. The exact LaTeX figure source is not included; the script above is a helper to approximate the plot for reproduction.

## Reproduce Figure 7

1) Run system monitoring for selected programs/datasets using the provided config:
```bash
# syntax: monitor.sh [THREAD_COUNT]
./tool/experiment/monitor.sh 64
```
- Config file: `./tool/config/monitor.txt`
- Logs are produced per engine/program/dataset; collect/copy them into a single folder for plotting.

2) Plot CPU/Memory over time from the collected logs (use wildcard to include all logs in the folder):
```bash
# syntax: plot_live.py PATH/*.log
python3 tool/plot/plot_live.py ./table/live-plot/*.log
```

Notes:
- Filenames like `Program_Dataset_Threads_Engine.log` are expected (e.g., `Bipartite_netflix_4_flowlog.log`).
- `plot_live.py` requires LaTeX (`pdflatex`) and outputs `liveplot.png` and `liveplot.pgf`.
- Prepared example logs are under `./table/live-plot/`.

## Reproduce Figure 8

Run the scalability experiment across thread counts:
```bash
# syntax: scalability.sh
./tool/experiment/scalability.sh
```

Configuration:
- Program/dataset pairs: `./tool/config/scalability.txt`
- Thread counts are set inside the script via `THREAD_COUNTS=(...)`; edit as needed.

Results:
- Output table: `./scalability.txt`
- Logs: `./log/scalability/`

## Reproduce Figure 9

Use the variant benchmark to compare FlowLog and Soufflé variants:
```bash
# syntax: benchmark.sh [-t SECONDS] [-n THREADS] [-e ENGINES]
# Use variant.txt as configuration file for variant benchmarking
./tool/experiment/benchmark.sh -t 900 -n 64 -e flowlog,souffle
```

Configuration:
- Variants are listed in `./tool/config/variant.txt` as `program_variant=dataset`.
- For the paper, we provide variants for DOOP, DDISASM, and Galen. To obtain the original Figure 9 data, edit `variant.txt` to include all available variants for these three programs (e.g., `galen`, `galen_v1`, …) with their corresponding datasets.
- The benchmark script automatically detects and uses `variant.txt` when program names contain version suffixes (e.g., `_v1`, `_v2`).

Results:
- Output table: `./result/benchmark.txt`
- Logs: `./log/benchmark/<threads>/`

## Reproduce Table 2

Table 2 contains a small set of specific program variants that should be run manually with FlowLog. 

Instructions:
1. Refer to Table 2 in the paper to see the specific variants to run
2. Use the FlowLog executable directly (typically located in `../`)
3. Run each variant manually using the command below:

```bash
# Under FlowLog file folder, it is default in the ../
../target/release/executing -p <variant_program> -f <facts_path> -w 64
```

Where:
- `<variant_program>`: The specific variant program listed in Table 2
- `<facts_path>`: Path to the corresponding dataset facts file
- `-w 64`: Number of worker threads (adjust as needed)

