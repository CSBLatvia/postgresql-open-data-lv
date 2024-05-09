CREATE TEMPORARY TABLE eka_atrib AS
WITH g
AS (
  SELECT adr_cd
    ,geom
  FROM vzd.adreses_ekas
  
  UNION
  
  SELECT adr_cd
    ,geom
  FROM vzd.adreses_ekas_koord_del
  )
SELECT a.adr_cd
  ,a.atrib
  ,g.geom
FROM vzd.adreses a
LEFT JOIN g ON a.adr_cd = g.adr_cd
WHERE a.tips_cd = 108
  AND a.statuss = 'EKS';

CREATE INDEX eka_atrib_geom_idx ON eka_atrib USING GIST (geom);

ANALYZE eka_atrib;

CREATE TEMPORARY TABLE eka_atrib_voronoi AS
SELECT NULL atrib
  ,(ST_Dump(ST_VoronoiPolygons(a.geom))).geom geom
FROM (
  SELECT ST_Collect(geom) geom
  FROM eka_atrib
  ) a;

CREATE INDEX eka_atrib_voronoi_geom_idx ON eka_atrib_voronoi USING GIST (geom);

ANALYZE eka_atrib_voronoi;

UPDATE eka_atrib_voronoi
SET atrib = s.atrib
FROM eka_atrib s
WHERE ST_Intersects(eka_atrib_voronoi.geom, s.geom);

--Izgriež pēc valsts robežas.
CREATE TEMPORARY TABLE postal_codes_tmp AS
SELECT atrib
  ,ST_Multi(ST_Union(geom)) geom
FROM eka_atrib_voronoi
GROUP BY atrib;

CREATE INDEX postal_codes_tmp_geom_idx ON postal_codes_tmp USING GIST (geom);

ANALYZE postal_codes_tmp;

UPDATE postal_codes_tmp
SET geom = ST_Multi(ST_Intersection(postal_codes_tmp.geom, s.geom))
FROM (
  SELECT ST_Buffer(ST_Collect(geom), 0) geom
  FROM vzd.teritorialas_vienibas_yyyymmdd
  ) s
WHERE ST_Intersects(postal_codes_tmp.geom, ST_ExteriorRing(s.geom));

ANALYZE postal_codes_tmp;

--Sašķeļ teritorijas pa teritoriālo vienību robežām.
CREATE TEMPORARY TABLE postal_codes_tmp2 (
  id SERIAL PRIMARY KEY
  ,atrib CHARACTER VARYING(7)
  ,l1_code CHARACTER VARYING(7)
  ,geom geometry(Polygon, 3059)
  );

WITH x
AS (
  SELECT a.atrib
    ,b.l1_code
    ,ST_Intersection(a.geom, b.geom) geom
  FROM postal_codes_tmp a
  INNER JOIN vzd.teritorialas_vienibas_yyyymmdd b ON ST_Intersects(a.geom, b.geom)
  )
  ,a
AS (
  SELECT atrib
    ,l1_code
    ,(ST_Dump(geom)).geom geom
  FROM x
  )
INSERT INTO postal_codes_tmp2 (
  atrib
  ,l1_code
  ,geom
  )
SELECT atrib
  ,l1_code
  ,geom
FROM a;

CREATE INDEX postal_codes_tmp2_geom_idx ON postal_codes_tmp2 USING GIST (geom);

ANALYZE postal_codes_tmp2;

--Apvieno teritorijas bez ēkām teritoriālās vienības ietvaros.
---ID ar šādām teritorijām.
CREATE TEMPORARY TABLE postal_codes_wo_buildings AS
WITH c
AS (
  SELECT b.id
    ,COUNT(*) cnt
  FROM postal_codes_tmp2 b
  INNER JOIN eka_atrib c ON ST_Intersects(b.geom, c.geom)
  GROUP BY b.id
  )
SELECT b.id
FROM postal_codes_tmp2 b
LEFT OUTER JOIN c ON b.id = c.id
WHERE c.cnt IS NULL;

---Apvieno.
INSERT INTO postal_codes_tmp2 (
  l1_code
  ,geom
  )
SELECT b.l1_code
  ,(ST_Dump(ST_Union(b.geom))).geom geom
FROM postal_codes_tmp2 b
INNER JOIN postal_codes_wo_buildings c ON b.id = c.id
GROUP BY b.l1_code;

ANALYZE postal_codes_tmp2;

DELETE
FROM postal_codes_tmp2
WHERE id IN (
    SELECT id
    FROM postal_codes_wo_buildings
    );

ANALYZE postal_codes_tmp2;

--Teritoriālās vienības ietvaros teritorijas bez ēkām pievieno teritorijām ar ēkām, ar kurām ir garākā kopējā robeža.
CREATE TEMPORARY TABLE postal_codes_tmp3 AS
WITH a
AS (
  SELECT b.id
    ,b.atrib
    ,b.l1_code
    ,b.geom
    ,d.id border_id
    ,ST_Length(ST_Intersection(b.geom, d.geom)) border_length
  FROM postal_codes_tmp2 b
  INNER JOIN postal_codes_tmp2 d ON ST_Intersects(b.geom, d.geom)
  WHERE b.atrib IS NULL
    AND b.l1_code = d.l1_code
    AND b.id > d.id
  )
  ,e
AS (
  SELECT id
    ,MAX(border_length) border_length
  FROM a
  GROUP BY id
  )
  ,p
AS (
  SELECT a.border_id id
    ,a.geom
  FROM a
  INNER JOIN e ON a.id = e.id
    AND a.border_length = e.border_length
  
  UNION ALL
  
  SELECT id
    ,geom
  FROM postal_codes_tmp2
  WHERE atrib IS NOT NULL
  )
SELECT p.id
  ,ST_Union(p.geom) geom
FROM p
INNER JOIN postal_codes_tmp2 r ON p.id = r.id
GROUP BY p.id;

CREATE INDEX postal_codes_tmp3_geom_idx ON postal_codes_tmp3 USING GIST (geom);

ANALYZE postal_codes_tmp3;

CREATE TEMPORARY TABLE postal_codes_tmp4 AS
SELECT a.atrib
  ,(ST_Dump(ST_Union(b.geom))).geom geom
FROM postal_codes_tmp2 a
INNER JOIN postal_codes_tmp3 b ON a.id = b.id
GROUP BY a.atrib;

CREATE INDEX postal_codes_tmp4_geom_idx ON postal_codes_tmp4 USING GIST (geom);

ANALYZE postal_codes_tmp4;

--Identificē un pievieno tukšumus (teritoriālo vienību daļas bez adrešu punktiem).
WITH a
AS (
  SELECT ST_Union(geom) geom
  FROM postal_codes_tmp4
  )
  ,b
AS (
  SELECT ST_Buffer(ST_Union(geom), - 1) geom
  FROM vzd.teritorialas_vienibas_yyyymmdd
  )
INSERT INTO postal_codes_tmp4 (geom)
SELECT (ST_Dump(ST_Difference(b.geom, a.geom))).geom geom
FROM a
  ,b;

--Nosaka izplatītāko pasta indeksu teritoriālajā vienībā un piešķir to iepriekš pievienotajiem tukšumiem.
CREATE TEMPORARY TABLE l1_code_top_postal_code AS
WITH c
AS (
  SELECT b.atrib
    ,a.l1_code
    ,ST_Union(ST_Intersection(a.geom, b.geom)) geom
  FROM vzd.teritorialas_vienibas_yyyymmdd a
  INNER JOIN postal_codes_tmp4 b ON ST_Intersects(a.geom, b.geom)
  GROUP BY b.atrib
    ,a.l1_code
  )
  ,d
AS (
  SELECT ROW_NUMBER() OVER (
      PARTITION BY l1_code ORDER BY ST_Area(geom) DESC
      ) rn
    ,atrib
    ,l1_code
    ,geom
  FROM c
  )
SELECT l1_code
  ,atrib
FROM d
WHERE rn = 1;

UPDATE postal_codes_tmp4 u
SET atrib = c.atrib
FROM (
  SELECT l1_code
    ,ST_PointOnSurface((ST_Dump(geom)).geom) geom
  FROM vzd.teritorialas_vienibas_yyyymmdd
  ) s
INNER JOIN l1_code_top_postal_code c ON c.l1_code = s.l1_code
WHERE ST_Contains(u.geom, s.geom)
  AND u.atrib IS NULL;

ANALYZE postal_codes_tmp4;

CREATE TEMPORARY TABLE postal_codes_tmp5 AS
SELECT atrib
  ,ROUND(ST_Area((ST_Dump(ST_Union(geom))).geom)::NUMERIC, 0) area
  ,(ST_Dump(ST_Union(geom))).geom geom
FROM postal_codes_tmp4
GROUP BY atrib;

CREATE INDEX postal_codes_tmp5_geom_idx ON postal_codes_tmp5 USING GIST (geom);

ANALYZE postal_codes_tmp5;

--TODO: apvieno nelielas teritorijas ar maz adresēm ar teritorijām, ar kurām ir garākā kopējā robeža.

DROP TABLE IF EXISTS vzd.postal_codes;

CREATE TABLE vzd.postal_codes (
  id serial PRIMARY KEY
  ,atrib CHARACTER VARYING(7)
  ,geom geometry(MultiPolygon, 3059)
  ,geom_cntr geometry(Point, 3059)
  );

INSERT INTO vzd.postal_codes (
  atrib
  ,geom
  )
SELECT atrib
  ,ST_Multi(ST_Union(geom))
FROM postal_codes_tmp5
GROUP BY atrib;

CREATE INDEX postal_codes_geom_idx ON vzd.postal_codes USING GIST (geom);

ANALYZE vzd.postal_codes;

--Aprēķina centroīdu koordinātas.
UPDATE vzd.postal_codes
SET geom_cntr = (ST_MaximumInscribedCircle(geom)).center;

CREATE INDEX postal_codes_geom_cntr_idx ON vzd.postal_codes USING GIST (geom_cntr);

ANALYZE vzd.postal_codes;

COMMENT ON TABLE vzd.postal_codes IS 'Pasta indeksi pēc dd.mm.yyyy. VARIS datiem';