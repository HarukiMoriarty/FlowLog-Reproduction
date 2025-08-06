-- Create table
DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc(
    x INTEGER, 
    y INTEGER
);

-- Load data
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT csv);

SELECT COUNT(*) FROM Arc;
