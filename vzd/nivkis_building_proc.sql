CREATE OR REPLACE PROCEDURE vzd.nivkis_building_proc(
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
  FROM vzd.nivkis_building
  
  UNION
  
  SELECT date_deleted "date"
  FROM vzd.nivkis_building
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

--PreparedDate.
CREATE TEMPORARY TABLE nivkis_building_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((XPATH('BuildingFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_building_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_building_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_building atjaunošanu ar % datiem.', date_files;

  --BuildingItemData.
  CREATE TEMPORARY TABLE nivkis_building_tmp1 AS
  SELECT UNNEST(XPATH('BuildingFullData/BuildingItemList/BuildingItemData', data)) "BuildingItemData"
  FROM vzd.nivkis_building_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_building_tmp;

  --ObjectRelation, BuildingBasicData un BuildingHistoricalData.
  CREATE TEMPORARY TABLE nivkis_building_tmp2 AS
  SELECT DISTINCT (XPATH('/BuildingItemData/BuildingBasicData/BuildingCadastreNr/text()', "BuildingItemData")) [1]::TEXT "BuildingCadastreNr"
    --,(XPATH('/BuildingItemData/BuildingBasicData/VARISCode/text()', "BuildingItemData")) [1]::TEXT::INT "VARISCode"
    ,(XPATH('/BuildingItemData/ObjectRelation/ObjectCadastreNr/text()', "BuildingItemData")) [1]::TEXT "ParcelCadastreNr"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingName/text()', "BuildingItemData")) [1]::TEXT "BuildingName"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingUseKind/BuildingUseKindId/text()', "BuildingItemData")) [1]::TEXT::SMALLINT "BuildingUseKindId"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingUseKind/BuildingUseKindName/text()', "BuildingItemData")) [1]::TEXT "BuildingUseKindName"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(10, 2) "BuildingArea"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingConstrArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(11, 2) "BuildingConstrArea"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingGroundFloors/text()', "BuildingItemData")) [1]::TEXT::SMALLINT "BuildingGroundFloors"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingUndergroundFloors/text()', "BuildingItemData")) [1]::TEXT::SMALLINT "BuildingUndergroundFloors"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingMaterialKind/MaterialKindId/text()', "BuildingItemData")) [1]::TEXT::SMALLINT "MaterialKindId"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingMaterialKind/MaterialKindName/text()', "BuildingItemData")) [1]::TEXT "MaterialKindName"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingPregCount/text()', "BuildingItemData")) [1]::TEXT::SMALLINT "BuildingPregCount"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingAcceptionYears/text()', "BuildingItemData")) [1]::TEXT "BuildingAcceptionYears"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingExploitYear/text()', "BuildingItemData")) [1]::TEXT::SMALLINT "BuildingExploitYear"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingDeprecation/text()', "BuildingItemData")) [1]::TEXT::SMALLINT "BuildingDeprecation"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingDepValDate/text()', "BuildingItemData")) [1]::TEXT::DATE "BuildingDepValDate"
    ,(XPATH('/BuildingItemData/BuildingBasicData/BuildingSurveyDate/text()', "BuildingItemData")) [1]::TEXT::DATE "BuildingSurveyDate"
    ,(XPATH('/BuildingItemData/BuildingBasicData/NotForLandBook/text()', "BuildingItemData")) [1]::TEXT "NotForLandBook"
    ,(XPATH('/BuildingItemData/BuildingBasicData/Prereg/text()', "BuildingItemData")) [1]::TEXT "Prereg"
    ,(XPATH('/BuildingItemData/BuildingBasicData/NotExist/text()', "BuildingItemData")) [1]::TEXT "NotExist"
    ,(XPATH('/BuildingItemData/BuildingBasicData/EngineeringStructureType/text()', "BuildingItemData")) [1]::TEXT "EngineeringStructureType"
    ,(XPATH('/BuildingItemData/BuildingHistoricalData/BuildingHistoricalLiter/text()', "BuildingItemData")) [1]::TEXT "BuildingHistoricalLiter"
    ,(XPATH('/BuildingItemData/BuildingHistoricalData/BuildingHistoricalName/text()', "BuildingItemData")) [1]::TEXT "BuildingHistoricalName"
    --,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(8, 1) "TotalArea"
    --,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/ExpedientArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(8, 1) "ExpedientArea"
    --,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/ExpedientAreaDetails/FlatTotalArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(7, 1) "FlatTotalArea"
    --,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/ExpedientAreaDetails/FlatTotalAreaDetails/FlatArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(7, 1) "FlatArea"
    ,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/ExpedientAreaDetails/FlatTotalAreaDetails/FlatAreaDetails/LivingArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(7, 1) "LivingArea"
    ,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/ExpedientAreaDetails/FlatTotalAreaDetails/FlatAreaDetails/FlatAuxArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(7, 1) "FlatAuxArea"
    ,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/ExpedientAreaDetails/FlatTotalAreaDetails/FlatOuterArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(6, 1) "FlatOuterArea"
    --,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/ExpedientAreaDetails/NonlivingTotalArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(8, 1) "NonlivingTotalArea"
    ,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/ExpedientAreaDetails/NonlivingAreaDetails/NonlivingInteriorArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(8, 1) "NonlivingInteriorArea"
    ,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/ExpedientAreaDetails/NonlivingAreaDetails/NonlivingOuterArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(7, 1) "NonlivingOuterArea"
    --,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/SharedArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(7, 1) "SharedArea"
    ,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/SharedAreaDetails/SharedInteriorArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(7, 1) "SharedInteriorArea"
    ,(XPATH('/BuildingItemData/BuildingOrPremiseGroupExplicationData/TotalAreaDetails/SharedAreaDetails/SharedOuterArea/text()', "BuildingItemData")) [1]::TEXT::DECIMAL(6, 1) "SharedOuterArea"
  FROM nivkis_building_tmp1;

  --Papildina BuildingUseKind klasifikatoru.
  INSERT INTO vzd.nivkis_building_usekind
  SELECT DISTINCT "BuildingUseKindId"
    ,"BuildingUseKindName"
  FROM nivkis_building_tmp2
  WHERE "BuildingUseKindId" IS NOT NULL
    AND "BuildingUseKindId" NOT IN (
      SELECT "BuildingUseKindId"
      FROM vzd.nivkis_building_usekind
      )
  ORDER BY "BuildingUseKindId";

  --Papildina BuildingMaterialKind klasifikatoru.
  INSERT INTO vzd.nivkis_building_materialkind
  SELECT DISTINCT "MaterialKindId"
    ,"MaterialKindName"
  FROM nivkis_building_tmp2
  WHERE "MaterialKindId" IS NOT NULL
    AND "MaterialKindId" NOT IN (
      SELECT "MaterialKindId"
      FROM vzd.nivkis_building_materialkind
      )
  ORDER BY "MaterialKindId";

  --Papildina EngineeringStructureType klasifikatoru.
  INSERT INTO vzd.nivkis_building_estype ("EngineeringStructureType")
  SELECT DISTINCT "EngineeringStructureType"
  FROM nivkis_building_tmp2
  WHERE "EngineeringStructureType" IS NOT NULL
    AND "EngineeringStructureType" NOT IN (
      SELECT "EngineeringStructureType"
      FROM vzd.nivkis_building_estype
      )
  ORDER BY "EngineeringStructureType";

  --BuildingTypeData.
  CREATE TEMPORARY TABLE nivkis_building_tmp3 AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/BuildingItemData/BuildingBasicData/BuildingCadastreNr/text()', a."BuildingItemData")) [1]::TEXT "BuildingCadastreNr"
      ,t."BuildingKind"
    FROM nivkis_building_tmp1 a
      ,LATERAL UNNEST((XPATH('/BuildingItemData/BuildingTypeData/BuildingKind', "BuildingItemData"))::TEXT[]) t("BuildingKind")
    )
    ,b
  AS (
    SELECT "BuildingCadastreNr"
      ,"BuildingKind"::XML "BuildingKind"
    FROM a
    )
  SELECT "BuildingCadastreNr"
    ,(XPATH('/BuildingKind/BuildingKindId/text()', "BuildingKind")) [1]::TEXT::INT "BuildingKindId"
    ,(XPATH('/BuildingKind/BuildingKindName/text()', "BuildingKind")) [1]::TEXT "BuildingKindName"
  FROM b;

  --Papildina BuildingKind klasifikatoru.
  INSERT INTO vzd.nivkis_building_kind
  SELECT DISTINCT "BuildingKindId"
    ,"BuildingKindName"
  FROM nivkis_building_tmp3
  WHERE "BuildingKindId" IS NOT NULL
    AND "BuildingKindId" NOT IN (
      SELECT "BuildingKindId"
      FROM vzd.nivkis_building_kind
      )
  ORDER BY "BuildingKindId";

  CREATE TEMPORARY TABLE nivkis_building_tmp4 AS
  SELECT "BuildingCadastreNr"
    ,ARRAY_AGG("BuildingKindId" ORDER BY "BuildingKindId") "BuildingKindId"
  FROM nivkis_building_tmp3
  GROUP BY "BuildingCadastreNr";

  --Apvieno pagaidu tabulas vienā priekš nivkis_building.
  CREATE TEMPORARY TABLE nivkis_building_tmp_merged AS
  SELECT DISTINCT a."BuildingCadastreNr"
    ,a."ParcelCadastreNr"
    ,a."BuildingName"
    ,a."BuildingUseKindId"
    ,a."BuildingArea"
    ,a."BuildingConstrArea"
    ,a."BuildingGroundFloors"
    ,a."BuildingUndergroundFloors"
    ,a."MaterialKindId"
    ,a."BuildingPregCount"
    ,ARRAY(SELECT DISTINCT e FROM UNNEST(STRING_TO_ARRAY(a."BuildingAcceptionYears", ', ')::SMALLINT[]) a(e) ORDER BY e) "BuildingAcceptionYears"
    ,a."BuildingExploitYear"
    ,a."BuildingDeprecation"
    ,a."BuildingDepValDate"
    ,a."BuildingSurveyDate"
    ,CASE 
      WHEN a."NotForLandBook" IS NOT NULL
        THEN 1::BOOLEAN
      ELSE NULL
      END "NotForLandBook"
    ,CASE 
      WHEN a."Prereg" IS NOT NULL
        THEN 1::BOOLEAN
      ELSE NULL
      END "Prereg"
    ,CASE 
      WHEN a."NotExist" IS NOT NULL
        THEN 1::BOOLEAN
      ELSE NULL
      END "NotExist"
    ,c.id "EngineeringStructureType"
    ,b."BuildingKindId"
    ,a."BuildingHistoricalLiter"
    ,a."BuildingHistoricalName"
    ,a."LivingArea"
    ,a."FlatAuxArea"
    ,a."FlatOuterArea"
    ,a."NonlivingInteriorArea"
    ,a."NonlivingOuterArea"
    ,a."SharedInteriorArea"
    ,a."SharedOuterArea"
  FROM nivkis_building_tmp2 a
  INNER JOIN nivkis_building_tmp4 b ON a."BuildingCadastreNr" = b."BuildingCadastreNr"
  LEFT OUTER JOIN vzd.nivkis_building_estype c ON a."EngineeringStructureType" = c."EngineeringStructureType";

  --nivkis_building.
  ---Kadastra objekts vairāk neeksistē.
  UPDATE vzd.nivkis_building uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_building u
  CROSS JOIN nivkis_building_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_building_tmp_merged s ON u."BuildingCadastreNr" = s."BuildingCadastreNr"
  WHERE s."BuildingCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_building
  SET date_deleted = d."PreparedDate"
  FROM nivkis_building_tmp_merged s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  WHERE nivkis_building."BuildingCadastreNr" = s."BuildingCadastreNr"
    AND nivkis_building.date_deleted IS NULL
    AND (
      COALESCE(nivkis_building."ParcelCadastreNr", '') != COALESCE(s."ParcelCadastreNr", '')
      OR COALESCE(nivkis_building."BuildingName", '') != COALESCE(s."BuildingName", '')
      OR COALESCE(nivkis_building."BuildingUseKindId", 0) != COALESCE(s."BuildingUseKindId", 0)
      OR COALESCE(nivkis_building."BuildingArea", 0) != COALESCE(s."BuildingArea", 0)
      OR COALESCE(nivkis_building."BuildingConstrArea", 0) != COALESCE(s."BuildingConstrArea", 0)
      OR COALESCE(nivkis_building."BuildingGroundFloors", 0) != COALESCE(s."BuildingGroundFloors", 0)
      OR COALESCE(nivkis_building."BuildingUndergroundFloors", 0) != COALESCE(s."BuildingUndergroundFloors", 0)
      OR COALESCE(nivkis_building."MaterialKindId", 0) != COALESCE(s."MaterialKindId", 0)
      OR COALESCE(nivkis_building."BuildingPregCount", 0) != COALESCE(s."BuildingPregCount", 0)
      OR COALESCE(nivkis_building."BuildingAcceptionYears", '{0}') != COALESCE(s."BuildingAcceptionYears", '{0}')
      OR COALESCE(nivkis_building."BuildingExploitYear", 0) != COALESCE(s."BuildingExploitYear", 0)
      OR COALESCE(nivkis_building."BuildingDeprecation", 0) != COALESCE(s."BuildingDeprecation", 0)
      OR COALESCE(nivkis_building."BuildingDepValDate", '1900-01-01') != COALESCE(s."BuildingDepValDate", '1900-01-01')
      OR COALESCE(nivkis_building."BuildingSurveyDate", '1900-01-01') != COALESCE(s."BuildingSurveyDate", '1900-01-01')
      OR COALESCE(nivkis_building."NotForLandBook", FALSE) != COALESCE(s."NotForLandBook", FALSE)
      OR COALESCE(nivkis_building."Prereg", FALSE) != COALESCE(s."Prereg", FALSE)
      OR COALESCE(nivkis_building."NotExist", FALSE) != COALESCE(s."NotExist", FALSE)
      OR COALESCE(nivkis_building."EngineeringStructureType", 0) != COALESCE(s."EngineeringStructureType", 0)
      OR COALESCE(nivkis_building."BuildingKindId", '{0}') != COALESCE(s."BuildingKindId", '{0}')
      OR COALESCE(nivkis_building."BuildingHistoricalLiter", '') != COALESCE(s."BuildingHistoricalLiter", '')
      OR COALESCE(nivkis_building."BuildingHistoricalName", '') != COALESCE(s."BuildingHistoricalName", '')
      OR COALESCE(nivkis_building."LivingArea", 0) != COALESCE(s."LivingArea", 0)
      OR COALESCE(nivkis_building."FlatAuxArea", 0) != COALESCE(s."FlatAuxArea", 0)
      OR COALESCE(nivkis_building."FlatOuterArea", 0) != COALESCE(s."FlatOuterArea", 0)
      OR COALESCE(nivkis_building."NonlivingInteriorArea", 0) != COALESCE(s."NonlivingInteriorArea", 0)
      OR COALESCE(nivkis_building."NonlivingOuterArea", 0) != COALESCE(s."NonlivingOuterArea", 0)
      OR COALESCE(nivkis_building."SharedInteriorArea", 0) != COALESCE(s."SharedInteriorArea", 0)
      OR COALESCE(nivkis_building."SharedOuterArea", 0) != COALESCE(s."SharedOuterArea", 0)
      );

  INSERT INTO vzd.nivkis_building (
    "BuildingCadastreNr"
    ,"ParcelCadastreNr"
    ,"BuildingName"
    ,"BuildingUseKindId"
    ,"BuildingArea"
    ,"BuildingConstrArea"
    ,"BuildingGroundFloors"
    ,"BuildingUndergroundFloors"
    ,"MaterialKindId"
    ,"BuildingPregCount"
    ,"BuildingAcceptionYears"
    ,"BuildingExploitYear"
    ,"BuildingDeprecation"
    ,"BuildingDepValDate"
    ,"BuildingSurveyDate"
    ,"NotForLandBook"
    ,"Prereg"
    ,"NotExist"
    ,"EngineeringStructureType"
    ,"BuildingKindId"
    ,"BuildingHistoricalLiter"
    ,"BuildingHistoricalName"
    ,"LivingArea"
    ,"FlatAuxArea"
    ,"FlatOuterArea"
    ,"NonlivingInteriorArea"
    ,"NonlivingOuterArea"
    ,"SharedInteriorArea"
    ,"SharedOuterArea"
    ,date_created
    )
  SELECT s."BuildingCadastreNr"
    ,s."ParcelCadastreNr"
    ,s."BuildingName"
    ,s."BuildingUseKindId"
    ,s."BuildingArea"
    ,s."BuildingConstrArea"
    ,s."BuildingGroundFloors"
    ,s."BuildingUndergroundFloors"
    ,s."MaterialKindId"
    ,s."BuildingPregCount"
    ,s."BuildingAcceptionYears"
    ,s."BuildingExploitYear"
    ,s."BuildingDeprecation"
    ,s."BuildingDepValDate"
    ,s."BuildingSurveyDate"
    ,s."NotForLandBook"
    ,s."Prereg"
    ,s."NotExist"
    ,s."EngineeringStructureType"
    ,s."BuildingKindId"
    ,s."BuildingHistoricalLiter"
    ,s."BuildingHistoricalName"
    ,s."LivingArea"
    ,s."FlatAuxArea"
    ,s."FlatOuterArea"
    ,s."NonlivingInteriorArea"
    ,s."NonlivingOuterArea"
    ,s."SharedInteriorArea"
    ,s."SharedOuterArea"
    ,d."PreparedDate"
  FROM nivkis_building_tmp_merged s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  INNER JOIN vzd.nivkis_building u ON s."BuildingCadastreNr" = u."BuildingCadastreNr"
  WHERE (
      COALESCE(u."ParcelCadastreNr", '') != COALESCE(s."ParcelCadastreNr", '')
      OR COALESCE(u."BuildingName", '') != COALESCE(s."BuildingName", '')
      OR COALESCE(u."BuildingUseKindId", 0) != COALESCE(s."BuildingUseKindId", 0)
      OR COALESCE(u."BuildingArea", 0) != COALESCE(s."BuildingArea", 0)
      OR COALESCE(u."BuildingConstrArea", 0) != COALESCE(s."BuildingConstrArea", 0)
      OR COALESCE(u."BuildingGroundFloors", 0) != COALESCE(s."BuildingGroundFloors", 0)
      OR COALESCE(u."BuildingUndergroundFloors", 0) != COALESCE(s."BuildingUndergroundFloors", 0)
      OR COALESCE(u."MaterialKindId", 0) != COALESCE(s."MaterialKindId", 0)
      OR COALESCE(u."BuildingPregCount", 0) != COALESCE(s."BuildingPregCount", 0)
      OR COALESCE(u."BuildingAcceptionYears", '{0}') != COALESCE(s."BuildingAcceptionYears", '{0}')
      OR COALESCE(u."BuildingExploitYear", 0) != COALESCE(s."BuildingExploitYear", 0)
      OR COALESCE(u."BuildingDeprecation", 0) != COALESCE(s."BuildingDeprecation", 0)
      OR COALESCE(u."BuildingDepValDate", '1900-01-01') != COALESCE(s."BuildingDepValDate", '1900-01-01')
      OR COALESCE(u."BuildingSurveyDate", '1900-01-01') != COALESCE(s."BuildingSurveyDate", '1900-01-01')
      OR COALESCE(u."NotForLandBook", FALSE) != COALESCE(s."NotForLandBook", FALSE)
      OR COALESCE(u."Prereg", FALSE) != COALESCE(s."Prereg", FALSE)
      OR COALESCE(u."NotExist", FALSE) != COALESCE(s."NotExist", FALSE)
      OR COALESCE(u."EngineeringStructureType", 0) != COALESCE(s."EngineeringStructureType", 0)
      OR COALESCE(u."BuildingKindId", '{0}') != COALESCE(s."BuildingKindId", '{0}')
      OR COALESCE(u."BuildingHistoricalLiter", '') != COALESCE(s."BuildingHistoricalLiter", '')
      OR COALESCE(u."BuildingHistoricalName", '') != COALESCE(s."BuildingHistoricalName", '')
      OR COALESCE(u."LivingArea", 0) != COALESCE(s."LivingArea", 0)
      OR COALESCE(u."FlatAuxArea", 0) != COALESCE(s."FlatAuxArea", 0)
      OR COALESCE(u."FlatOuterArea", 0) != COALESCE(s."FlatOuterArea", 0)
      OR COALESCE(u."NonlivingInteriorArea", 0) != COALESCE(s."NonlivingInteriorArea", 0)
      OR COALESCE(u."NonlivingOuterArea", 0) != COALESCE(s."NonlivingOuterArea", 0)
      OR COALESCE(u."SharedInteriorArea", 0) != COALESCE(s."SharedInteriorArea", 0)
      OR COALESCE(u."SharedOuterArea", 0) != COALESCE(s."SharedOuterArea", 0)
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_building (
    "BuildingCadastreNr"
    ,"ParcelCadastreNr"
    ,"BuildingName"
    ,"BuildingUseKindId"
    ,"BuildingArea"
    ,"BuildingConstrArea"
    ,"BuildingGroundFloors"
    ,"BuildingUndergroundFloors"
    ,"MaterialKindId"
    ,"BuildingPregCount"
    ,"BuildingAcceptionYears"
    ,"BuildingExploitYear"
    ,"BuildingDeprecation"
    ,"BuildingDepValDate"
    ,"BuildingSurveyDate"
    ,"NotForLandBook"
    ,"Prereg"
    ,"NotExist"
    ,"EngineeringStructureType"
    ,"BuildingKindId"
    ,"BuildingHistoricalLiter"
    ,"BuildingHistoricalName"
    ,"LivingArea"
    ,"FlatAuxArea"
    ,"FlatOuterArea"
    ,"NonlivingInteriorArea"
    ,"NonlivingOuterArea"
    ,"SharedInteriorArea"
    ,"SharedOuterArea"
    ,date_created
    )
  SELECT s."BuildingCadastreNr"
    ,s."ParcelCadastreNr"
    ,s."BuildingName"
    ,s."BuildingUseKindId"
    ,s."BuildingArea"
    ,s."BuildingConstrArea"
    ,s."BuildingGroundFloors"
    ,s."BuildingUndergroundFloors"
    ,s."MaterialKindId"
    ,s."BuildingPregCount"
    ,s."BuildingAcceptionYears"
    ,s."BuildingExploitYear"
    ,s."BuildingDeprecation"
    ,s."BuildingDepValDate"
    ,s."BuildingSurveyDate"
    ,s."NotForLandBook"
    ,s."Prereg"
    ,s."NotExist"
    ,s."EngineeringStructureType"
    ,s."BuildingKindId"
    ,s."BuildingHistoricalLiter"
    ,s."BuildingHistoricalName"
    ,s."LivingArea"
    ,s."FlatAuxArea"
    ,s."FlatOuterArea"
    ,s."NonlivingInteriorArea"
    ,s."NonlivingOuterArea"
    ,s."SharedInteriorArea"
    ,s."SharedOuterArea"
    ,d."PreparedDate"
  FROM nivkis_building_tmp_merged s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_building u ON s."BuildingCadastreNr" = u."BuildingCadastreNr"
  WHERE u."BuildingCadastreNr" IS NULL;

  --BuildingElementData.
  CREATE TEMPORARY TABLE nivkis_building_tmp_element AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/BuildingItemData/BuildingBasicData/BuildingCadastreNr/text()', a."BuildingItemData")) [1]::TEXT "BuildingCadastreNr"
      ,t."ConstructionDataList"
    FROM nivkis_building_tmp1 a
      ,LATERAL UNNEST((XPATH('/BuildingItemData/BuildingElementData/ConstructionDataList', "BuildingItemData"))::TEXT[]) t("ConstructionDataList")
    )
    ,b
  AS (
    SELECT "BuildingCadastreNr"
      ,"ConstructionDataList"::XML "ConstructionDataList"
    FROM a
    )
    ,c
  AS (
    SELECT "BuildingCadastreNr"
      ,t."BuildingElementMaterialKind"
      ,(XPATH('/ConstructionDataList/BuildingElementName/text()', "ConstructionDataList")) [1]::TEXT "BuildingElementName"
      --,t2."BuildingElementConstructionKind"
      ,ARRAY(SELECT DISTINCT e FROM UNNEST(STRING_TO_ARRAY((XPATH('/ConstructionDataList/BuildingElementAcceptionYears/text()', "ConstructionDataList")) [1]::TEXT, ', ')::SMALLINT[]) a(e) ORDER BY e) "BuildingElementAcceptionYears"
      ,(XPATH('/ConstructionDataList/BuildingElementExploitYear/text()', "ConstructionDataList")) [1]::TEXT::SMALLINT "BuildingElementExploitYear"
      ,(XPATH('/ConstructionDataList/BuildingElementDeprecation/text()', "ConstructionDataList")) [1]::TEXT::SMALLINT "BuildingElementDeprecation"
    FROM b
    LEFT JOIN LATERAL(SELECT UNNEST((XPATH('/ConstructionDataList/BuildingElementMaterialKindList/BuildingElementMaterialKind', "ConstructionDataList"))::TEXT[]) "BuildingElementMaterialKind") t ON TRUE
      --LEFT JOIN LATERAL (SELECT UNNEST((XPATH('/ConstructionDataList/BuildingElementConstractionKindList/BuildingElementConstructionKind', "ConstructionDataList"))::TEXT[]) "BuildingElementConstructionKind") t2 ON TRUE
    )
    ,d
  AS (
    SELECT "BuildingCadastreNr"
      ,"BuildingElementMaterialKind"::XML "BuildingElementMaterialKind"
      ,"BuildingElementName"
      --,"BuildingElementConstructionKind"::XML "BuildingElementConstructionKind"
      ,"BuildingElementAcceptionYears"
      ,"BuildingElementExploitYear"
      ,"BuildingElementDeprecation"
    FROM c
    )
    ,e
  AS (
    SELECT "BuildingCadastreNr"
      --,(XPATH('/BuildingElementMaterialKind/MaterialKindId/text()', "BuildingElementMaterialKind")) [1]::TEXT::SMALLINT "MaterialKindId"
      ,(XPATH('/BuildingElementMaterialKind/MaterialKindName/text()', "BuildingElementMaterialKind")) [1]::TEXT "MaterialKindName"
      ,"BuildingElementName"
      --,(XPATH('/BuildingElementConstructionKind/ConstructionKindId/text()', "BuildingElementConstructionKind")) [1]::TEXT::SMALLINT "ConstructionKindId"
      --,(XPATH('/BuildingElementConstructionKind/ConstructionKindName/text()', "BuildingElementConstructionKind")) [1]::TEXT "ConstructionKindName"
      ,"BuildingElementAcceptionYears"
      ,"BuildingElementExploitYear"
      ,"BuildingElementDeprecation"
    FROM d
    )
  SELECT "BuildingCadastreNr"
    ,ARRAY_AGG("MaterialKindName" ORDER BY "MaterialKindName") "MaterialKindName"
    ,"BuildingElementName"
    --,ARRAY_AGG("ConstructionKindName" ORDER BY "ConstructionKindName") "ConstructionKindName"
    ,"BuildingElementAcceptionYears"
    ,"BuildingElementExploitYear"
    ,"BuildingElementDeprecation"
  FROM e
  GROUP BY "BuildingCadastreNr"
    ,"BuildingElementName"
    ,"BuildingElementAcceptionYears"
    ,"BuildingElementExploitYear"
    ,"BuildingElementDeprecation";

  --Papildina BuildingElementName klasifikatoru.
  INSERT INTO vzd.nivkis_building_elementname ("BuildingElementName")
  SELECT DISTINCT "BuildingElementName"
  FROM nivkis_building_tmp_element
  WHERE "BuildingElementName" IS NOT NULL
    AND "BuildingElementName" NOT IN (
      SELECT "BuildingElementName"
      FROM vzd.nivkis_building_elementname
      )
  ORDER BY "BuildingElementName";

  --Izmanto ID no klasifikatoriem.
  CREATE TEMPORARY TABLE nivkis_building_tmp_element_2 AS
  SELECT a."BuildingCadastreNr"
    ,a."MaterialKindName"
    ,b.id "BuildingElementName"
    --,a."ConstructionKindName"
    ,a."BuildingElementAcceptionYears"
    ,a."BuildingElementExploitYear"
    ,a."BuildingElementDeprecation"
  FROM nivkis_building_tmp_element a
  INNER JOIN vzd.nivkis_building_elementname b ON a."BuildingElementName" = b."BuildingElementName";

  --nivkis_building_element.
  ---Kadastra objekts un/vai tā atribūti vairāk neeksistē.
  UPDATE vzd.nivkis_building_element uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_building_element u
  CROSS JOIN nivkis_building_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_building_tmp_element_2 s ON u."BuildingCadastreNr" = s."BuildingCadastreNr"
    AND u."BuildingElementName" = s."BuildingElementName"
  WHERE s."BuildingCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_building_element
  SET date_deleted = d."PreparedDate"
  FROM nivkis_building_tmp_element_2 s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  WHERE nivkis_building_element."BuildingCadastreNr" = s."BuildingCadastreNr"
    AND nivkis_building_element."BuildingElementName" = s."BuildingElementName"
    AND nivkis_building_element.date_deleted IS NULL
    AND (
      COALESCE(nivkis_building_element."MaterialKindName", '{}') != COALESCE(s."MaterialKindName", '{}')
      --OR COALESCE(nivkis_building_element."ConstructionKindName", '{}') != COALESCE(s."ConstructionKindName", '{}')
      OR COALESCE(nivkis_building_element."BuildingElementAcceptionYears", '{0}') != COALESCE(s."BuildingElementAcceptionYears", '{0}')
      OR COALESCE(nivkis_building_element."BuildingElementExploitYear", 0) != COALESCE(s."BuildingElementExploitYear", 0)
      OR COALESCE(nivkis_building_element."BuildingElementDeprecation", 0) != COALESCE(s."BuildingElementDeprecation", 0)
      );

  INSERT INTO vzd.nivkis_building_element (
    "BuildingCadastreNr"
    ,"MaterialKindName"
    ,"BuildingElementName"
    --,"ConstructionKindName"
    ,"BuildingElementAcceptionYears"
    ,"BuildingElementExploitYear"
    ,"BuildingElementDeprecation"
    ,date_created
    )
  SELECT s."BuildingCadastreNr"
    ,s."MaterialKindName"
    ,s."BuildingElementName"
    --,s."ConstructionKindName"
    ,s."BuildingElementAcceptionYears"
    ,s."BuildingElementExploitYear"
    ,s."BuildingElementDeprecation"
    ,d."PreparedDate"
  FROM nivkis_building_tmp_element_2 s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  INNER JOIN vzd.nivkis_building_element u ON s."BuildingCadastreNr" = u."BuildingCadastreNr"
    AND s."BuildingElementName" = u."BuildingElementName"
  WHERE (
      COALESCE(u."MaterialKindName", '{}') != COALESCE(s."MaterialKindName", '{}')
      --OR COALESCE(u."ConstructionKindName", '{}') != COALESCE(s."ConstructionKindName", '{}')
      OR COALESCE(u."BuildingElementAcceptionYears", '{0}') != COALESCE(s."BuildingElementAcceptionYears", '{0}')
      OR COALESCE(u."BuildingElementExploitYear", 0) != COALESCE(s."BuildingElementExploitYear", 0)
      OR COALESCE(u."BuildingElementDeprecation", 0) != COALESCE(s."BuildingElementDeprecation", 0)
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_building_element (
    "BuildingCadastreNr"
    ,"MaterialKindName"
    ,"BuildingElementName"
    --,"ConstructionKindName"
    ,"BuildingElementAcceptionYears"
    ,"BuildingElementExploitYear"
    ,"BuildingElementDeprecation"
    ,date_created
    )
  SELECT s."BuildingCadastreNr"
    ,s."MaterialKindName"
    ,s."BuildingElementName"
    --,s."ConstructionKindName"
    ,s."BuildingElementAcceptionYears"
    ,s."BuildingElementExploitYear"
    ,s."BuildingElementDeprecation"
    ,d."PreparedDate"
  FROM nivkis_building_tmp_element_2 s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_building_element u ON s."BuildingCadastreNr" = u."BuildingCadastreNr"
    AND s."BuildingElementName" = u."BuildingElementName"
  WHERE u."BuildingCadastreNr" IS NULL;

  --BuildingAmountList.
  CREATE TEMPORARY TABLE nivkis_building_tmp_amount AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/BuildingItemData/BuildingBasicData/BuildingCadastreNr/text()', a."BuildingItemData")) [1]::TEXT "BuildingCadastreNr"
      ,t."BuildingAmountData"
    FROM nivkis_building_tmp1 a
      ,LATERAL UNNEST((XPATH('/BuildingItemData/BuildingAmountList/BuildingAmountData', "BuildingItemData"))::TEXT[]) t("BuildingAmountData")
    )
    ,b
  AS (
    SELECT "BuildingCadastreNr"
      ,"BuildingAmountData"::XML "BuildingAmountData"
    FROM a
    )
  SELECT "BuildingCadastreNr"
    --,(XPATH('/BuildingAmountData/BuildingAmountKind/AmountKindId/text()', "BuildingAmountData")) [1]::TEXT::SMALLINT "AmountKindId"
    ,(XPATH('/BuildingAmountData/BuildingAmountKind/AmountKindName/text()', "BuildingAmountData")) [1]::TEXT "AmountKindName"
    ,(XPATH('/BuildingAmountData/BuildingAmountTitle/text()', "BuildingAmountData")) [1]::TEXT "BuildingAmountTitle"
    ,(XPATH('/BuildingAmountData/BuildingAmountQuantity/text()', "BuildingAmountData")) [1]::TEXT::DECIMAL(11, 2) "BuildingAmountQuantity"
    --,(XPATH('/BuildingAmountData/BuildingAmountMeasure/MeasureKindId/text()', "BuildingAmountData")) [1]::TEXT::SMALLINT "MeasureKindId"
    ,(XPATH('/BuildingAmountData/BuildingAmountMeasure/MeasureKindName/text()', "BuildingAmountData")) [1]::TEXT "MeasureKindName"
    ,(XPATH('/BuildingAmountData/BuildingAmountBuildingKind/BuildingKindId/text()', "BuildingAmountData")) [1]::TEXT::INT "BuildingKindId"
    --,(XPATH('/BuildingAmountData/BuildingAmountBuildingKind/BuildingKindName/text()', "BuildingAmountData")) [1]::TEXT "BuildingKindName"
  FROM b;

  --nivkis_building_amount.
  ---Kadastra objekts un/vai tā atribūti vairāk neeksistē vai mainīti.
  UPDATE vzd.nivkis_building_amount uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_building_amount u
  CROSS JOIN nivkis_building_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_building_tmp_amount s ON u."BuildingCadastreNr" = s."BuildingCadastreNr"
    AND COALESCE(u."BuildingKindId", 0) = COALESCE(s."BuildingKindId", 0)
    AND COALESCE(u."BuildingAmountTitle", '') = COALESCE(s."BuildingAmountTitle", '')
    AND u."AmountKindName" = s."AmountKindName"
    AND COALESCE(u."BuildingAmountQuantity", 0) = COALESCE(s."BuildingAmountQuantity", 0)
    AND COALESCE(u."MeasureKindName", '') = COALESCE(s."MeasureKindName", '')
  WHERE s."BuildingCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Jauns kadastra objekts vai mainīti atribūti.
  INSERT INTO vzd.nivkis_building_amount (
    "BuildingCadastreNr"
    ,"AmountKindName"
    ,"BuildingAmountTitle"
    ,"BuildingAmountQuantity"
    ,"MeasureKindName"
    ,"BuildingKindId"
    ,date_created
    )
  SELECT s."BuildingCadastreNr"
    ,s."AmountKindName"
    ,s."BuildingAmountTitle"
    ,s."BuildingAmountQuantity"
    ,s."MeasureKindName"
    ,s."BuildingKindId"
    ,d."PreparedDate"
  FROM nivkis_building_tmp_amount s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_building_amount u ON s."BuildingCadastreNr" = u."BuildingCadastreNr"
    AND COALESCE(s."BuildingKindId", 0) = COALESCE(u."BuildingKindId", 0)
    AND COALESCE(s."BuildingAmountTitle", '') = COALESCE(u."BuildingAmountTitle", '')
    AND s."AmountKindName" = u."AmountKindName"
    AND COALESCE(s."BuildingAmountQuantity", 0) = COALESCE(u."BuildingAmountQuantity", 0)
    AND COALESCE(s."MeasureKindName", '') = COALESCE(u."MeasureKindName", '')
  WHERE u."BuildingCadastreNr" IS NULL;

  --ImprovementItemData.
  CREATE TEMPORARY TABLE nivkis_building_tmp_improvement AS
  WITH a
  AS (
    SELECT DISTINCT (XPATH('/BuildingItemData/BuildingBasicData/BuildingCadastreNr/text()', a."BuildingItemData")) [1]::TEXT "BuildingCadastreNr"
      ,(XPATH('/BuildingItemData/ImprovementItemData/ImprovementCommonData/ImprovementDate/text()', a."BuildingItemData")) [1]::TEXT::DATE "ImprovementDate"
      ,t."ImprovementData"
    FROM nivkis_building_tmp1 a
      ,LATERAL UNNEST((XPATH('/BuildingItemData/ImprovementItemData/ImprovementList/ImprovementData', "BuildingItemData"))::TEXT[]) t("ImprovementData")
    )
    ,b
  AS (
    SELECT "BuildingCadastreNr"
      ,"ImprovementDate"
      ,"ImprovementData"::XML "ImprovementData"
    FROM a
    )
  SELECT "BuildingCadastreNr"
    ,"ImprovementDate"
    ,(XPATH('/ImprovementData/ImprovementTypeName/text()', "ImprovementData")) [1]::TEXT "ImprovementTypeName"
    ,(XPATH('/ImprovementData/ImprovementDetectionForm/text()', "ImprovementData")) [1]::TEXT "ImprovementDetectionForm"
    ,(XPATH('/ImprovementData/ImprovementQuantity/text()', "ImprovementData")) [1]::TEXT "ImprovementQuantity"
  FROM b;

  --nivkis_building_improvement.
  ---Kadastra objekts un/vai tā atribūti vairāk neeksistē.
  UPDATE vzd.nivkis_building_improvement uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_building_improvement u
  CROSS JOIN nivkis_building_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_building_tmp_improvement s ON u."BuildingCadastreNr" = s."BuildingCadastreNr"
    AND COALESCE(u."ImprovementDate", '1900-01-01') = COALESCE(s."ImprovementDate", '1900-01-01')
    AND u."ImprovementTypeName" = s."ImprovementTypeName"
  WHERE s."BuildingCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_building_improvement
  SET date_deleted = d."PreparedDate"
  FROM nivkis_building_tmp_improvement s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  WHERE nivkis_building_improvement."BuildingCadastreNr" = s."BuildingCadastreNr"
    AND COALESCE(nivkis_building_improvement."ImprovementDate", '1900-01-01') = COALESCE(s."ImprovementDate", '1900-01-01')
    AND nivkis_building_improvement."ImprovementTypeName" = s."ImprovementTypeName"
    AND nivkis_building_improvement.date_deleted IS NULL
    AND (
      COALESCE(nivkis_building_improvement."ImprovementDetectionForm", '') != COALESCE(s."ImprovementDetectionForm", '')
      OR COALESCE(nivkis_building_improvement."ImprovementQuantity", '') != COALESCE(s."ImprovementQuantity", '')
      );

  INSERT INTO vzd.nivkis_building_improvement (
    "BuildingCadastreNr"
    ,"ImprovementDate"
    ,"ImprovementTypeName"
    ,"ImprovementDetectionForm"
    ,"ImprovementQuantity"
    ,date_created
    )
  SELECT s."BuildingCadastreNr"
    ,s."ImprovementDate"
    ,s."ImprovementTypeName"
    ,s."ImprovementDetectionForm"
    ,s."ImprovementQuantity"
    ,d."PreparedDate"
  FROM nivkis_building_tmp_improvement s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  INNER JOIN vzd.nivkis_building_improvement u ON s."BuildingCadastreNr" = u."BuildingCadastreNr"
    AND COALESCE(s."ImprovementDate", '1900-01-01') = COALESCE(u."ImprovementDate", '1900-01-01')
    AND s."ImprovementTypeName" = u."ImprovementTypeName"
  WHERE (
      COALESCE(u."ImprovementDetectionForm", '') != COALESCE(s."ImprovementDetectionForm", '')
      OR COALESCE(u."ImprovementQuantity", '') != COALESCE(s."ImprovementQuantity", '')
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_building_improvement (
    "BuildingCadastreNr"
    ,"ImprovementDate"
    ,"ImprovementTypeName"
    ,"ImprovementDetectionForm"
    ,"ImprovementQuantity"
    ,date_created
    )
  SELECT s."BuildingCadastreNr"
    ,s."ImprovementDate"
    ,s."ImprovementTypeName"
    ,s."ImprovementDetectionForm"
    ,s."ImprovementQuantity"
    ,d."PreparedDate"
  FROM nivkis_building_tmp_improvement s
  CROSS JOIN nivkis_building_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_building_improvement u ON s."BuildingCadastreNr" = u."BuildingCadastreNr"
    AND COALESCE(s."ImprovementDate", '1900-01-01') = COALESCE(u."ImprovementDate", '1900-01-01')
    AND s."ImprovementTypeName" = u."ImprovementTypeName"
  WHERE u."BuildingCadastreNr" IS NULL;

  RAISE NOTICE 'Dati nivkis_building atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_building nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_building_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_building_proc() TO scheduler;