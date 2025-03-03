CREATE OR REPLACE PROCEDURE vzd.nivkis_parcelpart_proc(
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
  FROM vzd.nivkis_parcelpart
  
  UNION
  
  SELECT date_deleted "date"
  FROM vzd.nivkis_parcelpart
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

--PreparedDate.
CREATE TEMPORARY TABLE nivkis_parcelpart_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((XPATH('ParcelPartFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_parcelpart_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_parcelpart_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_parcelpart atjaunošanu ar % datiem.', date_files;

  --ParcelPartItemData.
  CREATE TEMPORARY TABLE nivkis_parcelpart_tmp1 AS
  SELECT UNNEST(XPATH('ParcelPartFullData/ParcelPartItemList/ParcelPartItemData', data)) "ParcelPartItemData"
  FROM vzd.nivkis_parcelpart_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_parcelpart_tmp;

  --ObjectRelation, ParcelPartBasicData.
  CREATE TEMPORARY TABLE nivkis_parcelpart_tmp2 AS
  SELECT DISTINCT (XPATH('/ParcelPartItemData/ParcelPartBasicData/ParcelPartCadastreNr/text()', "ParcelPartItemData")) [1]::TEXT "ParcelPartCadastreNr"
    ,(XPATH('/ParcelPartItemData/ObjectRelation/ObjectCadastreNr/text()', "ParcelPartItemData")) [1]::TEXT "ParcelCadastreNr"
    ,(XPATH('/ParcelPartItemData/ParcelPartBasicData/ParcelPartArea/text()', "ParcelPartItemData")) [1]::TEXT::INT "ParcelPartArea"
    ,(XPATH('/ParcelPartItemData/ParcelPartBasicData/ParcelPartLizValue/text()', "ParcelPartItemData")) [1]::TEXT::SMALLINT "ParcelPartLizValue"
  FROM nivkis_parcelpart_tmp1;

  --nivkis_parcelpart.
  ---Kadastra objekts vairāk neeksistē.
  UPDATE vzd.nivkis_parcelpart uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_parcelpart u
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_parcelpart_tmp2 s ON u."ParcelPartCadastreNr" = s."ParcelPartCadastreNr"
  WHERE s."ParcelPartCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_parcelpart
  SET date_deleted = d."PreparedDate"
  FROM nivkis_parcelpart_tmp2 s
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  WHERE nivkis_parcelpart."ParcelPartCadastreNr" = s."ParcelPartCadastreNr"
    AND nivkis_parcelpart.date_deleted IS NULL
    AND (
      COALESCE(nivkis_parcelpart."ParcelCadastreNr", '') != COALESCE(s."ParcelCadastreNr", '')
      OR COALESCE(nivkis_parcelpart."ParcelPartArea", 0) != COALESCE(s."ParcelPartArea", 0)
      OR COALESCE(nivkis_parcelpart."ParcelPartLizValue", 0) != COALESCE(s."ParcelPartLizValue", 0)
      );

  INSERT INTO vzd.nivkis_parcelpart (
    "ParcelPartCadastreNr"
    ,"ParcelCadastreNr"
    ,"ParcelPartArea"
    ,"ParcelPartLizValue"
    ,date_created
    )
  SELECT s."ParcelPartCadastreNr"
    ,s."ParcelCadastreNr"
    ,s."ParcelPartArea"
    ,s."ParcelPartLizValue"
    ,d."PreparedDate"
  FROM nivkis_parcelpart_tmp2 s
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  INNER JOIN vzd.nivkis_parcelpart u ON s."ParcelPartCadastreNr" = u."ParcelPartCadastreNr"
  WHERE (
      COALESCE(u."ParcelCadastreNr", '') != COALESCE(s."ParcelCadastreNr", '')
      OR COALESCE(u."ParcelPartArea", 0) != COALESCE(s."ParcelPartArea", 0)
      OR COALESCE(u."ParcelPartLizValue", 0) != COALESCE(s."ParcelPartLizValue", 0)
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_parcelpart (
    "ParcelPartCadastreNr"
    ,"ParcelCadastreNr"
    ,"ParcelPartArea"
    ,"ParcelPartLizValue"
    ,date_created
    )
  SELECT s."ParcelPartCadastreNr"
    ,s."ParcelCadastreNr"
    ,s."ParcelPartArea"
    ,s."ParcelPartLizValue"
    ,d."PreparedDate"
  FROM nivkis_parcelpart_tmp2 s
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_parcelpart u ON s."ParcelPartCadastreNr" = u."ParcelPartCadastreNr"
  WHERE u."ParcelPartCadastreNr" IS NULL;

  --LandPurposeList.
  CREATE TEMPORARY TABLE nivkis_parcelpart_tmp_landpurpose AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/ParcelPartItemData/ParcelPartBasicData/ParcelPartCadastreNr/text()', a."ParcelPartItemData")) [1]::TEXT "ParcelPartCadastreNr"
      ,t."LandPurposeData"
    FROM nivkis_parcelpart_tmp1 a
      ,LATERAL UNNEST((XPATH('/ParcelPartItemData/LandPurposeList/LandPurposeData', "ParcelPartItemData"))::TEXT []) t("LandPurposeData")
    )
    ,b
  AS (
    SELECT "ParcelPartCadastreNr"
      ,"LandPurposeData"::XML "LandPurposeData"
    FROM a
    )
  SELECT "ParcelPartCadastreNr"
    ,(XPATH('/LandPurposeData/LandPurposeKind/LandPurposeKindId/text()', "LandPurposeData")) [1]::TEXT "LandPurposeKindId"
    ,(XPATH('/LandPurposeData/LandPurposeKind/LandPurposeKindName/text()', "LandPurposeData")) [1]::TEXT "LandPurposeKindName"
    --,(XPATH('/LandPurposeData/LandPurposeArea/text()', "LandPurposeData")) [1]::TEXT::INT "LandPurposeArea"
    --,(XPATH('/LandPurposeData/LandPurposeExplicationData/AgricultTotal/text()', "LandPurposeData")) [1]::TEXT::INT "AgricultTotal"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/AgricultDetails/Areable/text()', "LandPurposeData")) [1]::TEXT::INT "Areable"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/AgricultDetails/Orchards/text()', "LandPurposeData")) [1]::TEXT::INT "Orchards"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/AgricultDetails/Meadows/text()', "LandPurposeData")) [1]::TEXT::INT "Meadows"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/AgricultDetails/Pastures/text()', "LandPurposeData")) [1]::TEXT::INT "Pastures"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/Forest/text()', "LandPurposeData")) [1]::TEXT::INT "Forest"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/Bushes/text()', "LandPurposeData")) [1]::TEXT::INT "Bushes"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/Swamp/text()', "LandPurposeData")) [1]::TEXT::INT "Swamp"
    --,(XPATH('/LandPurposeData/LandPurposeExplicationData/UnderWaterTotal/text()', "LandPurposeData")) [1]::TEXT::INT "UnderWaterTotal"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/UnderWaterDetails/UnderFishPonds/text()', "LandPurposeData")) [1]::TEXT::INT "UnderFishPonds"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/UnderWaterDetails/Flooded/text()', "LandPurposeData")) [1]::TEXT::INT "Flooded"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/UnderBuildings/text()', "LandPurposeData")) [1]::TEXT::INT "UnderBuildings"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/UnderRoads/text()', "LandPurposeData")) [1]::TEXT::INT "UnderRoads"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/OtherLand/text()', "LandPurposeData")) [1]::TEXT::INT "OtherLand"
    ,(XPATH('/LandPurposeData/LandPurposeExplicationData/Drained/text()', "LandPurposeData")) [1]::TEXT::INT "Drained"
  FROM b;

  --Papildina LandPurposeKind klasifikatoru.
  INSERT INTO vzd.nivkis_parcel_landpurpose_kind
  SELECT DISTINCT "LandPurposeKindId"
    ,"LandPurposeKindName"
  FROM nivkis_parcelpart_tmp_landpurpose
  WHERE "LandPurposeKindId" IS NOT NULL
    AND "LandPurposeKindId" NOT IN (
      SELECT "LandPurposeKindId"
      FROM vzd.nivkis_parcel_landpurpose_kind
      )
  ORDER BY "LandPurposeKindId";

  --nivkis_parcelpart_landpurpose.
  ---Kadastra objekts un/vai nekustamā īpašuma lietošanas mērķa kods vairāk neeksistē.
  UPDATE vzd.nivkis_parcelpart_landpurpose uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_parcelpart_landpurpose u
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_parcelpart_tmp_landpurpose s ON u."ParcelPartCadastreNr" = s."ParcelPartCadastreNr"
    AND u."LandPurposeKindId" = s."LandPurposeKindId"
  WHERE s."ParcelPartCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_parcelpart_landpurpose
  SET date_deleted = d."PreparedDate"
  FROM nivkis_parcelpart_tmp_landpurpose s
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  WHERE nivkis_parcelpart_landpurpose."ParcelPartCadastreNr" = s."ParcelPartCadastreNr"
    AND nivkis_parcelpart_landpurpose."LandPurposeKindId" = s."LandPurposeKindId"
    AND nivkis_parcelpart_landpurpose.date_deleted IS NULL
    AND (
      COALESCE(nivkis_parcelpart_landpurpose."Areable", 0) != COALESCE(s."Areable", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."Orchards", 0) != COALESCE(s."Orchards", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."Meadows", 0) != COALESCE(s."Meadows", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."Pastures", 0) != COALESCE(s."Pastures", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."Forest", 0) != COALESCE(s."Forest", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."Bushes", 0) != COALESCE(s."Bushes", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."Swamp", 0) != COALESCE(s."Swamp", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."UnderFishPonds", 0) != COALESCE(s."UnderFishPonds", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."Flooded", 0) != COALESCE(s."Flooded", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."UnderBuildings", 0) != COALESCE(s."UnderBuildings", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."UnderRoads", 0) != COALESCE(s."UnderRoads", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."OtherLand", 0) != COALESCE(s."OtherLand", 0)
      OR COALESCE(nivkis_parcelpart_landpurpose."Drained", 0) != COALESCE(s."Drained", 0)
      );

  INSERT INTO vzd.nivkis_parcelpart_landpurpose (
    "ParcelPartCadastreNr"
    ,"LandPurposeKindId"
    ,"Areable"
    ,"Orchards"
    ,"Meadows"
    ,"Pastures"
    ,"Forest"
    ,"Bushes"
    ,"Swamp"
    ,"UnderFishPonds"
    ,"Flooded"
    ,"UnderBuildings"
    ,"UnderRoads"
    ,"OtherLand"
    ,"Drained"
    ,date_created
    )
  SELECT s."ParcelPartCadastreNr"
    ,s."LandPurposeKindId"
    ,s."Areable"
    ,s."Orchards"
    ,s."Meadows"
    ,s."Pastures"
    ,s."Forest"
    ,s."Bushes"
    ,s."Swamp"
    ,s."UnderFishPonds"
    ,s."Flooded"
    ,s."UnderBuildings"
    ,s."UnderRoads"
    ,s."OtherLand"
    ,s."Drained"
    ,d."PreparedDate"
  FROM nivkis_parcelpart_tmp_landpurpose s
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  INNER JOIN vzd.nivkis_parcelpart_landpurpose u ON s."ParcelPartCadastreNr" = u."ParcelPartCadastreNr"
    AND s."LandPurposeKindId" = u."LandPurposeKindId"
  WHERE (
      COALESCE(u."Areable", 0) != COALESCE(s."Areable", 0)
      OR COALESCE(u."Orchards", 0) != COALESCE(s."Orchards", 0)
      OR COALESCE(u."Meadows", 0) != COALESCE(s."Meadows", 0)
      OR COALESCE(u."Pastures", 0) != COALESCE(s."Pastures", 0)
      OR COALESCE(u."Forest", 0) != COALESCE(s."Forest", 0)
      OR COALESCE(u."Bushes", 0) != COALESCE(s."Bushes", 0)
      OR COALESCE(u."Swamp", 0) != COALESCE(s."Swamp", 0)
      OR COALESCE(u."UnderFishPonds", 0) != COALESCE(s."UnderFishPonds", 0)
      OR COALESCE(u."Flooded", 0) != COALESCE(s."Flooded", 0)
      OR COALESCE(u."UnderBuildings", 0) != COALESCE(s."UnderBuildings", 0)
      OR COALESCE(u."UnderRoads", 0) != COALESCE(s."UnderRoads", 0)
      OR COALESCE(u."OtherLand", 0) != COALESCE(s."OtherLand", 0)
      OR COALESCE(u."Drained", 0) != COALESCE(s."Drained", 0)
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauns kadastra objekts un/vai nekustamā īpašuma lietošanas mērķa kods.
  INSERT INTO vzd.nivkis_parcelpart_landpurpose (
    "ParcelPartCadastreNr"
    ,"LandPurposeKindId"
    ,"Areable"
    ,"Orchards"
    ,"Meadows"
    ,"Pastures"
    ,"Forest"
    ,"Bushes"
    ,"Swamp"
    ,"UnderFishPonds"
    ,"Flooded"
    ,"UnderBuildings"
    ,"UnderRoads"
    ,"OtherLand"
    ,"Drained"
    ,date_created
    )
  SELECT s."ParcelPartCadastreNr"
    ,s."LandPurposeKindId"
    ,s."Areable"
    ,s."Orchards"
    ,s."Meadows"
    ,s."Pastures"
    ,s."Forest"
    ,s."Bushes"
    ,s."Swamp"
    ,s."UnderFishPonds"
    ,s."Flooded"
    ,s."UnderBuildings"
    ,s."UnderRoads"
    ,s."OtherLand"
    ,s."Drained"
    ,d."PreparedDate"
  FROM nivkis_parcelpart_tmp_landpurpose s
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_parcelpart_landpurpose u ON s."ParcelPartCadastreNr" = u."ParcelPartCadastreNr"
    AND s."LandPurposeKindId" = u."LandPurposeKindId"
  WHERE u."ParcelPartCadastreNr" IS NULL;

  --SurveyList.
  CREATE TEMPORARY TABLE nivkis_parcelpart_tmp_survey AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/ParcelPartItemData/ParcelPartBasicData/ParcelPartCadastreNr/text()', a."ParcelPartItemData")) [1]::TEXT "ParcelPartCadastreNr"
      ,t."SurveyData"
    FROM nivkis_parcelpart_tmp1 a
      ,LATERAL UNNEST((XPATH('/ParcelPartItemData/SurveyList/SurveyData', "ParcelPartItemData"))::TEXT []) t("SurveyData")
    )
    ,b
  AS (
    SELECT "ParcelPartCadastreNr"
      ,"SurveyData"::XML "SurveyData"
    FROM a
    )
  SELECT "ParcelPartCadastreNr"
    ,(XPATH('/SurveyData/SurveyKind/text()', "SurveyData")) [1]::TEXT "SurveyKind"
    ,(XPATH('/SurveyData/SurveyDate/text()', "SurveyData")) [1]::TEXT::DATE "SurveyDate"
  FROM b;

  --Papildina SurveyKind klasifikatoru.
  INSERT INTO vzd.nivkis_parcel_survey_kind ("SurveyKind")
  SELECT DISTINCT "SurveyKind"
  FROM nivkis_parcelpart_tmp_survey
  WHERE "SurveyKind" IS NOT NULL
    AND "SurveyKind" NOT IN (
      SELECT "SurveyKind"
      FROM vzd.nivkis_parcel_survey_kind
      )
  ORDER BY "SurveyKind";

  --Izmanto ID no klasifikatoriem.
  CREATE TEMPORARY TABLE nivkis_parcelpart_tmp_survey_2 AS
  SELECT a."ParcelPartCadastreNr"
    ,b.id "SurveyKind"
    ,a."SurveyDate"
  FROM nivkis_parcelpart_tmp_survey a
  INNER JOIN vzd.nivkis_parcel_survey_kind b ON a."SurveyKind" = b."SurveyKind";

  --nivkis_parcelpart_survey.
  ---Kadastra objekts un/vai tā atribūti vairāk neeksistē vai mainīti.
  UPDATE vzd.nivkis_parcelpart_survey uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_parcelpart_survey u
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_parcelpart_tmp_survey_2 s ON u."ParcelPartCadastreNr" = s."ParcelPartCadastreNr"
    AND u."SurveyKind" = s."SurveyKind"
    AND u."SurveyDate" = s."SurveyDate"
  WHERE s."ParcelPartCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Jauns kadastra objekts vai mainīti atribūti.
  INSERT INTO vzd.nivkis_parcelpart_survey (
    "ParcelPartCadastreNr"
    ,"SurveyKind"
    ,"SurveyDate"
    ,date_created
    )
  SELECT s."ParcelPartCadastreNr"
    ,s."SurveyKind"
    ,s."SurveyDate"
    ,d."PreparedDate"
  FROM nivkis_parcelpart_tmp_survey_2 s
  CROSS JOIN nivkis_parcelpart_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_parcelpart_survey u ON s."ParcelPartCadastreNr" = u."ParcelPartCadastreNr"
    AND s."SurveyKind" = u."SurveyKind"
    AND s."SurveyDate" = u."SurveyDate"
    AND (
      u.date_deleted = d."PreparedDate"
      OR u.date_deleted IS NULL
      )
  WHERE u."ParcelPartCadastreNr" IS NULL;

  RAISE NOTICE 'Dati nivkis_parcelpart atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_parcelpart nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_parcelpart_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_parcelpart_proc() TO scheduler;