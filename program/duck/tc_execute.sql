PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Compute transitive closure and store result
WITH RECURSIVE Tc(x, y) AS (
    SELECT x, y FROM Arc
    UNION
    SELECT a.x, b.y
    FROM Tc AS a
    JOIN Arc AS b ON a.y = b.x
)

SELECT COUNT(*) FROM Tc;
