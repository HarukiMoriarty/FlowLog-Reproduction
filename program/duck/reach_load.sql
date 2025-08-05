PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Create table
DROP TABLE IF EXISTS Source;
CREATE TABLE Source(
    id INTEGER
);

DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc(
    x INTEGER, 
    y INTEGER
);

-- Load data
COPY Source FROM '{{DATASET_PATH}}/Source.csv' (DELIMITER ',', FORMAT csv, HEADER FALSE);
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT csv, HEADER FALSE);