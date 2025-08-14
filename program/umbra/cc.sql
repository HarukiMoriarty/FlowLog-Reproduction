-- Step 1: Define edges
DROP TABLE IF EXISTS edges;
CREATE TABLE edges(
    node1id INTEGER, 
    node2id INTEGER
);

COPY edges FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT csv, HEADER false);

SELECT COUNT(*) FROM edges;

-- Recursive propagation of component IDs
WITH RECURSIVE cc(id, comp) AS (
    SELECT node1id AS id, node1id AS comp
    FROM edges

    UNION

    SELECT e.node2id AS id, MIN(c.comp) AS comp
    FROM cc AS c
    JOIN edges AS e ON e.node1id = c.id
    GROUP BY e.node2id
)

-- Count total number of nodes after deduplication
SELECT COUNT(*) AS total_nodes
FROM (
    SELECT id, MIN(comp) AS comp
    FROM cc
    GROUP BY id
) AS deduped;
