-- Compute Single Source Shortest Path
-- Based on sssp.dl Datalog program

WITH RECURSIVE Sssp(x, d) AS (
    -- Base case: distance 0 for starting nodes
    SELECT src AS x, 0 AS d
    FROM Id

    UNION ALL RECURRING

    -- Recursive case: extend shortest paths
    select x,d from (
        SELECT a.dest as x, min(s.d + a.weight) as d, min(r.d) as rd
        FROM Sssp s
        JOIN Arc a on s.x = a.src
        LEFT JOIN Recurring r on a.dest = r.x
        WHERE s.d + a.weight < r.d or r.d is null
        GROUP BY a.dest
    ) s where s.d < s.rd or s.rd is null
)

-- Deduplicate the results
SELECT COUNT(*) FROM (
    SELECT x, MIN(d) AS d
    FROM Sssp
    GROUP BY x
) AS deduped;

