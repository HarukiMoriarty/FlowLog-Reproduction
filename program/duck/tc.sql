PRAGMA threads=64;
PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Create Table
CREATE TABLE Arc(
    x INTEGER, 
    y INTEGER
);

-- Load data
COPY Arc FROM './dataset/mind/Arc.csv' (DELIMITER ',', FORMAT CSV, HEADER FALSE);

-- Compute transitive closure and store result
WITH RECURSIVE Tc(x, y) AS (
    SELECT x, y FROM Arc
    UNION
    SELECT a.x, b.y
    FROM Tc AS a
    JOIN Arc AS b ON a.y = b.x
)

SELECT COUNT(*) FROM Tc;
