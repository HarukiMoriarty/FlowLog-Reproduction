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
COPY NullEdge FROM '{{DATASET_PATH}}/NullEdge.csv' (DELIMITER ',', FORMAT csv);
COPY Edge FROM '{{DATASET_PATH}}/Edge.csv' (DELIMITER ',', FORMAT csv);

SELECT COUNT(*) FROM NullEdge;
SELECT COUNT(*) FROM Edge;