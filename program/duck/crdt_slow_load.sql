PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Based on crdt_slow.dl Datalog program
-- CRDT (Conflict-free Replicated Data Type) implementation for ordered lists

-- Create input tables
DROP TABLE IF EXISTS Insert_input;
CREATE TABLE Insert_input (
    a INTEGER,
    b INTEGER, 
    c INTEGER,
    d INTEGER
);

DROP TABLE IF EXISTS Remove_input;
CREATE TABLE Remove_input (
    a INTEGER,
    b INTEGER
);

-- Load data from CSV files
COPY Insert_input FROM './dataset/crdt/Insert_input.csv' (FORMAT CSV, HEADER FALSE);
COPY Remove_input FROM './dataset/crdt/Remove_input.csv' (FORMAT CSV, HEADER FALSE);
