CREATE OR REPLACE PROCEDURE vzd.nivkis_encumbrance_proc(
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
  FROM vzd.nivkis_encumbrance
  
  UNION
  
  SELECT date_deleted "date"
  FROM vzd.nivkis_encumbrance
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

--PreparedDate.
CREATE TEMPORARY TABLE nivkis_encumbrance_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((XPATH('EncumbranceFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_encumbrance_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_encumbrance_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_encumbrance atjaunošanu ar % datiem.', date_files;

  --EncumbranceItemData.
  CREATE TEMPORARY TABLE nivkis_encumbrance_tmp1 AS
  SELECT UNNEST(XPATH('EncumbranceFullData/EncumbranceItemList/EncumbranceItemData', data)) "EncumbranceItemData"
  FROM vzd.nivkis_encumbrance_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_encumbrance_tmp;

  --ObjectRelation, EncumbranceRowData.
  CREATE TEMPORARY TABLE nivkis_encumbrance_tmp2 AS
  SELECT DISTINCT (XPATH('/EncumbranceItemData/ObjectRelation/ObjectCadastreNr/text()', "EncumbranceItemData")) [1]::TEXT "ObjectCadastreNr"
    ,(XPATH('/EncumbranceItemData/EncumbranceList/EncumbranceRowData/EncumbranceKind/EncumbranceKindId/text()', "EncumbranceItemData")) [1]::TEXT::BIGINT "EncumbranceKindId"
    ,(XPATH('/EncumbranceItemData/EncumbranceList/EncumbranceRowData/EncumbranceKind/EncumbranceKindName/text()', "EncumbranceItemData")) [1]::TEXT "EncumbranceKindName"
    ,(XPATH('/EncumbranceItemData/EncumbranceList/EncumbranceRowData/EncumbranceNr/text()', "EncumbranceItemData")) [1]::TEXT::SMALLINT "EncumbranceNr"
    ,(XPATH('/EncumbranceItemData/EncumbranceList/EncumbranceRowData/EncumbranceEstablishDate/text()', "EncumbranceItemData")) [1]::TEXT::DATE "EncumbranceEstablishDate"
    ,(XPATH('/EncumbranceItemData/EncumbranceList/EncumbranceRowData/EncumbranceArea/text()', "EncumbranceItemData")) [1]::TEXT::DECIMAL(9, 4) "EncumbranceArea"
    ,(XPATH('/EncumbranceItemData/EncumbranceList/EncumbranceRowData/EncumbranceMeasure/text()', "EncumbranceItemData")) [1]::TEXT "EncumbranceMeasure"
  FROM nivkis_encumbrance_tmp1;

  --Papildina EncumbranceKind klasifikatoru.
  INSERT INTO vzd.nivkis_encumbrance_usekind
  SELECT DISTINCT "EncumbranceKindId"
    ,"EncumbranceKindName"
  FROM nivkis_encumbrance_tmp2
  WHERE "EncumbranceKindId" IS NOT NULL
    AND "EncumbranceKindId" NOT IN (
      SELECT "EncumbranceKindId"
      FROM vzd.nivkis_encumbrance_usekind
      )
  ORDER BY "EncumbranceKindId";

  --nivkis_encumbrance.
  ---Apgrūtinājums vairāk neeksistē.
  UPDATE vzd.nivkis_encumbrance uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_encumbrance u
  CROSS JOIN nivkis_encumbrance_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_encumbrance_tmp2 s ON u."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND COALESCE(u."EncumbranceNr", 0) = COALESCE(s."EncumbranceNr", 0)
  WHERE s."ObjectCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_encumbrance
  SET date_deleted = d."PreparedDate"
  FROM nivkis_encumbrance_tmp2 s
  CROSS JOIN nivkis_encumbrance_tmp_prepareddate d
  WHERE nivkis_encumbrance."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND COALESCE(nivkis_encumbrance."EncumbranceNr", 0) = COALESCE(s."EncumbranceNr", 0)
    AND nivkis_encumbrance.date_deleted IS NULL
    AND (
      COALESCE(nivkis_encumbrance."EncumbranceKindId", 0) != COALESCE(s."EncumbranceKindId", 0)
      OR COALESCE(nivkis_encumbrance."EncumbranceEstablishDate", '1900-01-01') != COALESCE(s."EncumbranceEstablishDate", '1900-01-01')
      OR COALESCE(nivkis_encumbrance."EncumbranceArea", 0) != COALESCE(s."EncumbranceArea", 0)
      OR COALESCE(nivkis_encumbrance."EncumbranceMeasure", '') != COALESCE(s."EncumbranceMeasure", '')
      );

  INSERT INTO vzd.nivkis_encumbrance (
    "ObjectCadastreNr"
    ,"EncumbranceKindId"
    ,"EncumbranceNr"
    ,"EncumbranceEstablishDate"
    ,"EncumbranceArea"
    ,"EncumbranceMeasure"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."EncumbranceKindId"
    ,s."EncumbranceNr"
    ,s."EncumbranceEstablishDate"
    ,s."EncumbranceArea"
    ,s."EncumbranceMeasure"
    ,d."PreparedDate"
  FROM nivkis_encumbrance_tmp2 s
  CROSS JOIN nivkis_encumbrance_tmp_prepareddate d
  INNER JOIN vzd.nivkis_encumbrance u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
    AND COALESCE(s."EncumbranceNr", 0) = COALESCE(u."EncumbranceNr", 0)
  WHERE (
      COALESCE(u."EncumbranceKindId", 0) != COALESCE(s."EncumbranceKindId", 0)
      OR COALESCE(u."EncumbranceEstablishDate", '1900-01-01') != COALESCE(s."EncumbranceEstablishDate", '1900-01-01')
      OR COALESCE(u."EncumbranceArea", 0) != COALESCE(s."EncumbranceArea", 0)
      OR COALESCE(u."EncumbranceMeasure", '') != COALESCE(s."EncumbranceMeasure", '')
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauns apgrūtinājums.
  INSERT INTO vzd.nivkis_encumbrance (
    "ObjectCadastreNr"
    ,"EncumbranceKindId"
    ,"EncumbranceNr"
    ,"EncumbranceEstablishDate"
    ,"EncumbranceArea"
    ,"EncumbranceMeasure"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."EncumbranceKindId"
    ,s."EncumbranceNr"
    ,s."EncumbranceEstablishDate"
    ,s."EncumbranceArea"
    ,s."EncumbranceMeasure"
    ,d."PreparedDate"
  FROM nivkis_encumbrance_tmp2 s
  CROSS JOIN nivkis_encumbrance_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_encumbrance u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
    AND COALESCE(s."EncumbranceNr", 0) = COALESCE(u."EncumbranceNr", 0)
  WHERE u."ObjectCadastreNr" IS NULL;

  RAISE NOTICE 'Dati nivkis_encumbrance atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_encumbrance nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_encumbrance_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_encumbrance_proc() TO scheduler;