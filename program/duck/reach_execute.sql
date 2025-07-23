PRAGMA threads=64;
PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

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

SELECT DISTINCT COUNT(*) AS num_reachable FROM Reach;
