--
-- Takes version string, splits on the dot, keeps the numbers, returns a comparable list.
--
CREATE OR REPLACE FUNCTION f_make_version(string) AS (
    SELECT list_transform(string_split(string, '.'), x -> IF(x = 'x', 0, TRY_CAST (x AS INTEGER)))
);

--
-- Creates a release line
--
CREATE OR REPLACE FUNCTION f_make_line(orderable_version) AS (
    SELECT IF(
       orderable_version[1] >= 5,
       concat(orderable_version[1], '.x'),
       list_reduce(list_transform(orderable_version[1:2], x -> CAST (x AS VARCHAR)), (x,y) -> concat(x, '.', y))
    )
);


