-- Based on crdt_slow.dl Datalog program
-- CRDT (Conflict-free Replicated Data Type) implementation for ordered lists

-- Create input tables
DROP TABLE IF EXISTS Insert_input;
CREATE TABLE Insert_input (
    a INTEGER,
    b INTEGER, 
    c INTEGER,
    d INTEGER
);

DROP TABLE IF EXISTS Remove_input;
CREATE TABLE Remove_input (
    a INTEGER,
    b INTEGER
);

-- Load data from CSV files
COPY Insert_input FROM '{{DATASET_PATH}}/Insert_input.csv' (FORMAT CSV, HEADER FALSE);
COPY Remove_input FROM '{{DATASET_PATH}}/Remove_input.csv' (FORMAT CSV, HEADER FALSE);

-- Based on crdt_slow.dl Datalog program
-- CRDT (Conflict-free Replicated Data Type) implementation for ordered lists

-- Create regular views (Umbra doesn't support CREATE RECURSIVE VIEW)
CREATE VIEW assign AS 
SELECT a AS IDCtr, b AS IDN, a AS ElemCtr, b AS ElemN, b AS Value
FROM Insert_input;

CREATE VIEW hasChild AS 
SELECT DISTINCT c AS ParentCtr, d AS ParentN
FROM Insert_input;

-- Combined ordering logic 
CREATE VIEW nextSibling AS 
WITH 
laterChild AS (
    SELECT DISTINCT i1.c AS ParentCtr, i1.d AS ParentN, i2.a AS Ctr2, i2.b AS N2
    FROM Insert_input i1
    JOIN Insert_input i2 ON i1.c = i2.c AND i1.d = i2.d
    WHERE i1.a * 10 + i1.b > i2.a * 10 + i2.b
),
firstChild AS (
    SELECT i.c AS ParentCtr, i.d AS ParentN, i.a AS ChildCtr, i.b AS ChildN
    FROM Insert_input i
    WHERE NOT EXISTS (
        SELECT 1 FROM laterChild lc 
        WHERE lc.ParentCtr = i.c AND lc.ParentN = i.d 
        AND lc.Ctr2 = i.a AND lc.N2 = i.b
    )
),
sibling AS (
    SELECT DISTINCT i1.a AS ChildCtr1, i1.b AS ChildN1, i2.a AS ChildCtr2, i2.b AS ChildN2
    FROM Insert_input i1
    JOIN Insert_input i2 ON i1.c = i2.c AND i1.d = i2.d
),
laterSibling AS (
    SELECT s.ChildCtr1 AS Ctr1, s.ChildN1 AS N1, s.ChildCtr2 AS Ctr2, s.ChildN2 AS N2
    FROM sibling s
    WHERE s.ChildCtr1 * 10 + s.ChildN1 > s.ChildCtr2 * 10 + s.ChildN2
),
laterSibling2 AS (
    SELECT DISTINCT s1.ChildCtr1 AS Ctr1, s1.ChildN1 AS N1, s3.ChildCtr2 AS Ctr3, s3.ChildN2 AS N3
    FROM sibling s1
    JOIN sibling s2 ON s1.ChildCtr1 = s2.ChildCtr1 AND s1.ChildN1 = s2.ChildN1
    JOIN sibling s3 ON s1.ChildCtr1 = s3.ChildCtr1 AND s1.ChildN1 = s3.ChildN1
    WHERE s1.ChildCtr1 * 10 + s1.ChildN1 > s2.ChildCtr2 * 10 + s2.ChildN2
    AND s2.ChildCtr2 * 10 + s2.ChildN2 > s3.ChildCtr2 * 10 + s3.ChildN2
)
SELECT ls.Ctr1, ls.N1, ls.Ctr2, ls.N2
FROM laterSibling ls
WHERE NOT EXISTS (
    SELECT 1 FROM laterSibling2 ls2
    WHERE ls2.Ctr1 = ls.Ctr1 AND ls2.N1 = ls.N1 
    AND ls2.Ctr3 = ls.Ctr2 AND ls2.N3 = ls.N2
);

-- Regular view for value logic
CREATE VIEW hasValue AS 
SELECT DISTINCT a.ElemCtr, a.ElemN
FROM assign a
WHERE NOT EXISTS (
    SELECT 1 FROM Remove_input r 
    WHERE r.a = a.IDCtr AND r.b = a.IDN
);

-- Main computation using WITH RECURSIVE (since Umbra doesn't support recursive views)
WITH RECURSIVE 
-- First compute nextSiblingAnc
nextSiblingAnc(StartCtr, StartN, NextCtr, NextN) AS (
    -- Base case: direct next sibling
    SELECT Ctr1 AS StartCtr, N1 AS StartN, Ctr2 AS NextCtr, N2 AS NextN
    FROM nextSibling
    
    UNION ALL
    
    -- Recursive case: go up to parent and find its next sibling
    SELECT i.a AS StartCtr, i.b AS StartN, nsa.NextCtr, nsa.NextN
    FROM Insert_input i
    JOIN nextSiblingAnc nsa ON i.c = nsa.StartCtr AND i.d = nsa.StartN
    WHERE NOT EXISTS (
        SELECT 1 FROM nextSibling ns WHERE ns.Ctr1 = i.a AND ns.N1 = i.b
    )
),

-- Then compute nextElem  
nextElem AS (
    -- Case 1: first child  
    SELECT i.c AS PrevCtr, i.d AS PrevN, i.a AS NextCtr, i.b AS NextN
    FROM Insert_input i
    WHERE NOT EXISTS (
        SELECT 1 FROM Insert_input i2 
        WHERE i2.c = i.c AND i2.d = i.d 
        AND i2.a * 10 + i2.b < i.a * 10 + i.b
    )

    UNION

    -- Case 2: no child, use next sibling ancestor
    SELECT nsa.StartCtr AS PrevCtr, nsa.StartN AS PrevN, nsa.NextCtr, nsa.NextN
    FROM nextSiblingAnc nsa
    WHERE NOT EXISTS (
        SELECT 1 FROM hasChild hc 
        WHERE hc.ParentCtr = nsa.StartCtr AND hc.ParentN = nsa.StartN
    )
),

-- Finally compute skipBlank recursively
skipBlank(FromCtr, FromN, ToCtr, ToN) AS (
    -- Base case: direct next element
    SELECT PrevCtr AS FromCtr, PrevN AS FromN, NextCtr AS ToCtr, NextN AS ToN
    FROM nextElem
    
    UNION
    
    -- Recursive case: skip over blank elements
    SELECT sb.FromCtr, sb.FromN, ne.NextCtr AS ToCtr, ne.NextN AS ToN
    FROM skipBlank sb
    JOIN nextElem ne ON sb.ToCtr = ne.PrevCtr AND sb.ToN = ne.PrevN
    WHERE NOT EXISTS (
        SELECT 1 FROM hasValue hv 
        WHERE hv.ElemCtr = sb.ToCtr AND hv.ElemN = sb.ToN
    )
),

-- Compute final result
nextVisible AS (
    SELECT sb.FromCtr AS PrevCtr, sb.FromN AS PrevN, sb.ToCtr AS NextCtr, sb.ToN AS NextN
    FROM skipBlank sb
    JOIN hasValue hv1 ON hv1.ElemCtr = sb.FromCtr AND hv1.ElemN = sb.FromN
    JOIN hasValue hv2 ON hv2.ElemCtr = sb.ToCtr AND hv2.ElemN = sb.ToN
),
result AS (
    SELECT nv.PrevCtr AS ctr1, nv.NextCtr AS ctr2, a.Value
    FROM nextVisible nv
    JOIN assign a ON nv.NextCtr = a.ElemCtr AND nv.NextN = a.ElemN
    WHERE NOT EXISTS (
        SELECT 1 FROM Remove_input r 
        WHERE r.a = a.IDCtr AND r.b = a.IDN
    )
)
SELECT COUNT(*) FROM result;

