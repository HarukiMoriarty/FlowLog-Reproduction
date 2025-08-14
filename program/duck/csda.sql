PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Based on csda.dl Datalog program

-- Create tables
DROP TABLE IF EXISTS Edge;
CREATE TABLE Edge (
    src INTEGER,
    dest INTEGER
);

DROP TABLE IF EXISTS NullEdge;
CREATE TABLE NullEdge (
    src INTEGER,
    dest INTEGER
);

-- Load data from CSV files
COPY Edge FROM '{{DATASET_PATH}}/Edge.csv' (FORMAT CSV, HEADER FALSE);
COPY NullEdge FROM '{{DATASET_PATH}}/NullEdge.csv' (FORMAT CSV, HEADER FALSE);

-- Based on csda.dl Datalog program

-- Transitive closure computation
WITH RECURSIVE tc(src, dest) AS (
    SELECT src, dest FROM NullEdge
    UNION
    SELECT tc.src, e.dest
    FROM tc
    JOIN Edge e ON tc.dest = e.src
)
SELECT COUNT(*) FROM tc;
