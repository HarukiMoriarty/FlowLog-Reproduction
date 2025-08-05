PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Connected components detection using recursive propagation
-- Finds all connected components in an undirected graph
-- Based on cc.dl Datalog program

-- Recursive propagation to find connected components
WITH RECURSIVE cc(id, comp) AS (
    -- Initialize each node with itself as component ID
    SELECT node1id AS id, node1id AS comp 
    FROM edges

    UNION

    -- Propagate minimum component ID to connected nodes
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