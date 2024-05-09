CREATE OR REPLACE PROCEDURE lad.field_blocks_proc(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

--Izveido pagaidu datu tabulu.
CREATE TEMPORARY TABLE field_blocks_tmp (
  id SERIAL PRIMARY KEY
  ,block_number VARCHAR
  ,mla VARCHAR
  ,valid_from TIMESTAMP
  ,geom geometry(MultiPolygon, 3059)
  );

--Pagaidu datu tabulā importē visu datu kopu no WFS.
INSERT INTO field_blocks_tmp (
  block_number
  ,mla
  ,valid_from
  ,geom
  )
SELECT block_number
  ,mla
  ,valid_from::TIMESTAMP
  ,ST_CurveToLine(shape)
FROM lad.lad_lauku_bloki;

CREATE INDEX field_blocks_tmp_idx ON field_blocks_tmp (block_number);

CREATE INDEX field_blocks_tmp_geom_idx ON field_blocks_tmp USING GIST (geom);

--Lauku bloki, kas vairāk neeksistē.
UPDATE lad.field_blocks
SET date_deleted = CURRENT_DATE
FROM lad.field_blocks u
LEFT JOIN field_blocks_tmp s ON u.block_number = s.block_number
WHERE s.block_number IS NULL
  AND lad.field_blocks.date_deleted IS NULL
  AND lad.field_blocks.id = u.id;

--Lauki, kuriem veiktas izmaiņas kopš pēdējās atjaunināšanas.
WITH b
AS (
  SELECT block_number
    ,MAX(valid_from) valid_from_max
  FROM lad.field_blocks
  GROUP BY block_number
  )
UPDATE lad.field_blocks
SET date_deleted = CURRENT_DATE
FROM field_blocks_tmp s
INNER JOIN b ON s.block_number = b.block_number
WHERE s.valid_from > b.valid_from_max
  AND lad.field_blocks.block_number = s.block_number
  AND date_deleted IS NULL;

WITH b
AS (
  SELECT block_number
    ,MAX(valid_from) valid_from_max
  FROM lad.field_blocks
  GROUP BY block_number
  )
INSERT INTO lad.field_blocks (
  block_number
  ,mla
  ,valid_from
  ,geom
  ,date_created
  )
SELECT s.block_number
  ,s.mla
  ,s.valid_from
  ,s.geom
  ,CURRENT_DATE
FROM field_blocks_tmp s
INNER JOIN b ON s.block_number = b.block_number
WHERE s.valid_from > b.valid_from_max;

--Jauni lauki.
INSERT INTO lad.field_blocks (
  block_number
  ,mla
  ,valid_from
  ,geom
  ,date_created
  )
SELECT s.block_number
  ,s.mla
  ,s.valid_from
  ,s.geom
  ,CURRENT_DATE
FROM lad.field_blocks u
RIGHT OUTER JOIN field_blocks_tmp s ON u.block_number = s.block_number
WHERE u.block_number IS NULL;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE lad.field_blocks_proc() TO scheduler;