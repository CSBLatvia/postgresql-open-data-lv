CREATE OR REPLACE PROCEDURE vzd.nitis_geom(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

--Apvieno darījumus.
CREATE TEMPORARY TABLE darijumi (
  id serial PRIMARY KEY
  ,darijuma_id INTEGER NOT NULL
  ,darijuma_datums DATE NOT NULL
  );

INSERT INTO darijumi (
  darijuma_id
  ,darijuma_datums
  )
SELECT darijuma_id
  ,darijuma_datums
FROM vzd.nitis_zv

UNION

SELECT darijuma_id
  ,darijuma_datums
FROM vzd.nitis_zvb

UNION

SELECT darijuma_id
  ,darijuma_datums
FROM vzd.nitis_b

UNION

SELECT darijuma_id
  ,darijuma_datums
FROM vzd.nitis_tg;

--Zemes vienībām.
/*
UPDATE vzd.nitis_zv_kad_apz
SET geom = NULL;
*/

---Kadastra datos ir saglabāta attiecīgā zemes vienība.
CREATE TEMPORARY TABLE min_date AS
SELECT MIN(date_created) min_date
FROM vzd.nivkis_zemes_vienibas;

WITH s
AS (
  SELECT a.darijuma_id
    ,a.kad_apz
    ,c.geom
  FROM vzd.nitis_zv_kad_apz a
  CROSS JOIN min_date m
  INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
  INNER JOIN vzd.nivkis_zemes_vienibas c ON (
      b.darijuma_datums >= c.date_created
      OR (
        b.darijuma_datums < m.min_date
        AND c.date_created = m.min_date
        )
      )
    AND (
      b.darijuma_datums < c.date_deleted
      OR c.date_deleted IS NULL
      )
    AND a.kad_apz = c.code
  WHERE a.geom IS NULL
  )
UPDATE vzd.nitis_zv_kad_apz
SET geom = s.geom
FROM s
WHERE nitis_zv_kad_apz.darijuma_id = s.darijuma_id
  AND nitis_zv_kad_apz.kad_apz = s.kad_apz
  AND nitis_zv_kad_apz.geom IS NULL;

----Trūkstošajiem gadījumiem piesaista laika ziņā tuvāko nākamo ierakstu.
WITH z
AS (
  SELECT a.code
    ,MIN(a.date_created) date_created
  FROM vzd.nivkis_zemes_vienibas a
  INNER JOIN vzd.nitis_zv_kad_apz b ON a.code = b.kad_apz
  INNER JOIN darijumi c ON b.darijuma_id = c.darijuma_id
  WHERE a.date_created > c.darijuma_datums
    AND b.geom IS NULL
  GROUP BY a.code
  )
  ,s
AS (
  SELECT a.darijuma_id
    ,a.kad_apz
    ,c.geom
  FROM vzd.nitis_zv_kad_apz a
  INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
  INNER JOIN vzd.nivkis_zemes_vienibas c ON a.kad_apz = c.code
  INNER JOIN z ON c.code = z.code
    AND z.date_created = c.date_created
  WHERE a.geom IS NULL
  )
UPDATE vzd.nitis_zv_kad_apz
SET geom = s.geom
FROM s
WHERE nitis_zv_kad_apz.darijuma_id = s.darijuma_id
  AND nitis_zv_kad_apz.kad_apz = s.kad_apz;

---Ja kadastra datos nav saglabāta attiecīgā zemes vienība, piesaista centroīdu no tās zemes vienības kadastra grupas ietvaros, kuras kadastra apzīmējums ir vistuvākais trūkstošajam (ja atšķirība ar apzīmējumu, kas ir lielāks, ir vienāda ar apzīmējumu, kas ir mazāks, izvēlas apzīmējumu, kas ir mazāks).
CREATE TEMPORARY TABLE zv_p_du AS
SELECT a.darijuma_id
  ,a.kad_apz
  ,c.code
  ,c.geom
  ,a.kad_apz::BIGINT - c.code::BIGINT diff
FROM vzd.nitis_zv_kad_apz a
CROSS JOIN min_date m
INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
INNER JOIN vzd.nivkis_zemes_vienibas c ON (
    b.darijuma_datums >= c.date_created
    OR (
      b.darijuma_datums < m.min_date
      AND c.date_created = m.min_date
      )
    )
  AND (
    b.darijuma_datums < c.date_deleted
    OR c.date_deleted IS NULL
    )
  AND a.kad_apz::BIGINT > c.code::BIGINT
WHERE a.geom IS NULL
  AND LEFT(a.kad_apz, 7) = LEFT(c.code, 7);--Sakrīt kadastra grupa.

CREATE TEMPORARY TABLE zv_p_d1 AS
SELECT a.darijuma_id
  ,a.kad_apz
  ,c.code
  ,c.geom
  ,c.code::BIGINT - a.kad_apz::BIGINT diff
FROM vzd.nitis_zv_kad_apz a
CROSS JOIN min_date m
INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
INNER JOIN vzd.nivkis_zemes_vienibas c ON (
    b.darijuma_datums >= c.date_created
    OR (
      b.darijuma_datums < m.min_date
      AND c.date_created = m.min_date
      )
    )
  AND (
    b.darijuma_datums < c.date_deleted
    OR c.date_deleted IS NULL
    )
  AND a.kad_apz::BIGINT < c.code::BIGINT
WHERE a.geom IS NULL
  AND LEFT(a.kad_apz, 7) = LEFT(c.code, 7);--Sakrīt kadastra grupa.

CREATE TEMPORARY TABLE zv_p_eu AS
SELECT darijuma_id
  ,kad_apz
  ,MIN(diff) diff
FROM zv_p_du
GROUP BY darijuma_id
  ,kad_apz;

CREATE TEMPORARY TABLE zv_p_cm AS
SELECT DISTINCT d.*
FROM zv_p_du d
INNER JOIN zv_p_eu e ON d.darijuma_id = e.darijuma_id
  AND d.kad_apz = e.kad_apz
  AND d.diff = e.diff;

CREATE TEMPORARY TABLE zv_p_el AS
SELECT darijuma_id
  ,kad_apz
  ,MIN(diff) diff
FROM zv_p_d1
GROUP BY darijuma_id
  ,kad_apz;

INSERT INTO zv_p_cm
SELECT DISTINCT d.*
FROM zv_p_d1 d
INNER JOIN zv_p_el e ON d.darijuma_id = e.darijuma_id
  AND d.kad_apz = e.kad_apz
  AND d.diff = e.diff;

CREATE TEMPORARY TABLE zv_p_cm2 AS
SELECT darijuma_id
  ,kad_apz
  ,MIN(diff) diff
FROM zv_p_cm
GROUP BY darijuma_id
  ,kad_apz;

CREATE TEMPORARY TABLE zv_p_c2 AS
SELECT d.*
FROM zv_p_cm d
INNER JOIN zv_p_cm2 e ON d.darijuma_id = e.darijuma_id
  AND d.kad_apz = e.kad_apz
  AND d.diff = e.diff;

CREATE TEMPORARY TABLE zv_p_cc AS
SELECT darijuma_id
  ,kad_apz
  ,COUNT(*) cnt
FROM zv_p_c2
GROUP BY darijuma_id
  ,kad_apz;

CREATE TEMPORARY TABLE zv_p AS
WITH c3
AS (
  SELECT c2.darijuma_id
    ,c2.kad_apz
    ,c2.code
  FROM zv_p_c2 c2
  INNER JOIN zv_p_cc cc ON c2.darijuma_id = cc.darijuma_id
    AND c2.kad_apz = cc.kad_apz
  WHERE cc.cnt = 1
  
  UNION
  
  SELECT c2.darijuma_id
    ,c2.kad_apz
    ,LPAD(MIN(c2.code::BIGINT)::TEXT, 11, '00000000000') code
  FROM zv_p_c2 c2
  INNER JOIN zv_p_cc cc ON c2.darijuma_id = cc.darijuma_id
    AND c2.kad_apz = cc.kad_apz
  WHERE cc.cnt > 1
  GROUP BY c2.darijuma_id
    ,c2.kad_apz
  )
  ,c
AS (
  SELECT c3.*
    ,c2.geom
  FROM c3
  INNER JOIN zv_p_c2 c2 ON c3.darijuma_id = c2.darijuma_id
    AND c3.kad_apz = c2.kad_apz
    AND c3.code = c2.code
  )
SELECT a.darijuma_id
  ,a.kad_apz
  ,c.geom
FROM vzd.nitis_zv_kad_apz a
INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
INNER JOIN c ON b.darijuma_id = c.darijuma_id
  AND a.kad_apz = c.kad_apz
WHERE a.geom IS NULL;

UPDATE vzd.nitis_zv_kad_apz
SET geom = ST_PointOnSurface(s.geom)
FROM zv_p s
WHERE nitis_zv_kad_apz.darijuma_id = s.darijuma_id
  AND nitis_zv_kad_apz.kad_apz = s.kad_apz
  AND nitis_zv_kad_apz.geom IS NULL;

--Būvēm.
/*
UPDATE vzd.nitis_b_kad_apz
SET geom = NULL;
*/

---Kadastra datos ir saglabāta attiecīgā būve.
DROP TABLE min_date;

CREATE TEMPORARY TABLE min_date AS
SELECT MIN(date_created) min_date
FROM vzd.nivkis_buves;

WITH s
AS (
  SELECT a.darijuma_id
    ,a.kad_apz
    ,c.geom
  FROM vzd.nitis_b_kad_apz a
  CROSS JOIN min_date m
  INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
  INNER JOIN vzd.nivkis_buves c ON (
      b.darijuma_datums >= c.date_created
      OR (
        b.darijuma_datums < m.min_date
        AND c.date_created = m.min_date
        )
      )
    AND (
      b.darijuma_datums < c.date_deleted
      OR c.date_deleted IS NULL
      )
    AND a.kad_apz = c.code
  WHERE a.geom IS NULL
  )
UPDATE vzd.nitis_b_kad_apz
SET geom = s.geom
FROM s
WHERE nitis_b_kad_apz.darijuma_id = s.darijuma_id
  AND nitis_b_kad_apz.kad_apz = s.kad_apz
  AND nitis_b_kad_apz.geom IS NULL;

----Trūkstošajiem gadījumiem piesaista laika ziņā tuvāko nākamo ierakstu.
WITH z
AS (
  SELECT a.code
    ,MIN(a.date_created) date_created
  FROM vzd.nivkis_buves a
  INNER JOIN vzd.nitis_b_kad_apz b ON a.code = b.kad_apz
  INNER JOIN darijumi c ON b.darijuma_id = c.darijuma_id
  WHERE a.date_created > c.darijuma_datums
    AND b.geom IS NULL
  GROUP BY a.code
  )
  ,s
AS (
  SELECT a.darijuma_id
    ,a.kad_apz
    ,c.geom
  FROM vzd.nitis_b_kad_apz a
  INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
  INNER JOIN vzd.nivkis_buves c ON a.kad_apz = c.code
  INNER JOIN z ON c.code = z.code
    AND z.date_created = c.date_created
  WHERE a.geom IS NULL
  )
UPDATE vzd.nitis_b_kad_apz
SET geom = s.geom
FROM s
WHERE nitis_b_kad_apz.darijuma_id = s.darijuma_id
  AND nitis_b_kad_apz.kad_apz = s.kad_apz;

---Ja kadastra datos nav saglabāta attiecīgā būve, piesaista centroīdu no tās būves kadastra grupas ietvaros, kuras kadastra apzīmējums ir vistuvākais trūkstošajam (ja atšķirība ar apzīmējumu, kas ir lielāks, ir vienāda ar apzīmējumu, kas ir mazāks, izvēlas apzīmējumu, kas ir mazāks).
CREATE TEMPORARY TABLE b_p_du AS
SELECT a.darijuma_id
  ,a.kad_apz
  ,c.code
  ,c.geom
  ,a.kad_apz::BIGINT - c.code::BIGINT diff
FROM vzd.nitis_b_kad_apz a
CROSS JOIN min_date m
INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
INNER JOIN vzd.nivkis_buves c ON (
    b.darijuma_datums >= c.date_created
    OR (
      b.darijuma_datums < m.min_date
      AND c.date_created = m.min_date
      )
    )
  AND (
    b.darijuma_datums < c.date_deleted
    OR c.date_deleted IS NULL
    )
  AND a.kad_apz::BIGINT > c.code::BIGINT
WHERE a.geom IS NULL
  AND LEFT(a.kad_apz, 7) = LEFT(c.code, 7);--Sakrīt kadastra grupa.

CREATE TEMPORARY TABLE b_p_d1 AS
SELECT a.darijuma_id
  ,a.kad_apz
  ,c.code
  ,c.geom
  ,c.code::BIGINT - a.kad_apz::BIGINT diff
FROM vzd.nitis_b_kad_apz a
CROSS JOIN min_date m
INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
INNER JOIN vzd.nivkis_buves c ON (
    b.darijuma_datums >= c.date_created
    OR (
      b.darijuma_datums < m.min_date
      AND c.date_created = m.min_date
      )
    )
  AND (
    b.darijuma_datums < c.date_deleted
    OR c.date_deleted IS NULL
    )
  AND a.kad_apz::BIGINT < c.code::BIGINT
WHERE a.geom IS NULL
  AND LEFT(a.kad_apz, 7) = LEFT(c.code, 7);--Sakrīt kadastra grupa.

CREATE TEMPORARY TABLE b_p_eu AS
SELECT darijuma_id
  ,kad_apz
  ,MIN(diff) diff
FROM b_p_du
GROUP BY darijuma_id
  ,kad_apz;

CREATE TEMPORARY TABLE b_p_cm AS
SELECT DISTINCT d.*
FROM b_p_du d
INNER JOIN b_p_eu e ON d.darijuma_id = e.darijuma_id
  AND d.kad_apz = e.kad_apz
  AND d.diff = e.diff;

CREATE TEMPORARY TABLE b_p_el AS
SELECT darijuma_id
  ,kad_apz
  ,MIN(diff) diff
FROM b_p_d1
GROUP BY darijuma_id
  ,kad_apz;

INSERT INTO b_p_cm
SELECT DISTINCT d.*
FROM b_p_d1 d
INNER JOIN b_p_el e ON d.darijuma_id = e.darijuma_id
  AND d.kad_apz = e.kad_apz
  AND d.diff = e.diff;

CREATE TEMPORARY TABLE b_p_cm2 AS
SELECT darijuma_id
  ,kad_apz
  ,MIN(diff) diff
FROM b_p_cm
GROUP BY darijuma_id
  ,kad_apz;

CREATE TEMPORARY TABLE b_p_c2 AS
SELECT d.*
FROM b_p_cm d
INNER JOIN b_p_cm2 e ON d.darijuma_id = e.darijuma_id
  AND d.kad_apz = e.kad_apz
  AND d.diff = e.diff;

CREATE TEMPORARY TABLE b_p_cc AS
SELECT darijuma_id
  ,kad_apz
  ,COUNT(*) cnt
FROM b_p_c2
GROUP BY darijuma_id
  ,kad_apz;

CREATE TEMPORARY TABLE b_p AS
WITH c3
AS (
  SELECT c2.darijuma_id
    ,c2.kad_apz
    ,c2.code
  FROM b_p_c2 c2
  INNER JOIN b_p_cc cc ON c2.darijuma_id = cc.darijuma_id
    AND c2.kad_apz = cc.kad_apz
  WHERE cc.cnt = 1
  
  UNION
  
  SELECT c2.darijuma_id
    ,c2.kad_apz
    ,LPAD(MIN(c2.code::BIGINT)::TEXT, 14, '00000000000000') code
  FROM b_p_c2 c2
  INNER JOIN b_p_cc cc ON c2.darijuma_id = cc.darijuma_id
    AND c2.kad_apz = cc.kad_apz
  WHERE cc.cnt > 1
  GROUP BY c2.darijuma_id
    ,c2.kad_apz
  )
  ,c
AS (
  SELECT c3.*
    ,c2.geom
  FROM c3
  INNER JOIN b_p_c2 c2 ON c3.darijuma_id = c2.darijuma_id
    AND c3.kad_apz = c2.kad_apz
    AND c3.code = c2.code
  )
SELECT a.darijuma_id
  ,a.kad_apz
  ,c.geom
FROM vzd.nitis_b_kad_apz a
INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
INNER JOIN c ON b.darijuma_id = c.darijuma_id
  AND a.kad_apz = c.kad_apz
WHERE a.geom IS NULL;

UPDATE vzd.nitis_b_kad_apz
SET geom = ST_PointOnSurface(s.geom)
FROM b_p s
WHERE nitis_b_kad_apz.darijuma_id = s.darijuma_id
  AND nitis_b_kad_apz.kad_apz = s.kad_apz
  AND nitis_b_kad_apz.geom IS NULL;

--Telpu grupām.
/*
UPDATE vzd.nitis_tg_kad_apz
SET geom = NULL;
*/

---Kadastra datos ir saglabāta attiecīgā būve.
WITH s
AS (
  SELECT a.darijuma_id
    ,a.kad_apz
    ,c.geom
  FROM vzd.nitis_tg_kad_apz a
  CROSS JOIN min_date m
  INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
  INNER JOIN vzd.nivkis_buves c ON (
      b.darijuma_datums >= c.date_created
      OR (
        b.darijuma_datums < m.min_date
        AND c.date_created = m.min_date
        )
      )
    AND (
      b.darijuma_datums < c.date_deleted
      OR c.date_deleted IS NULL
      )
    AND LEFT(a.kad_apz, 14) = c.code
  WHERE a.geom IS NULL
  )
UPDATE vzd.nitis_tg_kad_apz
SET geom = s.geom
FROM s
WHERE nitis_tg_kad_apz.darijuma_id = s.darijuma_id
  AND nitis_tg_kad_apz.kad_apz = s.kad_apz
  AND nitis_tg_kad_apz.geom IS NULL;

----Trūkstošajiem gadījumiem piesaista laika ziņā tuvāko nākamo ierakstu.
WITH z
AS (
  SELECT a.code
    ,MIN(a.date_created) date_created
  FROM vzd.nivkis_buves a
  INNER JOIN vzd.nitis_tg_kad_apz b ON a.code = LEFT(b.kad_apz, 14)
  INNER JOIN darijumi c ON b.darijuma_id = c.darijuma_id
  WHERE a.date_created > c.darijuma_datums
    AND b.geom IS NULL
  GROUP BY a.code
  )
  ,s
AS (
  SELECT a.darijuma_id
    ,a.kad_apz
    ,c.geom
  FROM vzd.nitis_tg_kad_apz a
  INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
  INNER JOIN vzd.nivkis_buves c ON LEFT(a.kad_apz, 14) = c.code
  INNER JOIN z ON c.code = z.code
    AND z.date_created = c.date_created
  WHERE a.geom IS NULL
  )
UPDATE vzd.nitis_tg_kad_apz
SET geom = s.geom
FROM s
WHERE nitis_tg_kad_apz.darijuma_id = s.darijuma_id
  AND nitis_tg_kad_apz.kad_apz = s.kad_apz;

---Ja kadastra datos nav saglabāta attiecīgā būve, piesaista centroīdu no tās būves kadastra grupas ietvaros, kuras kadastra apzīmējums ir vistuvākais trūkstošajam (ja atšķirība ar apzīmējumu, kas ir lielāks, ir vienāda ar apzīmējumu, kas ir mazāks, izvēlas apzīmējumu, kas ir mazāks).
CREATE TEMPORARY TABLE tg_p_du AS
SELECT a.darijuma_id
  ,a.kad_apz
  ,c.code
  ,c.geom
  ,LEFT(a.kad_apz, 14)::BIGINT - c.code::BIGINT diff
FROM vzd.nitis_tg_kad_apz a
CROSS JOIN min_date m
INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
INNER JOIN vzd.nivkis_buves c ON (
    b.darijuma_datums >= c.date_created
    OR (
      b.darijuma_datums < m.min_date
      AND c.date_created = m.min_date
      )
    )
  AND (
    b.darijuma_datums < c.date_deleted
    OR c.date_deleted IS NULL
    )
  AND LEFT(a.kad_apz, 14)::BIGINT > c.code::BIGINT
WHERE a.geom IS NULL
  AND LEFT(a.kad_apz, 7) = LEFT(c.code, 7);--Sakrīt kadastra grupa.

CREATE TEMPORARY TABLE tg_p_d1 AS
SELECT a.darijuma_id
  ,a.kad_apz
  ,c.code
  ,c.geom
  ,c.code::BIGINT - LEFT(a.kad_apz, 14)::BIGINT diff
FROM vzd.nitis_tg_kad_apz a
CROSS JOIN min_date m
INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
INNER JOIN vzd.nivkis_buves c ON (
    b.darijuma_datums >= c.date_created
    OR (
      b.darijuma_datums < m.min_date
      AND c.date_created = m.min_date
      )
    )
  AND (
    b.darijuma_datums < c.date_deleted
    OR c.date_deleted IS NULL
    )
  AND LEFT(a.kad_apz, 14)::BIGINT < c.code::BIGINT
WHERE a.geom IS NULL
  AND LEFT(a.kad_apz, 7) = LEFT(c.code, 7);--Sakrīt kadastra grupa.

CREATE TEMPORARY TABLE tg_p_eu AS
SELECT darijuma_id
  ,kad_apz
  ,MIN(diff) diff
FROM tg_p_du
GROUP BY darijuma_id
  ,kad_apz;

CREATE TEMPORARY TABLE tg_p_cm AS
SELECT DISTINCT d.*
FROM tg_p_du d
INNER JOIN tg_p_eu e ON d.darijuma_id = e.darijuma_id
  AND d.kad_apz = e.kad_apz
  AND d.diff = e.diff;

CREATE TEMPORARY TABLE tg_p_el AS
SELECT darijuma_id
  ,kad_apz
  ,MIN(diff) diff
FROM tg_p_d1
GROUP BY darijuma_id
  ,kad_apz;

INSERT INTO tg_p_cm
SELECT DISTINCT d.*
FROM tg_p_d1 d
INNER JOIN tg_p_el e ON d.darijuma_id = e.darijuma_id
  AND d.kad_apz = e.kad_apz
  AND d.diff = e.diff;

CREATE TEMPORARY TABLE tg_p_cm2 AS
SELECT darijuma_id
  ,kad_apz
  ,MIN(diff) diff
FROM tg_p_cm
GROUP BY darijuma_id
  ,kad_apz;

CREATE TEMPORARY TABLE tg_p_c2 AS
SELECT d.*
FROM tg_p_cm d
INNER JOIN tg_p_cm2 e ON d.darijuma_id = e.darijuma_id
  AND d.kad_apz = e.kad_apz
  AND d.diff = e.diff;

CREATE TEMPORARY TABLE tg_p_cc AS
SELECT darijuma_id
  ,kad_apz
  ,COUNT(*) cnt
FROM tg_p_c2
GROUP BY darijuma_id
  ,kad_apz;

CREATE TEMPORARY TABLE tg_p AS
WITH c3
AS (
  SELECT c2.darijuma_id
    ,c2.kad_apz
    ,c2.code
  FROM tg_p_c2 c2
  INNER JOIN tg_p_cc cc ON c2.darijuma_id = cc.darijuma_id
    AND c2.kad_apz = cc.kad_apz
  WHERE cc.cnt = 1
  
  UNION
  
  SELECT c2.darijuma_id
    ,c2.kad_apz
    ,LPAD(MIN(c2.code::BIGINT)::TEXT, 14, '00000000000000') code
  FROM tg_p_c2 c2
  INNER JOIN tg_p_cc cc ON c2.darijuma_id = cc.darijuma_id
    AND c2.kad_apz = cc.kad_apz
  WHERE cc.cnt > 1
  GROUP BY c2.darijuma_id
    ,c2.kad_apz
  )
  ,c
AS (
  SELECT c3.*
    ,c2.geom
  FROM c3
  INNER JOIN tg_p_c2 c2 ON c3.darijuma_id = c2.darijuma_id
    AND c3.kad_apz = c2.kad_apz
    AND c3.code = c2.code
  )
SELECT a.darijuma_id
  ,a.kad_apz
  ,c.geom
FROM vzd.nitis_tg_kad_apz a
INNER JOIN darijumi b ON a.darijuma_id = b.darijuma_id
INNER JOIN c ON b.darijuma_id = c.darijuma_id
  AND a.kad_apz = c.kad_apz
WHERE a.geom IS NULL;

UPDATE vzd.nitis_tg_kad_apz
SET geom = ST_PointOnSurface(s.geom)
FROM tg_p s
WHERE nitis_tg_kad_apz.darijuma_id = s.darijuma_id
  AND nitis_tg_kad_apz.kad_apz = s.kad_apz
  AND nitis_tg_kad_apz.geom IS NULL;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nitis_geom() TO scheduler;