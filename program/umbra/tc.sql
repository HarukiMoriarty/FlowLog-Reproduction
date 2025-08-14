-- Create table
DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc(
    x INTEGER, 
    y INTEGER
);

-- Load data
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT csv);

SELECT COUNT(*) FROM Arc;

-- Compute transitive closure
WITH RECURSIVE Tc(x, y) AS (
    SELECT x, y FROM Arc
    UNION
    SELECT a.x, b.y
    FROM Tc AS a
    JOIN Arc AS b ON a.y = b.x
)
SELECT COUNT(*) FROM Tc;

