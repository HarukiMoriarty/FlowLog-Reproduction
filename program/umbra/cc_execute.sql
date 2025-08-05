-- Recursive propagation of component IDs
WITH RECURSIVE cc(id, comp) AS (
    SELECT node1id, node1id AS comp FROM edges

    UNION

    SELECT e.node2id AS id, MIN(c.comp)
    FROM cc AS c
    JOIN edges AS e ON e.node1id = c.id
    GROUP BY e.node2id
)

-- Final aggregation
SELECT COUNT(*) 
FROM (
    SELECT id, MIN(comp) AS comp
    FROM cc
    GROUP BY id
);