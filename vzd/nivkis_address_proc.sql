CREATE OR REPLACE PROCEDURE vzd.nivkis_address_proc(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

DO $$

DECLARE date_db DATE;
DECLARE date_files DATE;

BEGIN

date_db :=
(WITH a
AS (
  SELECT date_created "date"
  FROM vzd.nivkis_address
  
  UNION
  
  SELECT date_deleted "date"
  FROM vzd.nivkis_address
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

CREATE TEMPORARY TABLE nivkis_address_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((xpath('AddressFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_address_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_address_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_address atjaunošanu ar % datiem.', date_files;

  CREATE TEMPORARY TABLE nivkis_address_tmp2 AS
  SELECT UNNEST((xpath('AddressFullData/AddressItemList/AddressItemData/ObjectRelation/ObjectCadastreNr/text()', data)))::TEXT "ObjectCadastreNr"
    ,UNNEST((xpath('AddressFullData/AddressItemList/AddressItemData/AddressData/ARCode/text()', data)))::TEXT::INT "ARCode"
  FROM vzd.nivkis_address_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_address_tmp;

  --Kadastra objekts un/vai tā adrese vairāk neeksistē.
  UPDATE vzd.nivkis_address uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_address u
  CROSS JOIN nivkis_address_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_address_tmp2 s ON u."ObjectCadastreNr" = s."ObjectCadastreNr"
  WHERE s."ARCode" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  --Mainīta adrese.
  UPDATE vzd.nivkis_address
  SET date_deleted = d."PreparedDate"
  FROM nivkis_address_tmp2 s
  CROSS JOIN nivkis_address_tmp_prepareddate d
  WHERE nivkis_address."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND nivkis_address.date_deleted IS NULL
    AND nivkis_address."ARCode" != s."ARCode";

  INSERT INTO vzd.nivkis_address (
    "ObjectCadastreNr"
    ,"ARCode"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ARCode"
    ,d."PreparedDate"
  FROM nivkis_address_tmp2 s
  CROSS JOIN nivkis_address_tmp_prepareddate d
  INNER JOIN vzd.nivkis_address u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE s."ARCode" IS NOT NULL
    AND u."ARCode" != s."ARCode"
    AND u.date_deleted = d."PreparedDate";

  --Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_address (
    "ObjectCadastreNr"
    ,"ARCode"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ARCode"
    ,d."PreparedDate"
  FROM nivkis_address_tmp2 s
  CROSS JOIN nivkis_address_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_address u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE s."ARCode" IS NOT NULL
    AND u."ObjectCadastreNr" IS NULL;

  --Salabo kadastra objektus ar vairākām adresēm.
  WITH m
  AS (
    SELECT "ObjectCadastreNr"
      ,"ARCode"
      ,MIN(date_created) date_created
    FROM vzd.nivkis_address
    GROUP BY "ObjectCadastreNr"
      ,"ARCode"
    )
    ,c
  AS (
    SELECT "ObjectCadastreNr"
      ,date_created
      ,COUNT(*) cnt
    FROM vzd.nivkis_address
    GROUP BY "ObjectCadastreNr"
      ,date_created
    HAVING COUNT(*) > 1
    )
  UPDATE vzd.nivkis_address
  SET date_deleted = NULL
  WHERE id IN (
      SELECT a.id
      FROM vzd.nivkis_address a
      INNER JOIN vzd.nivkis_address b ON a."ObjectCadastreNr" = b."ObjectCadastreNr"
        AND a."ARCode" = b."ARCode"
      INNER JOIN m ON a."ObjectCadastreNr" = m."ObjectCadastreNr"
        AND a."ARCode" = m."ARCode"
        AND a.date_created = m.date_created
      INNER JOIN c ON a."ObjectCadastreNr" = c."ObjectCadastreNr"
        AND a.date_created = c.date_created
      WHERE b.date_deleted IS NULL
        AND a.date_created != b.date_created
      );

  WITH m
  AS (
    SELECT "ObjectCadastreNr"
      ,"ARCode"
      ,MIN(date_created) date_created
    FROM vzd.nivkis_address
    GROUP BY "ObjectCadastreNr"
      ,"ARCode"
    )
    ,c
  AS (
    SELECT "ObjectCadastreNr"
      ,date_created
      ,COUNT(*) cnt
    FROM vzd.nivkis_address
    GROUP BY "ObjectCadastreNr"
      ,date_created
    HAVING COUNT(*) > 1
    )
  DELETE
  FROM vzd.nivkis_address
  WHERE id IN (
      SELECT b.id
      FROM vzd.nivkis_address a
      INNER JOIN vzd.nivkis_address b ON a."ObjectCadastreNr" = b."ObjectCadastreNr"
        AND a."ARCode" = b."ARCode"
      INNER JOIN m ON a."ObjectCadastreNr" = m."ObjectCadastreNr"
        AND a."ARCode" = m."ARCode"
        AND a.date_created = m.date_created
      INNER JOIN c ON a."ObjectCadastreNr" = c."ObjectCadastreNr"
        AND a.date_created = c.date_created
      WHERE b.date_created > a.date_created
      );

  RAISE NOTICE 'Dati nivkis_address atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_address nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_address_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_address_proc() TO scheduler;