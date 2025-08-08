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
COPY subset_base FROM '/hostdata/borrow/subset_base.csv' (FORMAT CSV, HEADER FALSE);
COPY cfg_edge FROM '/hostdata/borrow/cfg_edge.csv' (FORMAT CSV, HEADER FALSE);
COPY loan_issued_at FROM '/hostdata/borrow/loan_issued_at.csv' (FORMAT CSV, HEADER FALSE);
COPY universal_region FROM '/hostdata/borrow/universal_region.csv' (FORMAT CSV, HEADER FALSE);
COPY var_used_at FROM '/hostdata/borrow/var_used_at.csv' (FORMAT CSV, HEADER FALSE);
COPY loan_killed_at FROM '/hostdata/borrow/loan_killed_at.csv' (FORMAT CSV, HEADER FALSE);
COPY known_placeholder_subset FROM '/hostdata/borrow/known_placeholder_subset.csv' (FORMAT CSV, HEADER FALSE);
COPY var_dropped_at FROM '/hostdata/borrow/var_dropped_at.csv' (FORMAT CSV, HEADER FALSE);
COPY drop_of_var_derefs_origin FROM '/hostdata/borrow/drop_of_var_derefs_origin.csv' (FORMAT CSV, HEADER FALSE);
COPY var_defined_at FROM '/hostdata/borrow/var_defined_at.csv' (FORMAT CSV, HEADER FALSE);
COPY child_path FROM '/hostdata/borrow/child_path.csv' (FORMAT CSV, HEADER FALSE);
COPY path_moved_at_base FROM '/hostdata/borrow/path_moved_at_base.csv' (FORMAT CSV, HEADER FALSE);
COPY path_assigned_at_base FROM '/hostdata/borrow/path_assigned_at_base.csv' (FORMAT CSV, HEADER FALSE);
COPY path_accessed_at_base FROM '/hostdata/borrow/path_accessed_at_base.csv' (FORMAT CSV, HEADER FALSE);
COPY path_is_var FROM '/hostdata/borrow/path_is_var.csv' (FORMAT CSV, HEADER FALSE);
COPY loan_invalidated_at FROM '/hostdata/borrow/loan_invalidated_at.csv' (FORMAT CSV, HEADER FALSE);
COPY use_of_var_derefs_origin FROM '/hostdata/borrow/use_of_var_derefs_origin.csv' (FORMAT CSV, HEADER FALSE);
