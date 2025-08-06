-- Setup: Create tables and load data for Single Source Shortest Path
-- Based on sssp.dl Datalog program

-- Create arc table (edges with weights)
DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc (
    src INTEGER,
    dest INTEGER,
    weight INTEGER
);

-- Create id table (starting nodes)
DROP TABLE IF EXISTS Id;
CREATE TABLE Id (
    src INTEGER
);

-- Load data
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (FORMAT CSV, HEADER false);
COPY Id FROM '{{DATASET_PATH}}/id.csv' (FORMAT CSV, HEADER false);


SELECT COUNT(*) FROM Arc;
SELECT COUNT(*) FROM Id;
