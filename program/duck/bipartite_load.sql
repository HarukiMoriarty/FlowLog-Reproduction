PRAGMA threads=64;
PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Setup: Create tables and load data for bipartite graph detection
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
COPY arc FROM '{{DATASET_PATH}}/Arc.csv' (FORMAT CSV, HEADER false);
COPY source FROM '{{DATASET_PATH}}/Source.csv' (FORMAT CSV, HEADER false);