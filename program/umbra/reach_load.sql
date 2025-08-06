-- Create table
DROP TABLE IF EXISTS Source;
CREATE TABLE Source(
    id INTEGER
);

DROP TABLE IF EXISTS Arc;
CREATE TABLE Arc(
    x INTEGER, 
    y INTEGER
);

-- Load daata
COPY Source FROM '{{DATASET_PATH}}/Source.csv' (DELIMITER ',', FORMAT csv);
COPY Arc FROM '{{DATASET_PATH}}/Arc.csv' (DELIMITER ',', FORMAT csv);

SELECT COUNT(*) FROM Source;
SELECT COUNT(*) FROM Arc;
