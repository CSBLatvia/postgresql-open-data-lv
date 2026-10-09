CREATE OR REPLACE PROCEDURE vzd.nivkis(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

DO $$
BEGIN

--Ēkas.
DROP TABLE IF EXISTS kkbuilding_tmp;

CREATE TEMPORARY TABLE kkbuilding_tmp AS
WITH c
AS (
  SELECT code
    ,objectcode::BIGINT objectcode
    ,parcelcode
    ,(ST_Dump(ST_Multi(ST_MakeValid(geom)))).geom geom
  FROM kk_shp.kkbuilding
  )
SELECT code
  ,objectcode
  ,parcelcode
  ,ST_Multi(ST_Union(geom)) geom
FROM c
WHERE ST_GeometryType(geom) IN (
    'ST_Polygon'
    ,'ST_MultiPolygon'
    )
GROUP BY code
  ,objectcode
  ,parcelcode;

CREATE INDEX kkbuilding_tmp_geom_idx ON kkbuilding_tmp USING GIST (geom);

---Vairāk neeksistē.
UPDATE vzd.nivkis_buves uorig
SET date_deleted = CURRENT_DATE - 1 --Šeit un turpmāk nosacījums balstās pieņēmumā, ka procedūra tiek izpildīta dienu pēc jaunāko datu publicēšanas (svētdienās).
FROM vzd.nivkis_buves u
LEFT OUTER JOIN kkbuilding_tmp s ON u.code = s.code
WHERE u.object_code < 6000000000
  AND s.code IS NULL
  AND u.date_deleted IS NULL
  AND uorig.id = u.id;

---Ģeometrija, būves kods vai saistītās zemes vienības kadastra apzīmējums mainījies.
UPDATE vzd.nivkis_buves
SET date_deleted = CURRENT_DATE - 1
FROM kkbuilding_tmp s
WHERE nivkis_buves.code = s.code
  AND nivkis_buves.object_code < 6000000000
  AND nivkis_buves.date_deleted IS NULL
  AND (
    nivkis_buves.parcel_code != s.parcelcode
    OR nivkis_buves.object_code != s.objectcode
    OR ST_Equals(nivkis_buves.geom, s.geom) = FALSE
    );

INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_buves u
INNER JOIN kkbuilding_tmp s ON u.code = s.code
WHERE u.object_code < 6000000000
  AND (
    u.parcel_code != s.parcelcode
    OR u.object_code != s.objectcode
    OR ST_Equals(u.geom, s.geom) = FALSE
    )
  AND u.date_deleted = CURRENT_DATE - 1;

---Jaunas.
INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_buves u
RIGHT OUTER JOIN kkbuilding_tmp s ON u.code = s.code
WHERE u.code IS NULL;

---Agrāk dzēstas.
DROP TABLE IF EXISTS tmp;

CREATE TEMPORARY TABLE tmp AS
SELECT DISTINCT u.code
FROM vzd.nivkis_buves u
LEFT OUTER JOIN vzd.nivkis_buves b ON u.code = b.code
  AND b.date_deleted IS NULL
WHERE b.code IS NULL;

INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kkbuilding_tmp s ON u.code = s.code;

--Inženierbūves.
DROP TABLE IF EXISTS kkengineeringstructurepoly_tmp;

CREATE TEMPORARY TABLE kkengineeringstructurepoly_tmp AS
WITH c
AS (
  SELECT code
    ,objectcode::BIGINT objectcode
    ,parcelcode
    ,(ST_Dump(ST_Multi(ST_MakeValid(geom)))).geom geom
  FROM kk_shp.kkengineeringstructurepoly
  )
SELECT code
  ,objectcode
  ,parcelcode
  ,ST_Multi(ST_Union(geom)) geom
FROM c
WHERE ST_GeometryType(geom) IN (
    'ST_Polygon'
    ,'ST_MultiPolygon'
    )
GROUP BY code
  ,objectcode
  ,parcelcode;

CREATE INDEX kkengineeringstructurepoly_tmp_geom_idx ON kkengineeringstructurepoly_tmp USING GIST (geom);

---Vairāk neeksistē.
UPDATE vzd.nivkis_buves
SET date_deleted = CURRENT_DATE - 1
WHERE object_code >= 6000000000
  AND code NOT IN (
    SELECT code
    FROM kkengineeringstructurepoly_tmp
    )
  AND date_deleted IS NULL;

---Ģeometrija, būves kods vai saistītās zemes vienības kadastra apzīmējums mainījies.
UPDATE vzd.nivkis_buves
SET date_deleted = CURRENT_DATE - 1
FROM kkengineeringstructurepoly_tmp s
WHERE nivkis_buves.code = s.code
  AND nivkis_buves.object_code >= 6000000000
  AND nivkis_buves.date_deleted IS NULL
  AND (
    nivkis_buves.parcel_code != s.parcelcode
    OR nivkis_buves.object_code != s.objectcode
    OR ST_Equals(nivkis_buves.geom, s.geom) = FALSE
    );

INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_buves u
INNER JOIN kkengineeringstructurepoly_tmp s ON u.code = s.code
WHERE u.object_code >= 6000000000
  AND (
    u.parcel_code != s.parcelcode
    OR u.object_code != s.objectcode
    OR ST_Equals(u.geom, s.geom) = FALSE
    )
  AND u.date_deleted = CURRENT_DATE - 1;

---Jaunas.
INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_buves u
RIGHT OUTER JOIN kkengineeringstructurepoly_tmp s ON u.code = s.code
WHERE u.code IS NULL;

---Agrāk dzēstas.
INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kkengineeringstructurepoly_tmp s ON u.code = s.code;

--Zemes vienības.
DROP TABLE IF EXISTS kkparcel_tmp;

CREATE TEMPORARY TABLE kkparcel_tmp AS
WITH c
AS (
  SELECT code
    ,geom_act_d
    ,objectcode::BIGINT objectcode
    ,(ST_Dump(ST_Multi(ST_MakeValid(geom)))).geom geom
  FROM kk_shp.kkparcel
  )
SELECT code
  ,geom_act_d
  ,objectcode
  ,ST_Multi(ST_Union(geom)) geom
FROM c
WHERE ST_GeometryType(geom) IN (
    'ST_Polygon'
    ,'ST_MultiPolygon'
    )
GROUP BY code
  ,geom_act_d
  ,objectcode;

CREATE INDEX kkparcel_tmp_geom_idx ON kkparcel_tmp USING GIST (geom);

---Vairāk neeksistē.
UPDATE vzd.nivkis_zemes_vienibas uorig
SET date_deleted = CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibas u
LEFT OUTER JOIN kkparcel_tmp s ON u.code = s.code
WHERE s.code IS NULL
  AND u.date_deleted IS NULL
  AND uorig.id = u.id;

---Ģeometrija, tās aktualizēšanas datums vai zemes vienības tips mainījies.
UPDATE vzd.nivkis_zemes_vienibas
SET date_deleted = CURRENT_DATE - 1
FROM kkparcel_tmp s
WHERE nivkis_zemes_vienibas.code = s.code
  AND nivkis_zemes_vienibas.date_deleted IS NULL
  AND (
    nivkis_zemes_vienibas.geom_actual_date != s.geom_act_d
    OR nivkis_zemes_vienibas.object_code != s.objectcode
    OR ST_Equals(nivkis_zemes_vienibas.geom, s.geom) = FALSE
    );

INSERT INTO vzd.nivkis_zemes_vienibas (
  code
  ,geom_actual_date
  ,object_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.geom_act_d
  ,s.objectcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibas u
INNER JOIN kkparcel_tmp s ON u.code = s.code
WHERE (
    u.geom_actual_date != s.geom_act_d
    OR u.object_code != s.objectcode
    OR ST_Equals(u.geom, s.geom) = FALSE
    )
  AND u.date_deleted = CURRENT_DATE - 1;

---Jaunas.
INSERT INTO vzd.nivkis_zemes_vienibas (
  code
  ,geom_actual_date
  ,object_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.geom_act_d
  ,s.objectcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibas u
RIGHT OUTER JOIN kkparcel_tmp s ON u.code = s.code
WHERE u.code IS NULL;

---Agrāk dzēstas.
DROP TABLE IF EXISTS tmp;

CREATE TEMPORARY TABLE tmp AS
SELECT DISTINCT u.code
FROM vzd.nivkis_zemes_vienibas u
LEFT OUTER JOIN vzd.nivkis_zemes_vienibas b ON u.code = b.code
  AND b.date_deleted IS NULL
WHERE b.code IS NULL;

INSERT INTO vzd.nivkis_zemes_vienibas (
  code
  ,geom_actual_date
  ,object_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.geom_act_d
  ,s.objectcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kkparcel_tmp s ON u.code = s.code;

--Zemes vienību daļas.
DROP TABLE IF EXISTS kkparcelpart_tmp;

CREATE TEMPORARY TABLE kkparcelpart_tmp AS
WITH c
AS (
  SELECT code
    ,parcelcode
    ,(ST_Dump(ST_Multi(ST_MakeValid(geom)))).geom geom
  FROM kk_shp.kkparcelpart
  )
SELECT code
  ,parcelcode
  ,ST_Multi(ST_Union(geom)) geom
FROM c
WHERE ST_GeometryType(geom) IN (
    'ST_Polygon'
    ,'ST_MultiPolygon'
    )
GROUP BY code
  ,parcelcode;

CREATE INDEX kkparcelpart_tmp_geom_idx ON kkparcelpart_tmp USING GIST (geom);

---Vairāk neeksistē.
UPDATE vzd.nivkis_zemes_vienibu_dalas uorig
SET date_deleted = CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibu_dalas u
LEFT OUTER JOIN kkparcelpart_tmp s ON u.code = s.code
WHERE s.code IS NULL
  AND u.date_deleted IS NULL
  AND uorig.id = u.id;

---Ģeometrija vai zemes vienības kadastra apzīmējums mainījies.
UPDATE vzd.nivkis_zemes_vienibu_dalas
SET date_deleted = CURRENT_DATE - 1
FROM kkparcelpart_tmp s
WHERE nivkis_zemes_vienibu_dalas.code = s.code
  AND nivkis_zemes_vienibu_dalas.date_deleted IS NULL
  AND (
    nivkis_zemes_vienibu_dalas.parcel_code != s.parcelcode
    OR ST_Equals(nivkis_zemes_vienibu_dalas.geom, s.geom) = FALSE
    );

INSERT INTO vzd.nivkis_zemes_vienibu_dalas (
  code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibu_dalas u
INNER JOIN kkparcelpart_tmp s ON u.code = s.code
WHERE (
    u.parcel_code != s.parcelcode
    OR ST_Equals(u.geom, s.geom) = FALSE
    )
  AND u.date_deleted = CURRENT_DATE - 1;

---Jaunas.
INSERT INTO vzd.nivkis_zemes_vienibu_dalas (
  code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibu_dalas u
RIGHT OUTER JOIN kkparcelpart_tmp s ON u.code = s.code
WHERE u.code IS NULL;

---Agrāk dzēstas.
DROP TABLE IF EXISTS tmp;

CREATE TEMPORARY TABLE tmp AS
SELECT DISTINCT u.code
FROM vzd.nivkis_zemes_vienibu_dalas u
LEFT OUTER JOIN vzd.nivkis_zemes_vienibu_dalas b ON u.code = b.code
  AND b.date_deleted IS NULL
WHERE b.code IS NULL;

INSERT INTO vzd.nivkis_zemes_vienibu_dalas (
  code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kkparcelpart_tmp s ON u.code = s.code;

--Apgrūtinājumu ceļa servitūtu teritorijas.
DROP TABLE IF EXISTS kkwayrestriction_tmp;

CREATE TEMPORARY TABLE kkwayrestriction_tmp AS
WITH c
AS (
  SELECT code
    ,parcelcode
    ,(ST_Dump(ST_Multi(ST_MakeValid(geom)))).geom geom
  FROM kk_shp.kkwayrestriction
  )
SELECT code
  ,parcelcode
  ,ST_Multi(ST_Union(geom)) geom
FROM c
WHERE ST_GeometryType(geom) IN (
    'ST_Polygon'
    ,'ST_MultiPolygon'
    )
GROUP BY code
  ,parcelcode;

CREATE INDEX kkwayrestriction_tmp_geom_idx ON kkwayrestriction_tmp USING GIST (geom);

---Vairāk neeksistē.
UPDATE vzd.nivkis_servituti uorig
SET date_deleted = CURRENT_DATE - 1
FROM vzd.nivkis_servituti u
LEFT OUTER JOIN kkwayrestriction_tmp s ON u.code = s.code
  AND u.parcel_code = s.parcelcode
WHERE s.code IS NULL
  AND u.date_deleted IS NULL
  AND uorig.id = u.id;

---Ģeometrija mainījusies.
UPDATE vzd.nivkis_servituti
SET date_deleted = CURRENT_DATE - 1
FROM kkwayrestriction_tmp s
WHERE nivkis_servituti.code = s.code
  AND nivkis_servituti.parcel_code = s.parcelcode
  AND nivkis_servituti.date_deleted IS NULL
  AND ST_Equals(nivkis_servituti.geom, s.geom) = FALSE;

INSERT INTO vzd.nivkis_servituti (
  code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_servituti u
INNER JOIN kkwayrestriction_tmp s ON u.code = s.code
  AND u.parcel_code = s.parcelcode
WHERE ST_Equals(u.geom, s.geom) = FALSE
  AND u.date_deleted = CURRENT_DATE - 1
  AND COALESCE(s.geom::TEXT, '') != '';--Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

---Jaunas.
INSERT INTO vzd.nivkis_servituti (
  code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.parcelcode
  ,s.geom
  ,CURRENT_DATE - 1
FROM vzd.nivkis_servituti u
RIGHT OUTER JOIN kkwayrestriction_tmp s ON u.code = s.code
  AND u.parcel_code = s.parcelcode
WHERE u.code IS NULL
  AND COALESCE(s.geom::TEXT, '') != '';--Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

---Agrāk dzēstas.
DROP TABLE IF EXISTS tmp;

CREATE TEMPORARY TABLE tmp AS
SELECT DISTINCT u.code
  ,u.parcel_code
FROM vzd.nivkis_servituti u
LEFT OUTER JOIN vzd.nivkis_servituti b ON u.code = b.code
  AND u.parcel_code = b.parcel_code
  AND b.date_deleted IS NULL
WHERE b.code IS NULL;

INSERT INTO vzd.nivkis_servituti (
  code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.parcelcode
  ,ST_Multi(s.geom)
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kkwayrestriction_tmp s ON u.code = s.code
  AND u.parcel_code = s.parcelcode
WHERE COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis() TO scheduler;
