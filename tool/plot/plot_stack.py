#!/usr/bin/env python3
"""Plot stacked load+exec times for engines for four programs.

Reads `table/stack_plot.txt` (whitespace-separated with multi-space separators).
Creates a 2x2 figure (one subfigure per program) showing stacked bars for
each engine (Load on bottom, Exec on top). Handles -1 / '-' as missing and
treats values >= 900 as timeouts (annotated).

Usage: python3 scripts/plot_stack.py --programs sssp reach bipartite borrow
"""

import argparse
from pathlib import Path
import re
import math
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker


def read_table(path: Path) -> pd.DataFrame:
    # Read file and split columns by 2+ spaces to keep dataset/program names intact
    with path.open() as f:
        lines = [l.rstrip('\n') for l in f.readlines() if l.strip()]

    # First non-separator line is header
    header = lines[0]
    # Split header by 2+ spaces
    cols = re.split(r"\s{2,}", header.strip())

    data = []
    for line in lines[1:]:
        # skip the dashed separator line if present
        if set(line.strip()) <= set('- '):
            continue
        parts = re.split(r"\s{2,}", line.strip())
        # If the row has fewer parts than header, pad
        if len(parts) < len(cols):
            parts += [''] * (len(cols) - len(parts))
        data.append(parts[: len(cols)])

    df = pd.DataFrame(data, columns=cols)

    # Convert numeric columns to float where possible; replace '-' and '' with NaN
    for c in df.columns[2:]:
        df[c] = df[c].replace({'-': None, '': None}).apply(lambda x: None if x is None else x)
        def to_num(v):
            try:
                return float(v)
            except Exception:
                return float('nan')

        df[c] = df[c].apply(to_num)

    return df


# engine display name and token to search for in column headers (search is substring, case-insensitive)
ENGINES = [
    ('FlowLog', 'flowlog'),
    ('Souffle', 'souffle'),
    ('RecStep', 'recstep'),
    ('DDlog', 'ddlog'),
    ('Umbra', 'umbra'),
    ('DuckDB', 'duck'),
]


def find_cols_for_engine_cols(columns, token: str):
    # Find columns containing token and containing Load or Exec (case-insensitive substring match)
    load_col = None
    exec_col = None
    for c in columns:
        lc = c.lower()
        if token in lc and 'load' in lc:
            load_col = c
        if token in lc and 'exec' in lc:
            exec_col = c
    return load_col, exec_col


def plot_for_program(ax, row, program_name, threads: int):
    engines = []
    loads = []
    execs = []
    timeouts = []
    unsupported = []

    for display, token in ENGINES:
        # find matching column names in the row index using token substring
        load_col, exec_col = find_cols_for_engine_cols(row.index, token)

        engines.append(display)
        l = float(row[load_col]) if load_col and not math.isnan(row[load_col]) else float('nan')
        e = float(row[exec_col]) if exec_col and not math.isnan(row[exec_col]) else float('nan')
        # treat -1 as unsupported/missing
        was_l_minus1 = (not math.isnan(l) and l == -1.0)
        was_e_minus1 = (not math.isnan(e) and e == -1.0)
        if was_l_minus1:
            l = float('nan')
        if was_e_minus1:
            e = float('nan')
        if was_l_minus1 and was_e_minus1:
            unsupported.append(display)
        # treat -1 and NaN as missing (we already converted - to NaN). treat >=900 as timeout
        if not math.isnan(l) and l >= 900:
            l = float('nan')
            timeouts.append(display)
        if not math.isnan(e) and e >= 900:
            e = float('nan')
            if display not in timeouts:
                timeouts.append(display)

        loads.append(0.0 if math.isnan(l) else l)
        execs.append(0.0 if math.isnan(e) else e)

    # Plot Exec as the bottom bar, and Load stacked on top
    ind = list(range(len(engines)))
    # Draw Exec (orange) and Load (blue) as original
    ax.bar(ind, execs, label='Execution', color='#fd8d3c')
    ax.bar(ind, loads, bottom=execs, label='Load', color='#6baed6')
    # set y-limit and tick locator before annotations so annotations can use the plot max
    raw_max = max(1, max([a + b for a, b in zip(loads, execs)])) * 1.15
    # compute a 'nice' tick step so labels aren't too dense (target ~4 ticks)
    def nice_step(ymax, target_ticks=4):
        raw = float(ymax) / float(target_ticks)
        # prefer steps like 1,2,5 * 10^k
        bases = [1, 2, 5]
        scale = 1
        while True:
            for b in bases:
                step = b * scale
                if step >= raw:
                    return step
            scale *= 10

    step = nice_step(raw_max, target_ticks=4)
    top = math.ceil(raw_max / step) * step
    ax.set_ylim(0, top)
    ax.yaxis.set_major_locator(ticker.MultipleLocator(step))

    # Annotate timeouts
    for i, eng in enumerate(engines):
        if eng in timeouts:
            # place TO above the stack rendered in monospace (\texttt{TO})
            top = loads[i] + execs[i]
            ax.text(i, top + max(0.1, top*0.02), 'TO', ha='center', va='bottom', color='black', fontweight='bold', fontfamily='monospace')
        if eng in unsupported:
            # draw a thick dark-red cross (similar to \thickcross) near the bottom of the axis
            # center coordinates
            xpos = i
            # place the cross at a fixed rate of the plot's y-max so it scales with figure
            # use 12% of the plot top
            ypos = (top * 0.07) if 'top' in locals() else 0.8
            # cross size in axis data units (horizontal span)
            dx = 0.18
            dy = 0.18
            cr = '#990000'  # ~ red!60!black
            # draw an elegant heavy cross glyph (Unicode) centered at the position
            # use a single glyph so it scales/looks consistent across axes
            ax.text(xpos, ypos, '✖', ha='center', va='center', color=cr, fontsize=18, fontweight='bold', zorder=11)

    ax.set_xticks(ind)
    ax.set_xticklabels(engines, rotation=25, fontsize=10)
    dataset = row['Dataset'] if 'Dataset' in row.index else ''
    # shorten dataset name (e.g. 'arabic-sssp' -> 'arabic') and format title as: SSSP (arabic), 64 threads
    dataset_short = dataset.split('-')[0] if dataset else dataset
    # use shorter title and smaller font
    ax.set_title(f"{program_name} ({dataset_short})", fontsize=10)
    # set y-limit to slightly above max stack
    raw_max = max(1, max([a + b for a, b in zip(loads, execs)])) * 1.15
    # compute a 'nice' tick step so labels aren't too dense (target ~4 ticks)
    def nice_step(ymax, target_ticks=4):
        raw = float(ymax) / float(target_ticks)
        # prefer steps like 1,2,5 * 10^k
        bases = [1, 2, 5]
        scale = 1
        while True:
            for b in bases:
                step = b * scale
                if step >= raw:
                    return step
            scale *= 10

    step = nice_step(raw_max, target_ticks=4)
    top = math.ceil(raw_max / step) * step
    ax.set_ylim(0, top)
    ax.yaxis.set_major_locator(ticker.MultipleLocator(step))

    # Annotate exec times: always black, placed just above the exec stack
    for i, e in enumerate(execs):
        try:
            val = float(e)
        except Exception:
            continue
        if val > 0:
            # format: integer if whole, otherwise one decimal
            if float(val).is_integer():
                s = str(int(round(val)))
            else:
                s = f"{val:.1f}"
            # position just above the exec segment; small offset to separate from bar
            offset = max(0.02 * top, 0.1)
            ypos = val + offset
            ax.text(i, ypos, s, ha='center', va='bottom', color='black', fontweight='bold', fontsize='small', zorder=10)

    # load-time annotations removed: only exec-time numbers are shown above exec stacks


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--file', default='table/stack_plot.txt', help='path to stack_plot.txt')
    parser.add_argument('--programs', nargs='*', metavar='PROG', required=False,
                        help='up to six program names to plot (exact match in Program column). If omitted, defaults will be used')
    parser.add_argument('--out', default='stack_plot.png', help='output image path')
    parser.add_argument('--threads', type=int, default=64, help='number of threads (used in subplot titles)')
    args = parser.parse_args()

    df = read_table(Path(args.file))

    if not args.programs:
        # pick first six programs in file as default
        progs = list(df['Program'].iloc[:6])
    else:
        progs = args.programs

    if len(progs) < 1 or len(progs) > 6:
        raise SystemExit('Please provide between 1 and 6 program names')

    # force a 3x2 layout (leave empty subplots if fewer than 6 programs)
    nrows, ncols = 3, 2

    # make the figure flatter: slightly wider per column and much shorter per row
    fig, axes = plt.subplots(nrows, ncols, figsize=(3.5 * ncols, 1.8 * nrows), constrained_layout=True)
    # flatten axes into list for easy iteration
    if isinstance(axes, plt.Axes):
        axes = [axes]
    else:
        axes = list(axes.flatten())

    for ax, prog in zip(axes, progs):
        # find matching row
        matches = df[df['Program'] == prog]
        if matches.empty:
            ax.text(0.5, 0.5, f'Program "{prog}" not found', ha='center')
            ax.set_axis_off()
            continue
        row = matches.iloc[0]
        plot_for_program(ax, row, prog, args.threads)
        # Move the Exec/Load legend into the 'sssp' subfigure (case-insensitive match)
        # place it upper-left, slightly inset, small font and no frame
        lname = prog.lower()
        if 'sssp' in lname:
            handles, labels = ax.get_legend_handles_labels()
            if handles:
                ax.legend(handles, labels, loc='upper left', bbox_to_anchor=(0, 1.02),
                          bbox_transform=ax.transAxes, ncol=2, fontsize=9)

        # hide x tick labels for non-bottom-row subplots
        idx = list(axes).index(ax)
        row_index = idx // ncols
        if row_index != (nrows - 1):
            ax.set_xticklabels([''] * len(ax.get_xticklabels()))

    # Only show y-axis label / tick labels on the left-most subplot of each row
    for i, ax in enumerate(axes):
        col = i % ncols
        if col == 0:
            ax.set_ylabel('Exec/Load time(s)')

    # legend moved into specific subplots above; no global legend here
    # removed figure title per request
    plt.savefig(args.out, dpi=150)
    print(f'Saved {args.out}')


if __name__ == '__main__':
    main()
