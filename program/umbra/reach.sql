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

-- Load daata
COPY Source FROM '{{DATASET_PATH}}/Source.csv' (DELIMITER ',', FORMAT csv);
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT csv);

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

SELECT COUNT(*) FROM Reach;
