PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;

-- Setup: Create tables and load data for Single Source Shortest Path
-- Based on sssp.dl Datalog program

-- Create arc table (edges with weights)
DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc (
    src INTEGER,
    dest INTEGER,
    weight INTEGER
);

-- Create id table (starting nodes)
DROP TABLE IF EXISTS Id;
CREATE TABLE Id (
    src INTEGER
);

-- Load data
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (FORMAT CSV, HEADER false);
COPY Id FROM '{{DATASET_PATH}}/id.csv' (FORMAT CSV, HEADER false);

WITH RECURSIVE Sssp(x, d) USING KEY (x) AS (
    SELECT src AS x, 0 AS d
    FROM Id

    UNION

    (SELECT DISTINCT ON (a.dest) a.dest AS x, s.d + a.weight AS d
     FROM recurring.Sssp AS s, Sssp AS u, Arc AS a
     WHERE a.src = u.x
       AND s.x = u.x
       AND s.d + a.weight < COALESCE((SELECT d FROM recurring.Sssp WHERE x = a.dest), 999999999)
     ORDER BY a.dest ASC, s.d + a.weight ASC)
)

SELECT COUNT(*) FROM Sssp;
