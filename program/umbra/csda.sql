-- Create table
DROP TABLE IF EXISTS NullEdge;
CREATE TABLE NullEdge(
    x INTEGER, 
    y INTEGER
);

DROP TABLE IF EXISTS Edge;
CREATE TABLE Edge(
    x INTEGER, 
    y INTEGER
);

-- Load data
COPY NullEdge FROM '/hostdata/dataset/csda-httpd/NullEdge.csv' (DELIMITER ',', FORMAT csv);
COPY Edge FROM '/hostdata/dataset/csda-httpd/Edge.csv' (DELIMITER ',', FORMAT csv);

-- Step 3: Compute NullNode as reachability from x via Edge, seeded by NullEdge
WITH RECURSIVE tc(x, y) AS (
    -- Base case: from NullEdge
    SELECT x, y FROM NullEdge

    UNION

    -- Recursive case: extend path from (x, w) to (x, y) via Edge(w, y)
    SELECT n.x, e.y
    FROM tc n
    JOIN Edge e ON n.y = e.x
)

-- Step 4: Output number of NullNode entries
SELECT COUNT(*) FROM tc;
