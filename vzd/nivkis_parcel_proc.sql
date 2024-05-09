CREATE OR REPLACE PROCEDURE vzd.nivkis_parcel_proc(
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
  FROM vzd.nivkis_parcel
  
  UNION
  
  SELECT date_deleted "date"
  FROM vzd.nivkis_parcel
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

--PreparedDate.
CREATE TEMPORARY TABLE nivkis_parcel_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((XPATH('ParcelFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_parcel_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_parcel_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_parcel atjaunošanu ar % datiem.', date_files;

  --ParcelItemData.
  CREATE TEMPORARY TABLE nivkis_parcel_tmp1 AS
  SELECT UNNEST(XPATH('ParcelFullData/ParcelItemList/ParcelItemData', data)) "ParcelItemData"
  FROM vzd.nivkis_parcel_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_parcel_tmp;

  --ParcelBasicData.
  CREATE TEMPORARY TABLE nivkis_parcel_tmp2 AS
  SELECT DISTINCT (XPATH('/ParcelItemData/ParcelBasicData/ParcelCadastreNr/text()', "ParcelItemData")) [1]::TEXT "ParcelCadastreNr"
    ,(XPATH('/ParcelItemData/ParcelBasicData/ParcelStatus/ParcelStatusKindId/text()', "ParcelItemData")) [1]::TEXT::SMALLINT "ParcelStatusKindId"
    ,(XPATH('/ParcelItemData/ParcelBasicData/ParcelStatus/ParcelStatusKindName/text()', "ParcelItemData")) [1]::TEXT "ParcelStatusKindName"
    --,(XPATH('/ParcelItemData/ParcelBasicData/ParcelVARISCode/text()', "ParcelItemData")) [1]::TEXT::INT "ParcelVARISCode"
    --,(XPATH('/ParcelItemData/ParcelBasicData/ATVKCode/text()', "ParcelItemData")) [1]::TEXT "ATVKCode"
    ,(XPATH('/ParcelItemData/ParcelBasicData/ParcelArea/text()', "ParcelItemData")) [1]::TEXT::INT "ParcelArea"
    ,(XPATH('/ParcelItemData/ParcelBasicData/ParcelLizValue/text()', "ParcelItemData")) [1]::TEXT::SMALLINT "ParcelLizValue"
    ,(XPATH('/ParcelItemData/ParcelBasicData/NewForestArea/text()', "ParcelItemData")) [1]::TEXT::INT "NewForestArea"
  FROM nivkis_parcel_tmp1;

  --Papildina ParcelStatus klasifikatoru.
  INSERT INTO vzd.nivkis_parcel_status
  SELECT DISTINCT "ParcelStatusKindId"
    ,"ParcelStatusKindName"
  FROM nivkis_parcel_tmp2
  WHERE "ParcelStatusKindId" IS NOT NULL
    AND "ParcelStatusKindId" NOT IN (
      SELECT "ParcelStatusKindId"
      FROM vzd.nivkis_parcel_status
      )
  ORDER BY "ParcelStatusKindId";

  --nivkis_parcel.
  ---Kadastra objekts vairāk neeksistē.
  UPDATE vzd.nivkis_parcel uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_parcel u
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_parcel_tmp2 s ON u."ParcelCadastreNr" = s."ParcelCadastreNr"
  WHERE s."ParcelCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_parcel
  SET date_deleted = d."PreparedDate"
  FROM nivkis_parcel_tmp2 s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  WHERE nivkis_parcel."ParcelCadastreNr" = s."ParcelCadastreNr"
    AND nivkis_parcel.date_deleted IS NULL
    AND (
      COALESCE(nivkis_parcel."ParcelStatusKindId", 0) != COALESCE(s."ParcelStatusKindId", 0)
      OR COALESCE(nivkis_parcel."ParcelArea", 0) != COALESCE(s."ParcelArea", 0)
      OR COALESCE(nivkis_parcel."ParcelLizValue", 0) != COALESCE(s."ParcelLizValue", 0)
      OR COALESCE(nivkis_parcel."NewForestArea", 0) != COALESCE(s."NewForestArea", 0)
      );

  INSERT INTO vzd.nivkis_parcel (
    "ParcelCadastreNr"
    ,"ParcelStatusKindId"
    ,"ParcelArea"
    ,"ParcelLizValue"
    ,"NewForestArea"
    ,date_created
    )
  SELECT s."ParcelCadastreNr"
    ,s."ParcelStatusKindId"
    ,s."ParcelArea"
    ,s."ParcelLizValue"
    ,s."NewForestArea"
    ,d."PreparedDate"
  FROM nivkis_parcel_tmp2 s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  INNER JOIN vzd.nivkis_parcel u ON s."ParcelCadastreNr" = u."ParcelCadastreNr"
  WHERE (
      COALESCE(u."ParcelStatusKindId", 0) != COALESCE(s."ParcelStatusKindId", 0)
      OR COALESCE(u."ParcelArea", 0) != COALESCE(s."ParcelArea", 0)
      OR COALESCE(u."ParcelLizValue", 0) != COALESCE(s."ParcelLizValue", 0)
      OR COALESCE(u."NewForestArea", 0) != COALESCE(s."NewForestArea", 0)
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_parcel (
    "ParcelCadastreNr"
    ,"ParcelStatusKindId"
    ,"ParcelArea"
    ,"ParcelLizValue"
    ,"NewForestArea"
    ,date_created
    )
  SELECT s."ParcelCadastreNr"
    ,s."ParcelStatusKindId"
    ,s."ParcelArea"
    ,s."ParcelLizValue"
    ,s."NewForestArea"
    ,d."PreparedDate"
  FROM nivkis_parcel_tmp2 s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_parcel u ON s."ParcelCadastreNr" = u."ParcelCadastreNr"
  WHERE u."ParcelCadastreNr" IS NULL;

  --LandPurposeList.
  CREATE TEMPORARY TABLE nivkis_parcel_tmp_landpurpose AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/ParcelItemData/ParcelBasicData/ParcelCadastreNr/text()', a."ParcelItemData")) [1]::TEXT "ParcelCadastreNr"
      ,t."LandPurposeData"
    FROM nivkis_parcel_tmp1 a
      ,LATERAL UNNEST((XPATH('/ParcelItemData/LandPurposeList/LandPurposeData', "ParcelItemData"))::TEXT []) t("LandPurposeData")
    )
    ,b
  AS (
    SELECT "ParcelCadastreNr"
      ,"LandPurposeData"::XML "LandPurposeData"
    FROM a
    )
  SELECT "ParcelCadastreNr"
    ,(XPATH('/LandPurposeData/LandPurposeKind/LandPurposeKindId/text()', "LandPurposeData")) [1]::TEXT::SMALLINT "LandPurposeKindId"
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
  FROM nivkis_parcel_tmp_landpurpose
  WHERE "LandPurposeKindId" IS NOT NULL
    AND "LandPurposeKindId" NOT IN (
      SELECT "LandPurposeKindId"
      FROM vzd.nivkis_parcel_landpurpose_kind
      )
  ORDER BY "LandPurposeKindId";

  --nivkis_parcel_landpurpose.
  ---Kadastra objekts un/vai nekustamā īpašuma lietošanas mērķa kods vairāk neeksistē.
  UPDATE vzd.nivkis_parcel_landpurpose uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_parcel_landpurpose u
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_parcel_tmp_landpurpose s ON u."ParcelCadastreNr" = s."ParcelCadastreNr"
    AND u."LandPurposeKindId" = s."LandPurposeKindId"
  WHERE s."ParcelCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_parcel_landpurpose
  SET date_deleted = d."PreparedDate"
  FROM nivkis_parcel_tmp_landpurpose s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  WHERE nivkis_parcel_landpurpose."ParcelCadastreNr" = s."ParcelCadastreNr"
    AND nivkis_parcel_landpurpose."LandPurposeKindId" = s."LandPurposeKindId"
    AND nivkis_parcel_landpurpose.date_deleted IS NULL
    AND (
      COALESCE(nivkis_parcel_landpurpose."Areable", 0) != COALESCE(s."Areable", 0)
      OR COALESCE(nivkis_parcel_landpurpose."Orchards", 0) != COALESCE(s."Orchards", 0)
      OR COALESCE(nivkis_parcel_landpurpose."Meadows", 0) != COALESCE(s."Meadows", 0)
      OR COALESCE(nivkis_parcel_landpurpose."Pastures", 0) != COALESCE(s."Pastures", 0)
      OR COALESCE(nivkis_parcel_landpurpose."Forest", 0) != COALESCE(s."Forest", 0)
      OR COALESCE(nivkis_parcel_landpurpose."Bushes", 0) != COALESCE(s."Bushes", 0)
      OR COALESCE(nivkis_parcel_landpurpose."Swamp", 0) != COALESCE(s."Swamp", 0)
      OR COALESCE(nivkis_parcel_landpurpose."UnderFishPonds", 0) != COALESCE(s."UnderFishPonds", 0)
      OR COALESCE(nivkis_parcel_landpurpose."Flooded", 0) != COALESCE(s."Flooded", 0)
      OR COALESCE(nivkis_parcel_landpurpose."UnderBuildings", 0) != COALESCE(s."UnderBuildings", 0)
      OR COALESCE(nivkis_parcel_landpurpose."UnderRoads", 0) != COALESCE(s."UnderRoads", 0)
      OR COALESCE(nivkis_parcel_landpurpose."OtherLand", 0) != COALESCE(s."OtherLand", 0)
      OR COALESCE(nivkis_parcel_landpurpose."Drained", 0) != COALESCE(s."Drained", 0)
      );

  INSERT INTO vzd.nivkis_parcel_landpurpose (
    "ParcelCadastreNr"
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
  SELECT s."ParcelCadastreNr"
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
  FROM nivkis_parcel_tmp_landpurpose s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  INNER JOIN vzd.nivkis_parcel_landpurpose u ON s."ParcelCadastreNr" = u."ParcelCadastreNr"
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
  INSERT INTO vzd.nivkis_parcel_landpurpose (
    "ParcelCadastreNr"
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
  SELECT s."ParcelCadastreNr"
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
  FROM nivkis_parcel_tmp_landpurpose s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_parcel_landpurpose u ON s."ParcelCadastreNr" = u."ParcelCadastreNr"
    AND s."LandPurposeKindId" = u."LandPurposeKindId"
  WHERE u."ParcelCadastreNr" IS NULL;

  --SurveyList.
  CREATE TEMPORARY TABLE nivkis_parcel_tmp_survey AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/ParcelItemData/ParcelBasicData/ParcelCadastreNr/text()', a."ParcelItemData")) [1]::TEXT "ParcelCadastreNr"
      ,t."SurveyData"
    FROM nivkis_parcel_tmp1 a
      ,LATERAL UNNEST((XPATH('/ParcelItemData/SurveyList/SurveyData', "ParcelItemData"))::TEXT []) t("SurveyData")
    )
    ,b
  AS (
    SELECT "ParcelCadastreNr"
      ,"SurveyData"::XML "SurveyData"
    FROM a
    )
  SELECT "ParcelCadastreNr"
    ,(XPATH('/SurveyData/SurveyKind/text()', "SurveyData")) [1]::TEXT "SurveyKind"
    ,(XPATH('/SurveyData/SurveyDate/text()', "SurveyData")) [1]::TEXT::DATE "SurveyDate"
  FROM b;

  --Papildina SurveyKind klasifikatoru.
  INSERT INTO vzd.nivkis_parcel_survey_kind ("SurveyKind")
  SELECT DISTINCT "SurveyKind"
  FROM nivkis_parcel_tmp_survey
  WHERE "SurveyKind" IS NOT NULL
    AND "SurveyKind" NOT IN (
      SELECT "SurveyKind"
      FROM vzd.nivkis_parcel_survey_kind
      )
  ORDER BY "SurveyKind";

  --Izmanto ID no klasifikatoriem.
  CREATE TEMPORARY TABLE nivkis_parcel_tmp_survey_2 AS
  SELECT a."ParcelCadastreNr"
    ,b.id "SurveyKind"
    ,a."SurveyDate"
  FROM nivkis_parcel_tmp_survey a
  INNER JOIN vzd.nivkis_parcel_survey_kind b ON a."SurveyKind" = b."SurveyKind";

  --nivkis_parcel_survey.
  ---Kadastra objekts un/vai tā atribūti vairāk neeksistē vai mainīti.
  UPDATE vzd.nivkis_parcel_survey uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_parcel_survey u
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_parcel_tmp_survey_2 s ON u."ParcelCadastreNr" = s."ParcelCadastreNr"
    AND u."SurveyKind" = s."SurveyKind"
    AND u."SurveyDate" = s."SurveyDate"
  WHERE s."ParcelCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Jauns kadastra objekts vai mainīti atribūti.
  INSERT INTO vzd.nivkis_parcel_survey (
    "ParcelCadastreNr"
    ,"SurveyKind"
    ,"SurveyDate"
    ,date_created
    )
  SELECT s."ParcelCadastreNr"
    ,s."SurveyKind"
    ,s."SurveyDate"
    ,d."PreparedDate"
  FROM nivkis_parcel_tmp_survey_2 s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_parcel_survey u ON s."ParcelCadastreNr" = u."ParcelCadastreNr"
    AND s."SurveyKind" = u."SurveyKind"
    AND s."SurveyDate" = u."SurveyDate"
  WHERE u."ParcelCadastreNr" IS NULL;

  --PlannedParcelList.
  CREATE TEMPORARY TABLE nivkis_parcel_tmp_planned AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/ParcelItemData/ParcelBasicData/ParcelCadastreNr/text()', a."ParcelItemData")) [1]::TEXT "ParcelCadastreNr"
      ,t."PlannedParcelData"
    FROM nivkis_parcel_tmp1 a
      ,LATERAL UNNEST((XPATH('/ParcelItemData/PlannedParcelList/PlannedParcelData', "ParcelItemData"))::TEXT []) t("PlannedParcelData")
    )
    ,b
  AS (
    SELECT "ParcelCadastreNr"
      ,"PlannedParcelData"::XML "PlannedParcelData"
    FROM a
    )
  SELECT "ParcelCadastreNr"
    ,(XPATH('/PlannedParcelData/VARISCode/text()', "PlannedParcelData")) [1]::TEXT::INT "VARISCode"
    ,(XPATH('/PlannedParcelData/PlannedParcelCadastreNr/text()', "PlannedParcelData")) [1]::TEXT "PlannedParcelCadastreNr"
    ,(XPATH('/PlannedParcelData/PlannedParcelArea/text()', "PlannedParcelData")) [1]::TEXT::BIGINT "PlannedParcelArea"
  FROM b;

  --nivkis_parcel_planned.
  ---Kadastra objekts vairāk neeksistē.
  UPDATE vzd.nivkis_parcel_planned uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_parcel_planned u
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_parcel_tmp_planned s ON u."ParcelCadastreNr" = s."ParcelCadastreNr"
    AND u."PlannedParcelCadastreNr" = s."PlannedParcelCadastreNr"
  WHERE s."ParcelCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_parcel_planned
  SET date_deleted = d."PreparedDate"
  FROM nivkis_parcel_tmp_planned s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  WHERE nivkis_parcel_planned."ParcelCadastreNr" = s."ParcelCadastreNr"
    AND nivkis_parcel_planned."PlannedParcelCadastreNr" = s."PlannedParcelCadastreNr"
    AND nivkis_parcel_planned.date_deleted IS NULL
    AND (
      COALESCE(nivkis_parcel_planned."VARISCode", 0) != COALESCE(s."VARISCode", 0)
      OR COALESCE(nivkis_parcel_planned."PlannedParcelArea", 0) != COALESCE(s."PlannedParcelArea", 0)
      );

  INSERT INTO vzd.nivkis_parcel_planned (
    "ParcelCadastreNr"
    ,"VARISCode"
    ,"PlannedParcelCadastreNr"
    ,"PlannedParcelArea"
    ,date_created
    )
  SELECT s."ParcelCadastreNr"
    ,s."VARISCode"
    ,s."PlannedParcelCadastreNr"
    ,s."PlannedParcelArea"
    ,d."PreparedDate"
  FROM nivkis_parcel_tmp_planned s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  INNER JOIN vzd.nivkis_parcel_planned u ON s."ParcelCadastreNr" = u."ParcelCadastreNr"
    AND s."PlannedParcelCadastreNr" = u."PlannedParcelCadastreNr"
  WHERE (
      COALESCE(u."VARISCode", 0) != COALESCE(s."VARISCode", 0)
      OR COALESCE(u."PlannedParcelArea", 0) != COALESCE(s."PlannedParcelArea", 0)
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_parcel_planned (
    "ParcelCadastreNr"
    ,"VARISCode"
    ,"PlannedParcelCadastreNr"
    ,"PlannedParcelArea"
    ,date_created
    )
  SELECT s."ParcelCadastreNr"
    ,s."VARISCode"
    ,s."PlannedParcelCadastreNr"
    ,s."PlannedParcelArea"
    ,d."PreparedDate"
  FROM nivkis_parcel_tmp_planned s
  CROSS JOIN nivkis_parcel_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_parcel_planned u ON s."ParcelCadastreNr" = u."ParcelCadastreNr"
    AND s."PlannedParcelCadastreNr" = u."PlannedParcelCadastreNr"
  WHERE u."ParcelCadastreNr" IS NULL;

  RAISE NOTICE 'Dati nivkis_parcel atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_parcel nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_parcel_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_parcel_proc() TO scheduler;