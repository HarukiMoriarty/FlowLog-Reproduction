PRAGMA threads=64;
PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Create table
CREATE TABLE Source(
    id INTEGER
);

CREATE TABLE Arc(
    x INTEGER, 
    y INTEGER
);

-- Load data
COPY Source FROM '{{DATASET_PATH}}/Source.csv' (DELIMITER ',', FORMAT csv, HEADER FALSE);
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT csv, HEADER FALSE);

-- Compute Reachable nodes
WITH RECURSIVE Reach(id) AS (
    -- Base case: start from Source
    SELECT id FROM Source

    UNION

    -- Recursive case: expand along Arc
    SELECT a.y
    FROM Reach r
    JOIN Arc a ON r.id = a.x
)

SELECT COUNT(*) AS num_reachable FROM Reach;
