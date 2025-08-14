-- Based on borrow.dl Datalog program
-- Rust borrow checker analysis

-- Create input tables
DROP TABLE IF EXISTS subset_base;
CREATE TABLE subset_base (x INTEGER, y INTEGER, z INTEGER);

DROP TABLE IF EXISTS cfg_edge;
CREATE TABLE cfg_edge (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS loan_issued_at;
CREATE TABLE loan_issued_at (x INTEGER, y INTEGER, z INTEGER);

DROP TABLE IF EXISTS universal_region;
CREATE TABLE universal_region (x INTEGER);

DROP TABLE IF EXISTS var_used_at;
CREATE TABLE var_used_at (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS loan_killed_at;
CREATE TABLE loan_killed_at (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS known_placeholder_subset;
CREATE TABLE known_placeholder_subset (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS var_dropped_at;
CREATE TABLE var_dropped_at (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS drop_of_var_derefs_origin;
CREATE TABLE drop_of_var_derefs_origin (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS var_defined_at;
CREATE TABLE var_defined_at (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS child_path;
CREATE TABLE child_path (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS path_moved_at_base;
CREATE TABLE path_moved_at_base (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS path_assigned_at_base;
CREATE TABLE path_assigned_at_base (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS path_accessed_at_base;
CREATE TABLE path_accessed_at_base (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS path_is_var;
CREATE TABLE path_is_var (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS loan_invalidated_at;
CREATE TABLE loan_invalidated_at (x INTEGER, y INTEGER);

DROP TABLE IF EXISTS use_of_var_derefs_origin;
CREATE TABLE use_of_var_derefs_origin (x INTEGER, y INTEGER);

-- Load data from CSV files
COPY subset_base FROM '{{DATASET_PATH}}/subset_base.csv' (FORMAT CSV, HEADER FALSE);
COPY cfg_edge FROM '{{DATASET_PATH}}/cfg_edge.csv' (FORMAT CSV, HEADER FALSE);
COPY loan_issued_at FROM '{{DATASET_PATH}}/loan_issued_at.csv' (FORMAT CSV, HEADER FALSE);
COPY universal_region FROM '{{DATASET_PATH}}/universal_region.csv' (FORMAT CSV, HEADER FALSE);
COPY var_used_at FROM '{{DATASET_PATH}}/var_used_at.csv' (FORMAT CSV, HEADER FALSE);
COPY loan_killed_at FROM '{{DATASET_PATH}}/loan_killed_at.csv' (FORMAT CSV, HEADER FALSE);
COPY known_placeholder_subset FROM '{{DATASET_PATH}}/known_placeholder_subset.csv' (FORMAT CSV, HEADER FALSE);
COPY var_dropped_at FROM '{{DATASET_PATH}}/var_dropped_at.csv' (FORMAT CSV, HEADER FALSE);
COPY drop_of_var_derefs_origin FROM '{{DATASET_PATH}}/drop_of_var_derefs_origin.csv' (FORMAT CSV, HEADER FALSE);
COPY var_defined_at FROM '{{DATASET_PATH}}/var_defined_at.csv' (FORMAT CSV, HEADER FALSE);
COPY child_path FROM '{{DATASET_PATH}}/child_path.csv' (FORMAT CSV, HEADER FALSE);
COPY path_moved_at_base FROM '{{DATASET_PATH}}/path_moved_at_base.csv' (FORMAT CSV, HEADER FALSE);
COPY path_assigned_at_base FROM '{{DATASET_PATH}}/path_assigned_at_base.csv' (FORMAT CSV, HEADER FALSE);
COPY path_accessed_at_base FROM '{{DATASET_PATH}}/path_accessed_at_base.csv' (FORMAT CSV, HEADER FALSE);
COPY path_is_var FROM '{{DATASET_PATH}}/path_is_var.csv' (FORMAT CSV, HEADER FALSE);
COPY loan_invalidated_at FROM '{{DATASET_PATH}}/loan_invalidated_at.csv' (FORMAT CSV, HEADER FALSE);
COPY use_of_var_derefs_origin FROM '{{DATASET_PATH}}/use_of_var_derefs_origin.csv' (FORMAT CSV, HEADER FALSE);

-- Based on borrow.dl Datalog program
-- Following the exact strata order provided, using separate views for each strata
-- DuckDB doesn't support CREATE RECURSIVE VIEW, so we'll use CREATE VIEW + WITH RECURSIVE

-- Drop all existing views first
DROP VIEW IF EXISTS path_assigned_at_strata1;
DROP VIEW IF EXISTS ancestor_path_strata1;
DROP VIEW IF EXISTS path_moved_at_strata1;
DROP VIEW IF EXISTS path_begins_with_var_strata1;
DROP VIEW IF EXISTS subset_strata1;
DROP VIEW IF EXISTS path_accessed_at_strata1;
DROP VIEW IF EXISTS origin_contains_loan_on_entry_strata1;
DROP VIEW IF EXISTS var_live_on_entry_strata1;
DROP VIEW IF EXISTS cfg_node_strata1;
DROP VIEW IF EXISTS placeholder_origin_strata1;
DROP VIEW IF EXISTS known_placeholder_subset_strata2;
DROP VIEW IF EXISTS origin_live_on_entry_strata3;
DROP VIEW IF EXISTS ancestor_path_strata4;
DROP VIEW IF EXISTS var_live_on_entry_strata5;
DROP VIEW IF EXISTS origin_live_on_entry_strata6;
DROP VIEW IF EXISTS path_assigned_at_strata7;
DROP VIEW IF EXISTS path_moved_at_strata8;
DROP VIEW IF EXISTS path_begins_with_var_strata9;
DROP VIEW IF EXISTS path_accessed_at_strata10;
DROP VIEW IF EXISTS path_maybe_initialized_on_exit_strata11;
DROP VIEW IF EXISTS path_maybe_uninitialized_on_exit_strata11;
DROP VIEW IF EXISTS path_maybe_initialized_on_exit_strata12;
DROP VIEW IF EXISTS path_maybe_uninitialized_on_exit_strata13;
DROP VIEW IF EXISTS var_maybe_partly_initialized_on_exit_strata14;
DROP VIEW IF EXISTS move_error_strata14;
DROP VIEW IF EXISTS var_maybe_partly_initialized_on_entry_strata15;
DROP VIEW IF EXISTS var_drop_live_on_entry_strata16;
DROP VIEW IF EXISTS var_drop_live_on_entry_strata17;
DROP VIEW IF EXISTS origin_live_on_entry_strata18;
DROP VIEW IF EXISTS subset_strata19;
DROP VIEW IF EXISTS subset_error_strata20;
DROP VIEW IF EXISTS origin_contains_loan_on_entry_strata21;
DROP VIEW IF EXISTS loan_live_at_strata22;
DROP VIEW IF EXISTS errors_strata23;

-- Strata #1: [0, 1, 2, 12, 13, 14, 21, 22, 23, 24, 25] - Non-recursive base facts
-- Rule 0: path_assigned_at(x, y) :- path_assigned_at_base(x, y).
CREATE VIEW path_assigned_at_strata1 AS 
    SELECT x, y FROM path_assigned_at_base;

-- Rule 1: ancestor_path(x, y) :- child_path(x, y).
CREATE VIEW ancestor_path_strata1 AS 
    SELECT x, y FROM child_path;

-- Rule 2: path_moved_at(x, y) :- path_moved_at_base(x, y).
CREATE VIEW path_moved_at_strata1 AS 
    SELECT x, y FROM path_moved_at_base;

-- Rule 12: path_begins_with_var(x, var) :- path_is_var(x, var).
CREATE VIEW path_begins_with_var_strata1 AS 
    SELECT x, y FROM path_is_var;

-- Rule 13: subset(origin1, origin2, point) :- subset_base(origin1, origin2, point).
CREATE VIEW subset_strata1 AS 
    SELECT x, y, z FROM subset_base;

-- Rule 14: path_accessed_at(x, y) :- path_accessed_at_base(x, y).
CREATE VIEW path_accessed_at_strata1 AS 
    SELECT x, y FROM path_accessed_at_base;

-- Rule 21: origin_contains_loan_on_entry(origin, loan, point) :- loan_issued_at(loan, origin, point).
CREATE VIEW origin_contains_loan_on_entry_strata1 AS 
    SELECT y, x, z FROM loan_issued_at;

-- Rule 22: var_live_on_entry(var, point) :- var_used_at(var, point).
CREATE VIEW var_live_on_entry_strata1 AS 
    SELECT x, y FROM var_used_at;

-- Rule 23: cfg_node(point1) :- cfg_edge(point1, _).
-- Rule 24: cfg_node(point2) :- cfg_edge(_, point2).
CREATE VIEW cfg_node_strata1 AS 
    SELECT x FROM cfg_edge
    UNION
    SELECT y FROM cfg_edge;

-- Rule 25: placeholder_origin(origin) :- universal_region(origin).
CREATE VIEW placeholder_origin_strata1 AS 
    SELECT x FROM universal_region;

-- Strata #2: [3] - Recursive
-- Rule 3: known_placeholder_subset(x, z) :- known_placeholder_subset(x, y), known_placeholder_subset(y, z).
CREATE VIEW known_placeholder_subset_strata2 AS 
WITH RECURSIVE kps_rec(x, y) AS (
    SELECT x, y FROM known_placeholder_subset
    UNION
    SELECT kps1.x, kps2.y
    FROM kps_rec kps1
    JOIN kps_rec kps2 ON kps1.y = kps2.x
)
SELECT x, y FROM kps_rec;

-- Strata #3: [11] - Non-recursive
-- Rule 11: origin_live_on_entry(origin, point) :- cfg_node(point), universal_region(origin).
CREATE VIEW origin_live_on_entry_strata3 AS 
    SELECT ur.x AS x, cn.x AS y
    FROM universal_region ur
    CROSS JOIN cfg_node_strata1 cn;

-- Strata #4: [26] - Recursive
-- Rule 26: ancestor_path(Grandparent, Child) :- ancestor_path(Parent, Child), child_path(Parent, Grandparent).
CREATE VIEW ancestor_path_strata4 AS 
WITH RECURSIVE ap_rec(x, y) AS (
    SELECT x, y FROM ancestor_path_strata1
    UNION
    SELECT cp.y, ap.y
    FROM ap_rec ap
    JOIN child_path cp ON ap.x = cp.x
)
SELECT x, y FROM ap_rec;

-- Strata #5: [19] - Recursive
-- Rule 19: var_live_on_entry(var, point1) :- var_live_on_entry(var, point2), cfg_edge(point1, point2), !var_defined_at(var, point1).
CREATE VIEW var_live_on_entry_strata5 AS 
WITH RECURSIVE vle_rec(var, point) AS (
    SELECT x, y FROM var_live_on_entry_strata1
    UNION
    SELECT vle.var, ce.x
    FROM vle_rec vle
    JOIN cfg_edge ce ON vle.point = ce.y
    WHERE NOT EXISTS (SELECT 1 FROM var_defined_at vda WHERE vda.x = vle.var AND vda.y = ce.x)
)
SELECT var, point FROM vle_rec;

-- Strata #6: [18] - Non-recursive
-- Rule 18: origin_live_on_entry(origin, point) :- var_live_on_entry(var, point), use_of_var_derefs_origin(var, origin).
CREATE VIEW origin_live_on_entry_strata6 AS 
    SELECT x, y FROM origin_live_on_entry_strata3
    UNION
    SELECT uvo.y AS x, vle.point AS y
    FROM var_live_on_entry_strata5 vle
    JOIN use_of_var_derefs_origin uvo ON vle.var = uvo.x;

-- Strata #7: [28] - Recursive
-- Rule 28: path_assigned_at(Child, point) :- path_assigned_at(Parent, point), ancestor_path(Parent, Child).
CREATE VIEW path_assigned_at_strata7 AS 
WITH RECURSIVE pa_rec(x, y) AS (
    SELECT x, y FROM path_assigned_at_strata1
    UNION
    SELECT ap.y, pa.y
    FROM pa_rec pa
    JOIN ancestor_path_strata4 ap ON pa.x = ap.x
)
SELECT x, y FROM pa_rec;

-- Strata #8: [27] - Recursive
-- Rule 27: path_moved_at(Child, Point) :- path_moved_at(Parent, Point), ancestor_path(Parent, Child).
CREATE VIEW path_moved_at_strata8 AS 
WITH RECURSIVE pm_rec(x, y) AS (
    SELECT x, y FROM path_moved_at_strata1
    UNION
    SELECT ap.y, pm.y
    FROM pm_rec pm
    JOIN ancestor_path_strata4 ap ON pm.x = ap.x
)
SELECT x, y FROM pm_rec;

-- Strata #9: [30] - Recursive
-- Rule 30: path_begins_with_var(Child, Var) :- path_begins_with_var(Parent, Var), ancestor_path(Parent, Child).
CREATE VIEW path_begins_with_var_strata9 AS 
WITH RECURSIVE pbv_rec(x, y) AS (
    SELECT x, y FROM path_begins_with_var_strata1
    UNION
    SELECT ap.y, pbv.y
    FROM pbv_rec pbv
    JOIN ancestor_path_strata4 ap ON pbv.x = ap.x
)
SELECT x, y FROM pbv_rec;

-- Strata #10: [29] - Recursive
-- Rule 29: path_accessed_at(Child, point) :- path_accessed_at(Parent, point), ancestor_path(Parent, Child).
CREATE VIEW path_accessed_at_strata10 AS 
WITH RECURSIVE paa_rec(x, y) AS (
    SELECT x, y FROM path_accessed_at_strata1
    UNION
    SELECT ap.y, paa.y
    FROM paa_rec paa
    JOIN ancestor_path_strata4 ap ON paa.x = ap.x
)
SELECT x, y FROM paa_rec;

-- Strata #11: [31, 32] - Non-recursive
-- Rule 31: path_maybe_initialized_on_exit(path, point) :- path_assigned_at(path, point).
CREATE VIEW path_maybe_initialized_on_exit_strata11 AS 
    SELECT x, y FROM path_assigned_at_strata7;

-- Rule 32: path_maybe_uninitialized_on_exit(path, point) :- path_moved_at(path, point).
CREATE VIEW path_maybe_uninitialized_on_exit_strata11 AS 
    SELECT x, y FROM path_moved_at_strata8;

-- Strata #12: [33] - Recursive
-- Rule 33: path_maybe_initialized_on_exit(path, point2) :- path_maybe_initialized_on_exit(path, point1), cfg_edge(point1, point2), !path_moved_at(path, point2).
CREATE VIEW path_maybe_initialized_on_exit_strata12 AS 
WITH RECURSIVE pmie_rec(x, y) AS (
    SELECT x, y FROM path_maybe_initialized_on_exit_strata11
    UNION
    SELECT pmie.x, ce.y
    FROM pmie_rec pmie
    JOIN cfg_edge ce ON pmie.y = ce.x
    WHERE NOT EXISTS (SELECT 1 FROM path_moved_at_strata8 pma WHERE pma.x = pmie.x AND pma.y = ce.y)
)
SELECT x, y FROM pmie_rec;

-- Strata #13: [34] - Recursive
-- Rule 34: path_maybe_uninitialized_on_exit(path, point2) :- path_maybe_uninitialized_on_exit(path, point1), cfg_edge(point1, point2), !path_assigned_at(path, point2).
CREATE VIEW path_maybe_uninitialized_on_exit_strata13 AS 
WITH RECURSIVE pmue_rec(x, y) AS (
    SELECT x, y FROM path_maybe_uninitialized_on_exit_strata11
    UNION
    SELECT pmue.x, ce.y
    FROM pmue_rec pmue
    JOIN cfg_edge ce ON pmue.y = ce.x
    WHERE NOT EXISTS (SELECT 1 FROM path_assigned_at_strata7 paa WHERE paa.x = pmue.x AND paa.y = ce.y)
)
SELECT x, y FROM pmue_rec;

-- Strata #14: [35, 36] - Non-recursive
-- Rule 35: var_maybe_partly_initialized_on_exit(var, point) :- path_maybe_initialized_on_exit(path, point), path_begins_with_var(path, var).
CREATE VIEW var_maybe_partly_initialized_on_exit_strata14 AS 
    SELECT pbv.y AS x, pmie.y AS y
    FROM path_maybe_initialized_on_exit_strata12 pmie
    JOIN path_begins_with_var_strata9 pbv ON pmie.x = pbv.x;

-- Rule 36: move_error(Path, TargetNode) :- path_maybe_uninitialized_on_exit(Path, SourceNode), cfg_edge(SourceNode, TargetNode).
CREATE VIEW move_error_strata14 AS 
    SELECT pmue.x, ce.y
    FROM path_maybe_uninitialized_on_exit_strata13 pmue
    JOIN cfg_edge ce ON pmue.y = ce.x;

-- Strata #15: [15] - Non-recursive
-- Rule 15: var_maybe_partly_initialized_on_entry(var, point2) :- var_maybe_partly_initialized_on_exit(var, point1), cfg_edge(point1, point2).
CREATE VIEW var_maybe_partly_initialized_on_entry_strata15 AS 
    SELECT vmpie.x, ce.y
    FROM var_maybe_partly_initialized_on_exit_strata14 vmpie
    JOIN cfg_edge ce ON vmpie.y = ce.x;

-- Strata #16: [16] - Non-recursive
-- Rule 16: var_drop_live_on_entry(var, point) :- var_dropped_at(var, point), var_maybe_partly_initialized_on_entry(var, point).
CREATE VIEW var_drop_live_on_entry_strata16 AS 
    SELECT vda.x, vda.y
    FROM var_dropped_at vda
    JOIN var_maybe_partly_initialized_on_entry_strata15 vmpie ON vda.x = vmpie.x AND vda.y = vmpie.y;

-- Strata #17: [20] - Recursive
-- Rule 20: var_drop_live_on_entry(Var, SourceNode) :- var_drop_live_on_entry(Var, TargetNode), cfg_edge(SourceNode, TargetNode), !var_defined_at(Var, SourceNode), var_maybe_partly_initialized_on_exit(Var, SourceNode).
CREATE VIEW var_drop_live_on_entry_strata17 AS 
WITH RECURSIVE vdle_rec(x, y) AS (
    SELECT x, y FROM var_drop_live_on_entry_strata16
    UNION
    SELECT vdle.x, ce.x
    FROM vdle_rec vdle
    JOIN cfg_edge ce ON vdle.y = ce.y
    JOIN var_maybe_partly_initialized_on_exit_strata14 vmpie ON vdle.x = vmpie.x AND ce.x = vmpie.y
    WHERE NOT EXISTS (SELECT 1 FROM var_defined_at vda WHERE vda.x = vdle.x AND vda.y = ce.x)
)
SELECT x, y FROM vdle_rec;

-- Strata #18: [17] - Non-recursive
-- Rule 17: origin_live_on_entry(origin, point) :- var_drop_live_on_entry(var, point), drop_of_var_derefs_origin(var, origin).
CREATE VIEW origin_live_on_entry_strata18 AS 
    SELECT x, y FROM origin_live_on_entry_strata6
    UNION
    SELECT dvo.y AS x, vdle.y AS y
    FROM var_drop_live_on_entry_strata17 vdle
    JOIN drop_of_var_derefs_origin dvo ON vdle.x = dvo.x;

-- Strata #19: [4, 5] - Recursive (complex subset propagation)
-- Rule 4: subset(origin1, origin2, point2) :- subset(origin1, origin2, point1), cfg_edge(point1, point2), origin_live_on_entry(origin1, point2), origin_live_on_entry(origin2, point2).
-- Rule 5: subset(origin1, origin3, point) :- subset(origin1, origin2, point), subset_base(origin2, origin3, point), [origin1 ≠ origin3].
CREATE VIEW subset_strata19 AS 
WITH RECURSIVE subset_rec(x, y, z) AS (
    SELECT x, y, z FROM subset_strata1
    UNION
    (SELECT s.x, s.y, ce.y
     FROM subset_rec s
     JOIN cfg_edge ce ON s.z = ce.x
     JOIN origin_live_on_entry_strata18 ole1 ON s.x = ole1.x AND ce.y = ole1.y
     JOIN origin_live_on_entry_strata18 ole2 ON s.y = ole2.x AND ce.y = ole2.y
     UNION
     SELECT s.x, sb.y, s.z
     FROM subset_rec s
     JOIN subset_base sb ON s.y = sb.x AND s.z = sb.z
     WHERE s.x != sb.y)
)
SELECT x, y, z FROM subset_rec;

-- Strata #20: [10] - Non-recursive
-- Rule 10: subset_error(origin1, origin2, point) :- subset(origin1, origin2, point), placeholder_origin(origin1), placeholder_origin(origin2), !known_placeholder_subset(origin1, origin2), [origin1 ≠ origin2].
CREATE VIEW subset_error_strata20 AS 
    SELECT s.x, s.y, s.z
    FROM subset_strata19 s
    JOIN placeholder_origin_strata1 po1 ON s.x = po1.x
    JOIN placeholder_origin_strata1 po2 ON s.y = po2.x
    WHERE s.x != s.y
    AND NOT EXISTS (SELECT 1 FROM known_placeholder_subset_strata2 kps WHERE kps.x = s.x AND kps.y = s.y);

-- Strata #21: [6, 7] - Recursive (loan propagation)
-- Rule 6: origin_contains_loan_on_entry(origin, loan, point2) :- origin_contains_loan_on_entry(origin, loan, point1), cfg_edge(point1, point2), !loan_killed_at(loan, point1), origin_live_on_entry(origin, point2).
-- Rule 7: origin_contains_loan_on_entry(origin2, loan, point) :- origin_contains_loan_on_entry(origin1, loan, point), subset(origin1, origin2, point).
-- Error: Flowlog report count 1316, but we report 310300
CREATE VIEW origin_contains_loan_on_entry_strata21 AS 
WITH RECURSIVE ocle_rec(x, y, z) AS (
    SELECT x, y, z FROM origin_contains_loan_on_entry_strata1
    UNION
    (
        SELECT ocle.x, ocle.y, ce.y
        FROM ocle_rec ocle
        JOIN cfg_edge ce ON ocle.z = ce.x
        JOIN origin_live_on_entry_strata18 ole ON ocle.x = ole.x AND ce.y = ole.y
        WHERE NOT EXISTS (SELECT 1 FROM loan_killed_at lka WHERE lka.x = ocle.y AND lka.y = ocle.z)
        UNION
        SELECT s.y, ocle.y, ocle.z
        FROM ocle_rec ocle
        JOIN subset_strata19 s ON ocle.x = s.x AND ocle.z = s.z
    )
)
SELECT DISTINCT x, y, z FROM ocle_rec;

-- Strata #22: [8] - Non-recursive
-- Rule 8: loan_live_at(loan, point) :- origin_contains_loan_on_entry(origin, loan, point), origin_live_on_entry(origin, point).
CREATE VIEW loan_live_at_strata22 AS 
    SELECT ocle.y AS x, ocle.z AS y
    FROM origin_contains_loan_on_entry_strata21 ocle
    JOIN origin_live_on_entry_strata18 ole ON ocle.x = ole.x AND ocle.z = ole.y;

-- Strata #23: [9] - Non-recursive
-- Rule 9: errors(loan, point) :- loan_invalidated_at(loan, point), loan_live_at(loan, point).
CREATE VIEW errors_strata23 AS 
    SELECT lia.x, lia.y
    FROM loan_invalidated_at lia
    JOIN loan_live_at_strata22 lla ON lia.x = lla.x AND lia.y = lla.y;

-- Final result: count each specified relation separately
SELECT 
    (SELECT COUNT(*) FROM subset_strata19) AS subset_count,
    (SELECT COUNT(*) FROM origin_contains_loan_on_entry_strata21) AS origin_contains_loan_on_entry_count,
    (SELECT COUNT(*) FROM path_maybe_uninitialized_on_exit_strata13) AS path_maybe_uninitialized_on_exit_count,
    (SELECT COUNT(*) FROM var_drop_live_on_entry_strata17) AS var_drop_live_on_entry_count,
    (SELECT COUNT(*) FROM path_maybe_initialized_on_exit_strata12) AS path_maybe_initialized_on_exit_count,
    (SELECT COUNT(*) FROM var_live_on_entry_strata5) AS var_live_on_entry_count,
    (SELECT COUNT(*) FROM path_accessed_at_strata10) AS path_accessed_at_count,
    (SELECT COUNT(*) FROM path_moved_at_strata8) AS path_moved_at_count,
    (SELECT COUNT(*) FROM path_assigned_at_strata7) AS path_assigned_at_count,
    (SELECT COUNT(*) FROM path_begins_with_var_strata9) AS path_begins_with_var_count,
    (SELECT COUNT(*) FROM ancestor_path_strata4) AS ancestor_path_count,
    (SELECT COUNT(*) FROM origin_live_on_entry_strata18) AS origin_live_on_entry_count;
