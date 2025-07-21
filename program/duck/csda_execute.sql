PRAGMA threads=64;
PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Based on csda.dl Datalog program

-- Transitive closure computation
WITH RECURSIVE tc(src, dest) AS (
    SELECT src, dest FROM NullEdge
    UNION
    SELECT tc.src, e.dest
    FROM tc
    JOIN Edge e ON tc.dest = e.src
)
SELECT COUNT(*) FROM tc;
