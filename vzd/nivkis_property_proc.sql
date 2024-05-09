CREATE OR REPLACE PROCEDURE vzd.nivkis_property_proc(
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
  FROM vzd.nivkis_property
  
  UNION
  
  SELECT date_deleted "date"
  FROM vzd.nivkis_property
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

CREATE TEMPORARY TABLE nivkis_property_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((XPATH('PropertyFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_property_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_property_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_property atjaunošanu ar % datiem.', date_files;

  --PropertyItemData.
  CREATE TEMPORARY TABLE nivkis_property_tmp1 AS
  SELECT UNNEST(XPATH('PropertyFullData/PropertyItemList/PropertyItemData', data)) "PropertyItemData"
  FROM vzd.nivkis_property_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_property_tmp;

  --CadastreObjectIdData, PropertyBasicData un LandbookData.
  CREATE TEMPORARY TABLE nivkis_property_tmp2 AS
  SELECT DISTINCT (XPATH('/PropertyItemData/CadastreObjectIdData/PropertyKind/text()', "PropertyItemData")) [1]::TEXT "PropertyKind"
    ,(XPATH('/PropertyItemData/CadastreObjectIdData/ProCadastreNr/text()', "PropertyItemData")) [1]::TEXT "ProCadastreNr"
    ,(XPATH('/PropertyItemData/CadastreObjectIdData/ShareFlatProperty/text()', "PropertyItemData")) [1]::TEXT "ShareFlatProperty"
    ,(XPATH('/PropertyItemData/PropertyBasicData/PropertyName/text()', "PropertyItemData")) [1]::TEXT "PropertyName"
    ,(XPATH('/PropertyItemData/PropertyBasicData/PropertyParcelTotalArea/text()', "PropertyItemData")) [1]::TEXT::INT "PropertyParcelTotalArea"
    ,(XPATH('/PropertyItemData/PropertyBasicData/PropertyPremiseGroupTotalArea/text()', "PropertyItemData")) [1]::TEXT::DECIMAL(7, 1) "PropertyPremiseGroupTotalArea"
    ,(XPATH('/PropertyItemData/LandbookData/LandbookFolioNr/text()', "PropertyItemData")) [1]::TEXT "LandbookFolioNr" --Korektu datu gadījumā BIGINT, bet VZD mēdz ievadīt kļūdainus datus, jo specifikācijā šis ir teksta lauks.
    ,(XPATH('/PropertyItemData/LandbookData/LandbookFolioLiterNr/text()', "PropertyItemData")) [1]::TEXT "LandbookFolioLiterNr"
    ,(XPATH('/PropertyItemData/LandbookData/LandbookOfficeName/text()', "PropertyItemData")) [1]::TEXT "LandbookOfficeName"
    ,(XPATH('/PropertyItemData/LandbookData/NotCorroboratedInLandbook/text()', "PropertyItemData")) [1]::TEXT "NotCorroboratedInLandbook"
  FROM nivkis_property_tmp1;

  --Papildina PropertyKind klasifikatoru.
  INSERT INTO vzd.nivkis_property_kind ("PropertyKind")
  SELECT DISTINCT "PropertyKind"
  FROM nivkis_property_tmp2
  WHERE "PropertyKind" NOT IN (
      SELECT "PropertyKind"
      FROM vzd.nivkis_property_kind
      )
  ORDER BY "PropertyKind";

  --Izmanto ID no klasifikatora.
  CREATE TEMPORARY TABLE nivkis_property_tmp3 AS
  SELECT b.id "PropertyKind"
    ,a."ProCadastreNr"
    ,CASE 
      WHEN a."ShareFlatProperty" IS NOT NULL
        THEN 1::BOOLEAN
      ELSE NULL
      END "ShareFlatProperty"
    ,a."PropertyName"
    ,a."PropertyParcelTotalArea"
    ,a."PropertyPremiseGroupTotalArea"
    ,a."LandbookFolioNr"
    ,a."LandbookFolioLiterNr"
    ,a."LandbookOfficeName"
    ,CASE 
      WHEN a."NotCorroboratedInLandbook" IS NOT NULL
        THEN 1::BOOLEAN
      ELSE NULL
      END "NotCorroboratedInLandbook"
  FROM nivkis_property_tmp2 a
  INNER JOIN vzd.nivkis_property_kind b ON a."PropertyKind" = b."PropertyKind";

  --Īpašums vairāk neeksistē.
  UPDATE vzd.nivkis_property uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_property u
  CROSS JOIN nivkis_property_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_property_tmp3 s ON u."ProCadastreNr" = s."ProCadastreNr"
  WHERE s."ProCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  --Mainīti atribūti.
  UPDATE vzd.nivkis_property
  SET date_deleted = d."PreparedDate"
  FROM nivkis_property_tmp3 s
  CROSS JOIN nivkis_property_tmp_prepareddate d
  WHERE nivkis_property."ProCadastreNr" = s."ProCadastreNr"
    AND nivkis_property.date_deleted IS NULL
    AND (
      nivkis_property."PropertyKind" != s."PropertyKind"
      OR COALESCE(nivkis_property."ShareFlatProperty", FALSE) != COALESCE(s."ShareFlatProperty", FALSE)
      OR COALESCE(nivkis_property."PropertyName", '') != COALESCE(s."PropertyName", '')
      OR COALESCE(nivkis_property."PropertyParcelTotalArea", 0) != COALESCE(s."PropertyParcelTotalArea", 0)
      OR COALESCE(nivkis_property."PropertyPremiseGroupTotalArea", 0) != COALESCE(s."PropertyPremiseGroupTotalArea", 0)
      OR COALESCE(nivkis_property."LandbookFolioNr", '') != COALESCE(s."LandbookFolioNr", '')
      OR COALESCE(nivkis_property."LandbookFolioLiterNr", '') != COALESCE(s."LandbookFolioLiterNr", '')
      OR COALESCE(nivkis_property."LandbookOfficeName", '') != COALESCE(s."LandbookOfficeName", '')
      OR COALESCE(nivkis_property."NotCorroboratedInLandbook", FALSE) != COALESCE(s."NotCorroboratedInLandbook", FALSE)
      );

  INSERT INTO vzd.nivkis_property (
    "PropertyKind"
    ,"ProCadastreNr"
    ,"ShareFlatProperty"
    ,"PropertyName"
    ,"PropertyParcelTotalArea"
    ,"PropertyPremiseGroupTotalArea"
    ,"LandbookFolioNr"
    ,"LandbookFolioLiterNr"
    ,"LandbookOfficeName"
    ,"NotCorroboratedInLandbook"
    ,date_created
    )
  SELECT s."PropertyKind"
    ,s."ProCadastreNr"
    ,s."ShareFlatProperty"
    ,s."PropertyName"
    ,s."PropertyParcelTotalArea"
    ,s."PropertyPremiseGroupTotalArea"
    ,s."LandbookFolioNr"
    ,s."LandbookFolioLiterNr"
    ,s."LandbookOfficeName"
    ,s."NotCorroboratedInLandbook"
    ,d."PreparedDate"
  FROM nivkis_property_tmp3 s
  CROSS JOIN nivkis_property_tmp_prepareddate d
  INNER JOIN vzd.nivkis_property u ON s."ProCadastreNr" = u."ProCadastreNr"
  WHERE (
      u."PropertyKind" != s."PropertyKind"
      OR COALESCE(u."ShareFlatProperty", FALSE) != COALESCE(s."ShareFlatProperty", FALSE)
      OR COALESCE(u."PropertyName", '') != COALESCE(s."PropertyName", '')
      OR COALESCE(u."PropertyParcelTotalArea", 0) != COALESCE(s."PropertyParcelTotalArea", 0)
      OR COALESCE(u."PropertyPremiseGroupTotalArea", 0) != COALESCE(s."PropertyPremiseGroupTotalArea", 0)
      OR COALESCE(u."LandbookFolioNr", '') != COALESCE(s."LandbookFolioNr", '')
      OR COALESCE(u."LandbookFolioLiterNr", '') != COALESCE(s."LandbookFolioLiterNr", '')
      OR COALESCE(u."LandbookOfficeName", '') != COALESCE(s."LandbookOfficeName", '')
      OR COALESCE(u."NotCorroboratedInLandbook", FALSE) != COALESCE(s."NotCorroboratedInLandbook", FALSE)
      )
    AND u.date_deleted = d."PreparedDate";

  --Jauns īpašums.
  INSERT INTO vzd.nivkis_property (
    "PropertyKind"
    ,"ProCadastreNr"
    ,"ShareFlatProperty"
    ,"PropertyName"
    ,"PropertyParcelTotalArea"
    ,"PropertyPremiseGroupTotalArea"
    ,"LandbookFolioNr"
    ,"LandbookFolioLiterNr"
    ,"LandbookOfficeName"
    ,"NotCorroboratedInLandbook"
    ,date_created
    )
  SELECT s."PropertyKind"
    ,s."ProCadastreNr"
    ,s."ShareFlatProperty"
    ,s."PropertyName"
    ,s."PropertyParcelTotalArea"
    ,s."PropertyPremiseGroupTotalArea"
    ,s."LandbookFolioNr"
    ,s."LandbookFolioLiterNr"
    ,s."LandbookOfficeName"
    ,s."NotCorroboratedInLandbook"
    ,d."PreparedDate"
  FROM nivkis_property_tmp3 s
  CROSS JOIN nivkis_property_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_property u ON s."ProCadastreNr" = u."ProCadastreNr"
  WHERE u."ProCadastreNr" IS NULL;

  --PropertyContentData
  CREATE TEMPORARY TABLE nivkis_property_tmp_object AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/PropertyItemData/CadastreObjectIdData/ProCadastreNr/text()', "PropertyItemData")) [1]::TEXT "ProCadastreNr"
      ,t."ObjectData"
    FROM nivkis_property_tmp1 a
      ,LATERAL UNNEST((XPATH('/PropertyItemData/PropertyContentData/ObjectList/ObjectData', "PropertyItemData"))::TEXT[]) t("ObjectData")
    )
    ,b
  AS (
    SELECT "ProCadastreNr"
      ,"ObjectData"::XML "ObjectData"
    FROM a
    )
  SELECT "ProCadastreNr"
    ,(XPATH('/ObjectData/ObjectKindData/text()', "ObjectData")) [1]::TEXT "ObjectKindData"
    ,(XPATH('/ObjectData/ObjectCadastreNrData/text()', "ObjectData")) [1]::TEXT "ObjectCadastreNrData"
    ,(XPATH('/ObjectData/ShareParts/text()', "ObjectData")) [1]::TEXT::BIGINT "ShareParts"
    ,(XPATH('/ObjectData/NrOfShares/text()', "ObjectData")) [1]::TEXT::BIGINT "NrOfShares"
  FROM b;

  --Papildina ObjectKindData klasifikatoru.
  INSERT INTO vzd.nivkis_property_object_kind ("ObjectKindData")
  SELECT DISTINCT "ObjectKindData"
  FROM nivkis_property_tmp_object
  WHERE "ObjectKindData" NOT IN (
      SELECT "ObjectKindData"
      FROM vzd.nivkis_property_object_kind
      )
  ORDER BY "ObjectKindData";

  --Izmanto ID no klasifikatora.
  CREATE TEMPORARY TABLE nivkis_property_tmp_object_2 AS
  SELECT a."ProCadastreNr"
    ,b.id "ObjectKindData"
    ,a."ObjectCadastreNrData"
    ,a."ShareParts"
    ,a."NrOfShares"
  FROM nivkis_property_tmp_object a
  INNER JOIN vzd.nivkis_property_object_kind b ON a."ObjectKindData" = b."ObjectKindData";

  --Īpašums vairāk neeksistē vai tā sastāvā vairs nav attiecīgā kadastra objekta.
  UPDATE vzd.nivkis_property_object uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_property_object u
  CROSS JOIN nivkis_property_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_property_tmp_object_2 s ON u."ProCadastreNr" = s."ProCadastreNr"
    AND u."ObjectCadastreNrData" = s."ObjectCadastreNrData"
  WHERE s."ObjectCadastreNrData" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  --Mainīti atribūti.
  UPDATE vzd.nivkis_property_object
  SET date_deleted = d."PreparedDate"
  FROM nivkis_property_tmp_object_2 s
  CROSS JOIN nivkis_property_tmp_prepareddate d
  WHERE nivkis_property_object."ProCadastreNr" = s."ProCadastreNr"
    AND nivkis_property_object."ObjectCadastreNrData" = s."ObjectCadastreNrData"
    AND nivkis_property_object.date_deleted IS NULL
    AND (
      nivkis_property_object."ObjectKindData" != s."ObjectKindData"
      OR COALESCE(nivkis_property_object."ShareParts", 0) != COALESCE(s."ShareParts", 0)
      OR COALESCE(nivkis_property_object."NrOfShares", 0) != COALESCE(s."NrOfShares", 0)
      );

  INSERT INTO vzd.nivkis_property_object (
    "ProCadastreNr"
    ,"ObjectKindData"
    ,"ObjectCadastreNrData"
    ,"ShareParts"
    ,"NrOfShares"
    ,date_created
    )
  SELECT s."ProCadastreNr"
    ,s."ObjectKindData"
    ,s."ObjectCadastreNrData"
    ,s."ShareParts"
    ,s."NrOfShares"
    ,d."PreparedDate"
  FROM nivkis_property_tmp_object_2 s
  CROSS JOIN nivkis_property_tmp_prepareddate d
  INNER JOIN vzd.nivkis_property_object u ON s."ProCadastreNr" = u."ProCadastreNr"
    AND u."ObjectCadastreNrData" = s."ObjectCadastreNrData"
  WHERE (
      u."ObjectKindData" != s."ObjectKindData"
      OR COALESCE(u."ShareParts", 0) != COALESCE(s."ShareParts", 0)
      OR COALESCE(u."NrOfShares", 0) != COALESCE(s."NrOfShares", 0)
      )
    AND u.date_deleted = d."PreparedDate";

  --Jauns īpašums vai tā sastāvā esošs kadastra objekts.
  INSERT INTO vzd.nivkis_property_object (
    "ProCadastreNr"
    ,"ObjectKindData"
    ,"ObjectCadastreNrData"
    ,"ShareParts"
    ,"NrOfShares"
    ,date_created
    )
  SELECT s."ProCadastreNr"
    ,s."ObjectKindData"
    ,s."ObjectCadastreNrData"
    ,s."ShareParts"
    ,s."NrOfShares"
    ,d."PreparedDate"
  FROM nivkis_property_tmp_object_2 s
  CROSS JOIN nivkis_property_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_property_object u ON s."ProCadastreNr" = u."ProCadastreNr"
    AND s."ObjectCadastreNrData" = u."ObjectCadastreNrData"
  WHERE u."ObjectCadastreNrData" IS NULL;

  RAISE NOTICE 'Dati nivkis_property atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_property nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_property_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_property_proc() TO scheduler;