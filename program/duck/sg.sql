PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Setup: Create tables and load data for bipartite graph detection
-- Based on sg.dl Datalog program

-- Create arc table (edges in the graph)
DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc (
    src INTEGER,
    dest INTEGER
);

-- Load data
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (FORMAT CSV, HEADER false);

-- Setup: Create tables and load data for bipartite graph detection
-- Based on sg.dl Datalog program

WITH RECURSIVE Sg(x, y) AS (
    SELECT A1.dest AS x, A2.dest AS y
    FROM Arc AS A1
    JOIN Arc AS A2 ON A1.src = A2.src
    WHERE A1.dest <> A2.dest

    UNION

    -- Recursive case: Sg(a, b), Arc(a, x), Arc(b, y)
    SELECT A1.dest AS x, A2.dest AS y
    FROM Arc AS A1
    JOIN Sg AS S ON A1.src = S.x
    JOIN Arc AS A2 ON S.y = A2.src
)
SELECT COUNT(*) FROM Sg;
