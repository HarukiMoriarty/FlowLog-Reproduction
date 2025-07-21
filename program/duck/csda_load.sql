PRAGMA threads=64;
PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Based on csda.dl Datalog program

-- Create tables
CREATE TABLE Edge (
    src INTEGER,
    dest INTEGER
);

CREATE TABLE NullEdge (
    src INTEGER,
    dest INTEGER
);

-- Load data from CSV files
COPY Edge FROM '{{DATASET_PATH}}/Edge.csv' (FORMAT CSV, HEADER FALSE);
COPY NullEdge FROM '{{DATASET_PATH}}/NullEdge.csv' (FORMAT CSV, HEADER FALSE);