-- Create table
DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc(
    x INTEGER, 
    y INTEGER
);

-- Load data
COPY Arc FROM '/hostdata/dataset/mind/Arc.csv' (DELIMITER ',', FORMAT csv);

-- Compute transitive closure
WITH RECURSIVE Tc(x, y) AS (
    SELECT x, y FROM Arc
    UNION
    SELECT a.x, b.y
    FROM Tc AS a
    JOIN Arc AS b ON a.y = b.x
)
SELECT COUNT(*) FROM Tc;
