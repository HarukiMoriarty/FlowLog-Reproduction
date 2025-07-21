-- Based on bipartite.dl Datalog program

-- Create arc table (edges in the graph)
DROP TABLE IF EXISTS arc;
CREATE TABLE arc (
    y INTEGER,
    x INTEGER
);

-- Create source table (starting nodes)
DROP TABLE IF EXISTS source;
CREATE TABLE source (
    x INTEGER
);

-- Load data from CSV files
COPY arc FROM '/hostdata/dataset/mind/Arc.csv' (FORMAT CSV, HEADER false);
COPY source FROM '/hostdata/dataset/mind/Source.csv' (FORMAT CSV, HEADER false);

CHECKPOINT;