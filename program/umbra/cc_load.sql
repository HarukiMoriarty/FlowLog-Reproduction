-- Step 1: Define edges
DROP TABLE IF EXISTS edges;
CREATE TABLE edges(
    node1id INTEGER, 
    node2id INTEGER
);

COPY edges FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT csv, HEADER false);

CHECKPOINT;