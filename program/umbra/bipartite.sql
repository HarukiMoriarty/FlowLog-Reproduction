-- Based on bipartite.dl Datalog program

-- Create arc table (edges in the graph)
DROP TABLE IF EXISTS arc;
CREATE TABLE arc (
    y INTEGER,
    x INTEGER
);

-- Create source table (starting nodes)
DROP TABLE IF EXISTS source;
CREATE TABLE source (
    x INTEGER
);

-- Load data from CSV files
COPY arc FROM '{{DATASET_PATH}}/Arc.csv' (FORMAT CSV, HEADER false);
COPY source FROM '{{DATASET_PATH}}/Source.csv' (FORMAT CSV, HEADER false);

-- Display table sizes avoid lazy store
SELECT COUNT(*) FROM arc;
SELECT COUNT(*) FROM source;

-- Based on bipartite.dl Datalog program

WITH RECURSIVE
    coloring(x, color) AS (
        -- Base case: Start from source nodes, color 0
        SELECT x, 0 FROM source
        UNION
        -- Recursive case: Propagate to neighbors with opposite color
        SELECT neighbor, 1 - color
        FROM (
            SELECT arc.y AS neighbor, coloring.color
            FROM coloring JOIN arc ON arc.x = coloring.x
            UNION ALL
            SELECT arc.x AS neighbor, coloring.color
            FROM coloring JOIN arc ON arc.y = coloring.x
        ) AS derived
    )
SELECT
    COUNT(DISTINCT x) FILTER (WHERE color = 0) AS zero_count,
    COUNT(DISTINCT x) FILTER (WHERE color = 1) AS one_count,
    -- Count the intersection of the two sets
    COUNT(DISTINCT x) FILTER (WHERE color = 0 AND x IN (SELECT x FROM coloring WHERE color = 1)) AS intersection_count
FROM coloring;



