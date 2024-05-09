CREATE OR REPLACE PROCEDURE vzd.nivkis_mark_proc(
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
  FROM vzd.nivkis_mark
  
  UNION
  
  SELECT date_deleted "date"
  FROM vzd.nivkis_mark
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

--PreparedDate.
CREATE TEMPORARY TABLE nivkis_mark_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((XPATH('MarkFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_mark_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_mark_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_mark atjaunošanu ar % datiem.', date_files;

  --MarkItemData.
  CREATE TEMPORARY TABLE nivkis_mark_tmp1 AS
  SELECT UNNEST(XPATH('MarkFullData/MarkItemList/MarkItemData', data)) "MarkItemData"
  FROM vzd.nivkis_mark_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_mark_tmp;

  --ObjectRelation, MarkRecData.
  CREATE TEMPORARY TABLE nivkis_mark_tmp2 AS
  SELECT DISTINCT (XPATH('/MarkItemData/ObjectRelation/ObjectCadastreNr/text()', "MarkItemData")) [1]::TEXT "ObjectCadastreNr"
    ,(XPATH('/MarkItemData/ObjectRelation/ObjectType/text()', "MarkItemData")) [1]::TEXT "ObjectType"
    ,(XPATH('/MarkItemData/MarkList/MarkRecData/MarkType/text()', "MarkItemData")) [1]::TEXT "MarkType"
    ,(XPATH('/MarkItemData/MarkList/MarkRecData/MarkDate/text()', "MarkItemData")) [1]::TEXT::DATE "MarkDate"
    ,(XPATH('/MarkItemData/MarkList/MarkRecData/MarkDescription/text()', "MarkItemData")) [1]::TEXT "MarkDescription"
    ,(XPATH('/MarkItemData/MarkList/MarkRecData/MarkArea/text()', "MarkItemData")) [1]::TEXT::INT "MarkArea"
  FROM nivkis_mark_tmp1;

  --Papildina ObjectType klasifikatoru.
  INSERT INTO vzd.nivkis_objecttype ("ObjectType")
  SELECT DISTINCT "ObjectType"
  FROM nivkis_mark_tmp2
  WHERE "ObjectType" NOT IN (
      SELECT "ObjectType"
      FROM vzd.nivkis_objecttype
      )
  ORDER BY "ObjectType";

  --Papildina MarkType klasifikatoru.
  INSERT INTO vzd.nivkis_mark_marktype (
    "MarkType"
    ,"MarkDescription"
    )
  SELECT DISTINCT "MarkType"
    ,"MarkDescription"
  FROM nivkis_mark_tmp2
  WHERE "MarkType" NOT IN (
      SELECT "MarkType"
      FROM vzd.nivkis_mark_marktype
      )
  ORDER BY "MarkType";

  --Izmanto ID no klasifikatoriem.
  CREATE TEMPORARY TABLE nivkis_mark_tmp3 AS
  SELECT a."ObjectCadastreNr"
    ,b.id "ObjectType"
    ,a."MarkType"
    ,a."MarkDate"
    ,a."MarkArea"
  FROM nivkis_mark_tmp2 a
  INNER JOIN vzd.nivkis_objecttype b ON a."ObjectType" = b."ObjectType";

  --nivkis_mark.
  ---Atzīme vairāk neeksistē.
  UPDATE vzd.nivkis_mark uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_mark u
  CROSS JOIN nivkis_mark_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_mark_tmp3 s ON u."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND u."MarkType" = s."MarkType"
  WHERE s."ObjectCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_mark
  SET date_deleted = d."PreparedDate"
  FROM nivkis_mark_tmp3 s
  CROSS JOIN nivkis_mark_tmp_prepareddate d
  WHERE nivkis_mark."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND nivkis_mark."MarkType" = s."MarkType"
    AND nivkis_mark.date_deleted IS NULL
    AND (
      COALESCE(nivkis_mark."MarkDate", '1900-01-01') != COALESCE(s."MarkDate", '1900-01-01')
      OR COALESCE(nivkis_mark."MarkArea", 0) != COALESCE(s."MarkArea", 0)
      );

  INSERT INTO vzd.nivkis_mark (
    "ObjectCadastreNr"
    ,"ObjectType"
    ,"MarkType"
    ,"MarkDate"
    ,"MarkArea"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ObjectType"
    ,s."MarkType"
    ,s."MarkDate"
    ,s."MarkArea"
    ,d."PreparedDate"
  FROM nivkis_mark_tmp3 s
  CROSS JOIN nivkis_mark_tmp_prepareddate d
  INNER JOIN vzd.nivkis_mark u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
    AND s."MarkType" = u."MarkType"
  WHERE (
      COALESCE(u."MarkDate", '1900-01-01') != COALESCE(s."MarkDate", '1900-01-01')
      OR COALESCE(u."MarkArea", 0) != COALESCE(s."MarkArea", 0)
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauna atzīme.
  INSERT INTO vzd.nivkis_mark (
    "ObjectCadastreNr"
    ,"ObjectType"
    ,"MarkType"
    ,"MarkDate"
    ,"MarkArea"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ObjectType"
    ,s."MarkType"
    ,s."MarkDate"
    ,s."MarkArea"
    ,d."PreparedDate"
  FROM nivkis_mark_tmp3 s
  CROSS JOIN nivkis_mark_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_mark u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
    AND s."MarkType" = u."MarkType"
  WHERE u."ObjectCadastreNr" IS NULL;

  RAISE NOTICE 'Dati nivkis_mark atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_mark nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_mark_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_mark_proc() TO scheduler;