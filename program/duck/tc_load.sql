PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Create Table
DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc(
    x INTEGER, 
    y INTEGER
);

-- Load data
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT CSV, HEADER FALSE);