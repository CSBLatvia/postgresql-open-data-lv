CREATE OR REPLACE PROCEDURE vzd.nivkis(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

DO $$
BEGIN

--Ēkas.
---Vairāk neeksistē.
UPDATE vzd.nivkis_buves uorig
SET date_deleted = CURRENT_DATE - 1 --Šeit un turpmāk nosacījums balstās pieņēmumā, ka procedūra tiek izpildīta dienu pēc jaunāko datu publicēšanas (svētdienās).
FROM vzd.nivkis_buves u
LEFT OUTER JOIN kk_shp.kkbuilding s ON u.code = s.code
WHERE u.object_code < 6000000000
  AND s.code IS NULL
  AND u.date_deleted IS NULL
  AND uorig.code = u.code;

---Ģeometrija, būves kods vai saistītās zemes vienības kadastra apzīmējums mainījies.
UPDATE vzd.nivkis_buves
SET date_deleted = CURRENT_DATE - 1
FROM kk_shp.kkbuilding s
WHERE nivkis_buves.code = s.code
  AND nivkis_buves.object_code < 6000000000
  AND nivkis_buves.date_deleted IS NULL
  AND (
    nivkis_buves.parcel_code != s.parcelcode
    OR nivkis_buves.object_code != s.objectcode::BIGINT
    OR ST_Equals(nivkis_buves.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE
    );

INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode::BIGINT
  ,s.parcelcode
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_buves u
INNER JOIN kk_shp.kkbuilding s ON u.code = s.code
WHERE u.object_code < 6000000000
  AND (
    u.parcel_code != s.parcelcode
    OR u.object_code != s.objectcode::BIGINT
    OR ST_Equals(u.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE
    )
  AND u.date_deleted = CURRENT_DATE - 1
  AND COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

---Jaunas.
INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode::BIGINT
  ,s.parcelcode
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_buves u
RIGHT OUTER JOIN kk_shp.kkbuilding s ON u.code = s.code
WHERE u.code IS NULL
  AND COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

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
  ,s.objectcode::BIGINT
  ,s.parcelcode
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kk_shp.kkbuilding s ON u.code = s.code
WHERE COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

--Inženierbūves.
---Vairāk neeksistē.
UPDATE vzd.nivkis_buves
SET date_deleted = CURRENT_DATE - 1
WHERE object_code >= 6000000000
  AND code NOT IN (
    SELECT code
    FROM kk_shp.kkengineeringstructurepoly
    )
  AND date_deleted IS NULL;

---Ģeometrija, būves kods vai saistītās zemes vienības kadastra apzīmējums mainījies.
UPDATE vzd.nivkis_buves
SET date_deleted = CURRENT_DATE - 1
FROM kk_shp.kkengineeringstructurepoly s
WHERE nivkis_buves.code = s.code
  AND nivkis_buves.object_code >= 6000000000
  AND nivkis_buves.date_deleted IS NULL
  AND (
    nivkis_buves.parcel_code != s.parcelcode
    OR nivkis_buves.object_code != s.objectcode::BIGINT
    OR ST_Equals(nivkis_buves.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE
    );

INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode::BIGINT
  ,s.parcelcode
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_buves u
INNER JOIN kk_shp.kkengineeringstructurepoly s ON u.code = s.code
WHERE u.object_code >= 6000000000
  AND (
    u.parcel_code != s.parcelcode
    OR u.object_code != s.objectcode::BIGINT
    OR ST_Equals(u.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE
    )
  AND u.date_deleted = CURRENT_DATE - 1
  AND COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

---Jaunas.
INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode::BIGINT
  ,s.parcelcode
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_buves u
RIGHT OUTER JOIN kk_shp.kkengineeringstructurepoly s ON u.code = s.code
WHERE u.code IS NULL
  AND COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

---Agrāk dzēstas.
INSERT INTO vzd.nivkis_buves (
  code
  ,object_code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.objectcode::BIGINT
  ,s.parcelcode
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kk_shp.kkengineeringstructurepoly s ON u.code = s.code
WHERE COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

--Zemes vienības.
---Vairāk neeksistē.
UPDATE vzd.nivkis_zemes_vienibas uorig
SET date_deleted = CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibas u
LEFT OUTER JOIN kk_shp.kkparcel s ON u.code = s.code
WHERE s.code IS NULL
  AND u.date_deleted IS NULL
  AND uorig.code = u.code;

---Ģeometrija, tās aktualizēšanas datums vai zemes vienības tips mainījies.
UPDATE vzd.nivkis_zemes_vienibas
SET date_deleted = CURRENT_DATE - 1
FROM kk_shp.kkparcel s
WHERE nivkis_zemes_vienibas.code = s.code
  AND nivkis_zemes_vienibas.date_deleted IS NULL
  AND (
    nivkis_zemes_vienibas.geom_actual_date != s.geom_act_d
    OR nivkis_zemes_vienibas.object_code != s.objectcode::BIGINT
    OR ST_Equals(nivkis_zemes_vienibas.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE
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
  ,s.objectcode::BIGINT
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibas u
INNER JOIN kk_shp.kkparcel s ON u.code = s.code
WHERE (
    u.geom_actual_date != s.geom_act_d
    OR u.object_code != s.objectcode::BIGINT
    OR ST_Equals(u.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE
    )
  AND u.date_deleted = CURRENT_DATE - 1
  AND COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

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
  ,s.objectcode::BIGINT
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibas u
RIGHT OUTER JOIN kk_shp.kkparcel s ON u.code = s.code
WHERE u.code IS NULL
  AND COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

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
  ,s.objectcode::BIGINT
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kk_shp.kkparcel s ON u.code = s.code
WHERE COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

--Zemes vienību daļas.
---Vairāk neeksistē.
UPDATE vzd.nivkis_zemes_vienibu_dalas uorig
SET date_deleted = CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibu_dalas u
LEFT OUTER JOIN kk_shp.kkparcelpart s ON u.code = s.code
WHERE s.code IS NULL
  AND u.date_deleted IS NULL
  AND uorig.code = u.code;

---Ģeometrija vai zemes vienības kadastra apzīmējums mainījies.
UPDATE vzd.nivkis_zemes_vienibu_dalas
SET date_deleted = CURRENT_DATE - 1
FROM kk_shp.kkparcelpart s
WHERE nivkis_zemes_vienibu_dalas.code = s.code
  AND nivkis_zemes_vienibu_dalas.date_deleted IS NULL
  AND (
    nivkis_zemes_vienibu_dalas.parcel_code != s.parcelcode
    OR ST_Equals(nivkis_zemes_vienibu_dalas.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE
    );

INSERT INTO vzd.nivkis_zemes_vienibu_dalas (
  code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.parcelcode
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibu_dalas u
INNER JOIN kk_shp.kkparcelpart s ON u.code = s.code
WHERE (
    u.parcel_code != s.parcelcode
    OR ST_Equals(u.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE
    )
  AND u.date_deleted = CURRENT_DATE - 1
  AND COALESCE(s.geom::TEXT, '') != '';--Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

---Jaunas.
INSERT INTO vzd.nivkis_zemes_vienibu_dalas (
  code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.parcelcode
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_zemes_vienibu_dalas u
RIGHT OUTER JOIN kk_shp.kkparcelpart s ON u.code = s.code
WHERE u.code IS NULL
  AND COALESCE(s.geom::TEXT, '') != '';--Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

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
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kk_shp.kkparcelpart s ON u.code = s.code
WHERE COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

--Apgrūtinājumu ceļa servitūtu teritorijas.
---Vairāk neeksistē.
UPDATE vzd.nivkis_servituti uorig
SET date_deleted = CURRENT_DATE - 1
FROM vzd.nivkis_servituti u
LEFT OUTER JOIN kk_shp.kkwayrestriction s ON u.code = s.code
  AND u.parcel_code = s.parcelcode
WHERE s.code IS NULL
  AND u.date_deleted IS NULL
  AND uorig.code = u.code
  AND uorig.parcel_code = u.parcel_code;

---Ģeometrija mainījusies.
UPDATE vzd.nivkis_servituti
SET date_deleted = CURRENT_DATE - 1
FROM kk_shp.kkwayrestriction s
WHERE nivkis_servituti.code = s.code
  AND nivkis_servituti.parcel_code = s.parcelcode
  AND nivkis_servituti.date_deleted IS NULL
  AND ST_Equals(nivkis_servituti.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE;

INSERT INTO vzd.nivkis_servituti (
  code
  ,parcel_code
  ,geom
  ,date_created
  )
SELECT s.code
  ,s.parcelcode
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_servituti u
INNER JOIN kk_shp.kkwayrestriction s ON u.code = s.code
  AND u.parcel_code = s.parcelcode
WHERE ST_Equals(u.geom, ST_Multi(ST_MakeValid(s.geom))) = FALSE
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
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM vzd.nivkis_servituti u
RIGHT OUTER JOIN kk_shp.kkwayrestriction s ON u.code = s.code
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
  ,ST_Multi(ST_MakeValid(s.geom))
  ,CURRENT_DATE - 1
FROM tmp u
INNER JOIN kk_shp.kkwayrestriction s ON u.code = s.code
  AND u.parcel_code = s.parcelcode
WHERE COALESCE(s.geom::TEXT, '') != ''; --Risinājums tam, ka IS NULL iekš ogr_fdw neatgriež rezultātus.

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis() TO scheduler;