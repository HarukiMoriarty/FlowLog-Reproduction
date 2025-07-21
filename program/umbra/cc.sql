-- Step 1: Define edges
DROP TABLE IF EXISTS edges;
CREATE TABLE edges(
    node1id INTEGER, 
    node2id INTEGER
);

COPY edges FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT csv, HEADER false);

-- Recursive propagation of component IDs (no DISTINCT ON, no ORDER BY)
WITH RECURSIVE cc(id, comp) AS (
    SELECT node1id, node1id AS comp FROM edges

    UNION

    SELECT e.node2id AS id, MIN(c.comp)
    FROM cc AS c
    JOIN edges AS e ON e.node1id = c.id
    GROUP BY e.node2id
)

-- Final projection (deduplicate by picking smallest comp per node)
SELECT COUNT(*) FROM (
    SELECT id, MIN(comp) AS comp
    FROM cc
    GROUP BY id
) AS deduped;
