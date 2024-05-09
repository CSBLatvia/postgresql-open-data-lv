CREATE OR REPLACE PROCEDURE lad.fields_proc(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

--Izveido pagaidu datu tabulu.
CREATE TEMPORARY TABLE fields_tmp (
  id SERIAL PRIMARY KEY
  ,parcel_id INTEGER
  ,period_code SMALLINT
  ,product_code SMALLINT
  ,product_description VARCHAR
  ,aid_forms VARCHAR
  ,area_declared REAL
  ,data_changed_date TIMESTAMP
  ,geom geometry(MultiPolygon, 3059)
  );

--Pagaidu datu tabulā importē visu datu kopu no WFS.
INSERT INTO fields_tmp (
  parcel_id
  ,period_code
  ,product_code
  ,product_description
  ,aid_forms
  ,area_declared
  ,data_changed_date
  ,geom
  )
SELECT parcel_id
  ,period_code::SMALLINT
  ,product_code::SMALLINT
  ,product_description
  ,aid_forms
  ,area_declared
  ,data_changed_date::TIMESTAMP
  ,ST_CurveToLine(shape)
FROM lad.lad_lauki;

--Aizpilda produktu kodu tabulu.
INSERT INTO lad.products (
  product_code
  ,product_description
  )
SELECT DISTINCT product_code
  ,product_description
FROM fields_tmp
WHERE product_code NOT IN (
    SELECT product_code
    FROM lad.products
    )
ORDER BY product_code;

--Lauki, kas vairāk neeksistē.
UPDATE lad.fields
SET date_deleted = CURRENT_DATE
FROM lad.fields u
LEFT JOIN fields_tmp s ON u.parcel_id = s.parcel_id
WHERE s.parcel_id IS NULL
  AND lad.fields.date_deleted IS NULL
  AND lad.fields.id = u.id;

--Lauki, kuriem veiktas izmaiņas kopš pēdējās atjaunināšanas.

WITH b
AS (
  SELECT parcel_id
    ,MAX(data_changed_date) data_changed_date_max
  FROM lad.fields
  GROUP BY parcel_id
  )
UPDATE lad.fields
SET date_deleted = CURRENT_DATE
FROM fields_tmp s
INNER JOIN b ON s.parcel_id = b.parcel_id
WHERE s.data_changed_date > b.data_changed_date_max
  AND lad.fields.parcel_id = s.parcel_id
  AND date_deleted IS NULL;

WITH b
AS (
  SELECT parcel_id
    ,MAX(data_changed_date) data_changed_date_max
  FROM lad.fields
  GROUP BY parcel_id
  )
INSERT INTO lad.fields (
  parcel_id
  ,period_code
  ,product_code
  ,aid_forms
  ,area_declared
  ,data_changed_date
  ,geom
  ,date_created
  )
SELECT s.parcel_id
  ,s.period_code
  ,s.product_code
  ,s.aid_forms
  ,s.area_declared
  ,s.data_changed_date
  ,s.geom
  ,CURRENT_DATE
FROM fields_tmp s
INNER JOIN b ON s.parcel_id = b.parcel_id
WHERE s.data_changed_date > b.data_changed_date_max;

--Jauni lauki.
INSERT INTO lad.fields (
  parcel_id
  ,period_code
  ,product_code
  ,aid_forms
  ,area_declared
  ,data_changed_date
  ,geom
  ,date_created
  )
SELECT s.parcel_id
  ,s.period_code
  ,s.product_code
  ,s.aid_forms
  ,s.area_declared
  ,s.data_changed_date
  ,s.geom
  ,CURRENT_DATE
FROM lad.fields u
RIGHT OUTER JOIN fields_tmp s ON u.parcel_id = s.parcel_id
WHERE u.parcel_id IS NULL;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE lad.fields_proc() TO scheduler;