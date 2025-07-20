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
COPY Edge FROM './dataset/csda-httpd/Edge.csv' (FORMAT CSV, HEADER FALSE);
COPY NullEdge FROM './dataset/csda-httpd/NullEdge.csv' (FORMAT CSV, HEADER FALSE);

-- Transitive closure computation
WITH RECURSIVE tc(src, dest) AS (
    SELECT src, dest FROM NullEdge
    UNION
    SELECT tc.src, e.dest
    FROM tc
    JOIN Edge e ON tc.dest = e.src
)
SELECT COUNT(*) FROM tc;
