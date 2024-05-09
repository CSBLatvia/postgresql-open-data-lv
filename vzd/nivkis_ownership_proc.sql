CREATE OR REPLACE PROCEDURE vzd.nivkis_ownership_proc(
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
  FROM vzd.nivkis_ownership
  
  UNION
  
  SELECT date_deleted "date"
  FROM vzd.nivkis_ownership
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

CREATE TEMPORARY TABLE nivkis_ownership_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((XPATH('OwnershipFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_ownership_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_ownership_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_ownership atjaunošanu ar % datiem.', date_files;

  --OwnershipItemData.
  CREATE TEMPORARY TABLE nivkis_ownership_tmp1 AS
  SELECT UNNEST(XPATH('OwnershipFullData/OwnershipItemList/OwnershipItemData', data)) "OwnershipItemData"
  FROM vzd.nivkis_ownership_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_ownership_tmp;

  --ObjectRelation un OwnershipStatusKindList.
  CREATE TEMPORARY TABLE nivkis_ownership_tmp2 AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/OwnershipItemData/ObjectRelation/ObjectCadastreNr/text()', a."OwnershipItemData")) [1]::TEXT "ObjectCadastreNr"
      ,(XPATH('/OwnershipItemData/ObjectRelation/ObjectType/text()', a."OwnershipItemData")) [1]::TEXT "ObjectType"
      ,t."OwnershipStatusKind"
    FROM nivkis_ownership_tmp1 a
      ,LATERAL UNNEST((XPATH('/OwnershipItemData/OwnershipStatusKindList/OwnershipStatusKind', "OwnershipItemData"))::TEXT[]) t("OwnershipStatusKind")
    )
    ,b
  AS (
    SELECT "ObjectCadastreNr"
      ,"OwnershipStatusKind"::XML "OwnershipStatusKind"
    FROM a
    )
  SELECT "ObjectCadastreNr"
    ,(XPATH('/OwnershipStatusKind/OwnershipStatus/text()', "OwnershipStatusKind")) [1]::TEXT "OwnershipStatus"
    ,(XPATH('/OwnershipStatusKind/PersonStatus/text()', "OwnershipStatusKind")) [1]::TEXT "PersonStatus"
  FROM b;

  --Papildina OwnershipStatus klasifikatoru.
  INSERT INTO vzd.nivkis_ownership_status ("OwnershipStatus")
  SELECT DISTINCT "OwnershipStatus"
  FROM nivkis_ownership_tmp2
  WHERE "OwnershipStatus" NOT IN (
      SELECT "OwnershipStatus"
      FROM vzd.nivkis_ownership_status
      )
  ORDER BY "OwnershipStatus";

  --Papildina PersonStatus klasifikatoru.
  INSERT INTO vzd.nivkis_ownership_personstatus ("PersonStatus")
  SELECT DISTINCT "PersonStatus"
  FROM nivkis_ownership_tmp2
  WHERE "PersonStatus" NOT IN (
      SELECT "PersonStatus"
      FROM vzd.nivkis_ownership_personstatus
      )
  ORDER BY "PersonStatus";

  --Izmanto ID no klasifikatoriem.
  CREATE TEMPORARY TABLE nivkis_ownership_tmp3 AS
  SELECT "ObjectCadastreNr"
    ,b.id "OwnershipStatus"
    ,c.id "PersonStatus"
  FROM nivkis_ownership_tmp2 a
  INNER JOIN vzd.nivkis_ownership_status b ON a."OwnershipStatus" = b."OwnershipStatus"
  INNER JOIN vzd.nivkis_ownership_personstatus c ON a."PersonStatus" = c."PersonStatus";

  --Kadastra objekts un/vai personas īpašuma tiesību un personas statuss vairāk neeksistē.
  UPDATE vzd.nivkis_ownership uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_ownership u
  CROSS JOIN nivkis_ownership_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_ownership_tmp3 s ON u."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND u."OwnershipStatus" = s."OwnershipStatus"
    AND u."PersonStatus" = s."PersonStatus"
  WHERE s."PersonStatus" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  --Jauns kadastra objekts un/vai personas īpašuma tiesību un personas statuss.
  INSERT INTO vzd.nivkis_ownership (
    "ObjectCadastreNr"
    ,"OwnershipStatus"
    ,"PersonStatus"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."OwnershipStatus"
    ,s."PersonStatus"
    ,d."PreparedDate"
  FROM nivkis_ownership_tmp3 s
  CROSS JOIN nivkis_ownership_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_ownership u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
    AND s."OwnershipStatus" = u."OwnershipStatus"
    AND s."PersonStatus" = u."PersonStatus"
  WHERE u."PersonStatus" IS NULL;

  RAISE NOTICE 'Dati nivkis_ownership atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_ownership nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_ownership_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_ownership_proc() TO scheduler;