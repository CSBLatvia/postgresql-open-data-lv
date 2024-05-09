CREATE OR REPLACE PROCEDURE vzd.ciemi_proc(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

--Ciemi, kas vairāk neeksistē.
UPDATE vzd.ciemi
SET date_deleted = CURRENT_DATE
FROM vzd.ciemi u
LEFT JOIN aw_shp.ciemi s ON u.code = s.kods
WHERE s.kods IS NULL
  AND vzd.ciemi.date_deleted IS NULL
  AND vzd.ciemi.id = u.id;

--Ciemi, kuru ģeometrija mainījusies.
UPDATE vzd.ciemi
SET date_deleted = CURRENT_DATE
FROM aw_shp.ciemi s
WHERE ST_Equals(ST_SnapToGrid(vzd.ciemi.geom, 0.0001), ST_SnapToGrid(ST_Multi(s.geom), 0.0001)) = false
  AND vzd.ciemi.code = s.kods
  AND date_deleted IS NULL;

WITH b
AS (
  SELECT code
    ,MAX(code_version) code_version_max
  FROM vzd.ciemi
  GROUP BY code
  )
INSERT INTO vzd.ciemi (
  code
  ,code_version
  ,name
  ,geom
  ,date_created
  )
SELECT s.kods
  ,b.code_version_max + 1
  ,s.nosaukums
  ,ST_Multi(s.geom)
  ,CURRENT_DATE
FROM vzd.ciemi u
INNER JOIN aw_shp.ciemi s ON ST_Equals(ST_SnapToGrid(u.geom, 0.0001), ST_SnapToGrid(ST_Multi(s.geom), 0.0001)) = false
  AND u.code = s.kods
  AND u.date_deleted = CURRENT_DATE
INNER JOIN b ON s.kods = b.code;

--Ciemi, kuru nosaukums mainījies.
UPDATE vzd.ciemi
SET date_deleted = CURRENT_DATE
FROM aw_shp.ciemi s
WHERE ST_Equals(ST_SnapToGrid(vzd.ciemi.geom, 0.0001), ST_SnapToGrid(ST_Multi(s.geom), 0.0001)) = true
  AND vzd.ciemi.code = s.kods
  AND date_deleted IS NULL
  AND name != s.nosaukums;

WITH b
AS (
  SELECT code
    ,MAX(code_version) code_version_max
  FROM vzd.ciemi
  GROUP BY code
  )
INSERT INTO vzd.ciemi (
  code
  ,code_version
  ,name
  ,geom
  ,date_created
  )
SELECT s.kods
  ,b.code_version_max + 1
  ,s.nosaukums
  ,ST_Multi(s.geom)
  ,CURRENT_DATE
FROM vzd.ciemi u
INNER JOIN aw_shp.ciemi s ON ST_Equals(ST_SnapToGrid(u.geom, 0.0001), ST_SnapToGrid(ST_Multi(s.geom), 0.0001)) = true
  AND u.code = s.kods
  AND u.date_deleted = CURRENT_DATE
INNER JOIN b ON s.kods = b.code
WHERE u.name != s.nosaukums;

--Jauni ciemi.
INSERT INTO vzd.ciemi (
  code
  ,code_version
  ,name
  ,geom
  ,date_created
  )
SELECT s.kods
  ,1
  ,s.nosaukums
  ,ST_Multi(s.geom)
  ,CURRENT_DATE
FROM vzd.ciemi u
RIGHT OUTER JOIN aw_shp.ciemi s ON u.code = s.kods
WHERE u.code IS NULL;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.ciemi_proc() TO scheduler;