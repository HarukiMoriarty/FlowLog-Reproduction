PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Connected components detection using recursive propagation
-- Finds all connected components in an undirected graph
-- Based on cc.dl Datalog program

-- Create edges table for graph structure
DROP TABLE IF EXISTS edges;
CREATE TABLE edges (
    node1id INTEGER,
    node2id INTEGER
);

-- Load graph data from CSV file
COPY edges FROM '{{DATASET_PATH}}/Arc.csv' (FORMAT CSV, HEADER false);