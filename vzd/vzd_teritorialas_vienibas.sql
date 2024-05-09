CREATE OR REPLACE PROCEDURE vzd.teritorialas_vienibas(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

DO $$
BEGIN

EXECUTE 'DROP TABLE IF EXISTS vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD');

EXECUTE 'CREATE TABLE vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || '(
  id SERIAL PRIMARY KEY
  ,l1_code VARCHAR(7) NOT NULL
  ,l1_name VARCHAR(50) NOT NULL
  ,l1_type SMALLINT NOT NULL
  ,l0_code VARCHAR(7) NULL
  ,l0_name VARCHAR(50) NULL
  ,l0_type SMALLINT NULL
  ,nuts3_code VARCHAR(5) NULL
  ,nuts3_name VARCHAR(50) NULL
  ,geom geometry(MultiPolygon, 3059) NOT NULL
  )';

EXECUTE 'CREATE INDEX teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || '_geom_idx ON vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || ' USING GIST (geom)';

--Pagasti
EXECUTE 'INSERT INTO vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || ' (
  l1_code
  ,l1_name
  ,l1_type
  ,geom
  )
SELECT atrib
  ,REPLACE(nosaukums, ''pag.'', ''pagasts'')
  ,7
  ,ST_Multi(geom)
FROM aw_shp.adm_rob
WHERE tips_cd = 105';

--Valstspilsētas, kas veido pašvaldības
EXECUTE 'INSERT INTO vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || ' (
  l1_code
  ,l1_name
  ,l1_type
  ,geom
  ,l0_code
  ,l0_name
  ,l0_type
  )
SELECT atrib
  ,nosaukums
  ,1
  ,ST_Multi(geom)
  ,atrib
  ,nosaukums
  ,1
FROM aw_shp.adm_rob
WHERE tips_cd = 104
  AND vkur_tips = 101';

--Novadu pilsētas
EXECUTE 'INSERT INTO vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || ' (
  l1_code
  ,l1_name
  ,l1_type
  ,geom
  )
SELECT atrib
  ,nosaukums
  ,6
  ,ST_Multi(geom)
FROM aw_shp.adm_rob
WHERE tips_cd = 104
  AND vkur_tips = 113';

--Novadi bez pagastiem un pilsētām
EXECUTE 'INSERT INTO vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || ' (
  l1_code
  ,l1_name
  ,l1_type
  ,geom
  ,l0_code
  ,l0_name
  ,l0_type
  )
SELECT a.atrib
  ,REPLACE(a.nosaukums, ''nov.'', ''novads'')
  ,5
  ,ST_Multi(a.geom)
  ,a.atrib
  ,REPLACE(a.nosaukums, ''nov.'', ''novads'')
  ,5
FROM aw_shp.adm_rob a
LEFT OUTER JOIN vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || ' b ON ST_Contains(ST_Multi(a.geom), b.geom)
WHERE b.l1_code IS NULL
  AND a.tips_cd = 113';

--Novadi ar pagastiem un pilsētām
EXECUTE 'UPDATE vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || '
SET l0_code = s.atrib
  ,l0_name = REPLACE(s.nosaukums, ''nov.'', ''novads'')
  ,l0_type = 5
FROM aw_shp.adm_rob s
WHERE ST_Contains(ST_Multi(s.geom), vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || '.geom)
  AND l0_code IS NULL
  AND s.tips_cd = 113';

--NUTS3 kodi
EXECUTE 'UPDATE vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || '
SET nuts3_code = a.code_parent
FROM csp.atu_nuts_codes a
WHERE vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || '.l0_code = a.code
  AND CAST(a.level AS SMALLINT) = 3
  AND a.validity_period_end LIKE ''''';

--NUTS3 nosaukumi
EXECUTE 'UPDATE vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || '
SET nuts3_name = a.name
FROM csp.atu_nuts_codes a
WHERE vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || '.nuts3_code = a.code
  AND CAST(a.level AS SMALLINT) = 1
  AND a.validity_period_end LIKE ''''';

--Labo ģeometrijas ar kļūdainu pierakstu
EXECUTE 'UPDATE vzd.teritorialas_vienibas_' || to_char(current_timestamp, 'YYYYMMDD') || '
SET geom = ST_MakeValid(geom)
WHERE ST_IsValid(geom) = false';

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.teritorialas_vienibas() TO scheduler;