PRAGMA threads=64;
PRAGMA memory_limit='250GB';
PRAGMA enable_progress_bar=true;


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
