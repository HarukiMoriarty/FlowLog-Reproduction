-- Compute Single Source Shortest Path
-- Based on sssp.dl Datalog program

WITH RECURSIVE Sssp(x, d) AS (
    -- Base case: distance 0 for starting nodes
    SELECT src AS x, 0 AS d
    FROM Id

    UNION

    -- Recursive case: extend shortest paths
    SELECT a.dest AS x, MIN(s.d + a.weight) AS d
    FROM Sssp s
    JOIN Arc a ON s.x = a.src
    GROUP BY a.dest
)

SELECT COUNT(*) FROM (
    SELECT x, MIN(d) AS d
    FROM Sssp
    GROUP BY x
) AS deduped;
