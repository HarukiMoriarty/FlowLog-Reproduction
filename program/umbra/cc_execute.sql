-- Recursive propagation of component IDs (no DISTINCT ON, no ORDER BY)
WITH RECURSIVE cc(id, comp) AS (
    SELECT node1id, node1id AS comp FROM edges

    UNION ALL RECURRING

    SELECT e.node2id AS id, MIN(c.comp)
    FROM cc AS c
    JOIN edges AS e ON e.node1id = c.id
    LEFT JOIN Recurring r ON e.node2id = r.id
    WHERE c.comp < r.comp OR r.comp IS NULL
    GROUP BY e.node2id
)

-- Final projection (deduplicate by picking smallest comp per node)
SELECT COUNT(*) FROM (
    SELECT id, MIN(comp) AS comp
    FROM cc
    GROUP BY id
) AS deduped;
