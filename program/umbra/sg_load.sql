-- Setup: Create tables and load data for bipartite graph detection
-- Based on sg.dl Datalog program

-- Create arc table (edges in the graph)
DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc (
    src INTEGER,
    dest INTEGER
);

-- Load data
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (FORMAT CSV, HEADER false);

SELECT COUNT(*) FROM Arc;