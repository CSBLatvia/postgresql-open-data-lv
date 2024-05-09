CREATE OR REPLACE PROCEDURE vzd.nivkis_premisegroup_proc(
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
  FROM vzd.nivkis_premisegroup
  
  UNION
  
  SELECT date_deleted "date"
  FROM vzd.nivkis_premisegroup
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

--PreparedDate.
CREATE TEMPORARY TABLE nivkis_premisegroup_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((XPATH('PremiseGroupFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_premisegroup_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_premisegroup_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_premisegroup atjaunošanu ar % datiem.', date_files;

  --PremiseGroupItemData.
  CREATE TEMPORARY TABLE nivkis_premisegroup_tmp1 AS
  SELECT UNNEST(XPATH('PremiseGroupFullData/PremiseGroupItemList/PremiseGroupItemData', data)) "PremiseGroupItemData"
  FROM vzd.nivkis_premisegroup_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_premisegroup_tmp;

  --ObjectRelation, PremiseGroupBasicData.
  CREATE TEMPORARY TABLE nivkis_premisegroup_tmp2 AS
  SELECT DISTINCT (XPATH('/PremiseGroupItemData/PremiseGroupBasicData/PremiseGroupCadastreNr/text()', "PremiseGroupItemData")) [1]::TEXT "PremiseGroupCadastreNr"
    ,(XPATH('/PremiseGroupItemData/ObjectRelation/ObjectCadastreNr/text()', "PremiseGroupItemData")) [1]::TEXT "BuildingCadastreNr"
    ,(XPATH('/PremiseGroupItemData/PremiseGroupBasicData/PremiseGroupName/text()', "PremiseGroupItemData")) [1]::TEXT "PremiseGroupName"
    ,(XPATH('/PremiseGroupItemData/PremiseGroupBasicData/PremiseGroupUseKind/PremiseGroupUseKindId/text()', "PremiseGroupItemData")) [1]::TEXT::SMALLINT "PremiseGroupUseKindId"
    ,(XPATH('/PremiseGroupItemData/PremiseGroupBasicData/PremiseGroupUseKind/PremiseGroupUseKindName/text()', "PremiseGroupItemData")) [1]::TEXT "PremiseGroupUseKindName"
    ,(XPATH('/PremiseGroupItemData/PremiseGroupBasicData/PremiseGroupBuildingFloor/text()', "PremiseGroupItemData")) [1]::TEXT::SMALLINT "PremiseGroupBuildingFloor"
    ,(XPATH('/PremiseGroupItemData/PremiseGroupBasicData/PremiseGroupPremiseCount/text()', "PremiseGroupItemData")) [1]::TEXT::SMALLINT "PremiseGroupPremiseCount"
    ,(XPATH('/PremiseGroupItemData/PremiseGroupBasicData/PremiseGroupArea/text()', "PremiseGroupItemData")) [1]::TEXT::DECIMAL(7, 1) "PremiseGroupArea"
    ,(XPATH('/PremiseGroupItemData/PremiseGroupBasicData/PremiseGroupSurveyDate/text()', "PremiseGroupItemData")) [1]::TEXT::DATE "PremiseGroupSurveyDate"
    ,(XPATH('/PremiseGroupItemData/PremiseGroupBasicData/PremiseGroupAcceptionYears/text()', "PremiseGroupItemData")) [1]::TEXT "PremiseGroupAcceptionYears"
    ,(XPATH('/PremiseGroupItemData/PremiseGroupBasicData/NotForLandBook/text()', "PremiseGroupItemData")) [1]::TEXT "NotForLandBook"
  FROM nivkis_premisegroup_tmp1;

  --Papildina PremiseGroupUseKind klasifikatoru.
  INSERT INTO vzd.nivkis_premisegroup_usekind
  SELECT DISTINCT "PremiseGroupUseKindId"
    ,"PremiseGroupUseKindName"
  FROM nivkis_premisegroup_tmp2
  WHERE "PremiseGroupUseKindId" IS NOT NULL
    AND "PremiseGroupUseKindId" NOT IN (
      SELECT "PremiseGroupUseKindId"
      FROM vzd.nivkis_premisegroup_usekind
      )
  ORDER BY "PremiseGroupUseKindId";

  CREATE TEMPORARY TABLE nivkis_premisegroup_tmp3 AS
  SELECT "PremiseGroupCadastreNr"
    ,"BuildingCadastreNr"
    ,"PremiseGroupName"
    ,"PremiseGroupUseKindId"
    ,"PremiseGroupBuildingFloor"
    ,"PremiseGroupPremiseCount"
    ,"PremiseGroupArea"
    ,"PremiseGroupSurveyDate"
    ,ARRAY(SELECT DISTINCT e FROM UNNEST(STRING_TO_ARRAY("PremiseGroupAcceptionYears", ', ')::SMALLINT []) a(e) ORDER BY e) "PremiseGroupAcceptionYears"
    ,CASE 
      WHEN "NotForLandBook" IS NOT NULL
        THEN 1::BOOLEAN
      ELSE NULL
      END "NotForLandBook"
  FROM nivkis_premisegroup_tmp2;

  --nivkis_premisegroup.
  ---Kadastra objekts vairāk neeksistē.
  UPDATE vzd.nivkis_premisegroup uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_premisegroup u
  CROSS JOIN nivkis_premisegroup_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_premisegroup_tmp3 s ON u."PremiseGroupCadastreNr" = s."PremiseGroupCadastreNr"
  WHERE s."PremiseGroupCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_premisegroup
  SET date_deleted = d."PreparedDate"
  FROM nivkis_premisegroup_tmp3 s
  CROSS JOIN nivkis_premisegroup_tmp_prepareddate d
  WHERE nivkis_premisegroup."PremiseGroupCadastreNr" = s."PremiseGroupCadastreNr"
    AND nivkis_premisegroup.date_deleted IS NULL
    AND (
      COALESCE(nivkis_premisegroup."BuildingCadastreNr", '') != COALESCE(s."BuildingCadastreNr", '')
      OR COALESCE(nivkis_premisegroup."PremiseGroupName", '') != COALESCE(s."PremiseGroupName", '')
      OR COALESCE(nivkis_premisegroup."PremiseGroupUseKindId", 0) != COALESCE(s."PremiseGroupUseKindId", 0)
      OR COALESCE(nivkis_premisegroup."PremiseGroupBuildingFloor", 0) != COALESCE(s."PremiseGroupBuildingFloor", 0)
      OR COALESCE(nivkis_premisegroup."PremiseGroupPremiseCount", 0) != COALESCE(s."PremiseGroupPremiseCount", 0)
      OR COALESCE(nivkis_premisegroup."PremiseGroupArea", 0) != COALESCE(s."PremiseGroupArea", 0)
      OR COALESCE(nivkis_premisegroup."PremiseGroupSurveyDate", '1900-01-01') != COALESCE(s."PremiseGroupSurveyDate", '1900-01-01')
      OR COALESCE(nivkis_premisegroup."PremiseGroupAcceptionYears", '{0}') != COALESCE(s."PremiseGroupAcceptionYears", '{0}')
      OR COALESCE(nivkis_premisegroup."NotForLandBook", FALSE) != COALESCE(s."NotForLandBook", FALSE)
      );

  INSERT INTO vzd.nivkis_premisegroup (
    "PremiseGroupCadastreNr"
    ,"BuildingCadastreNr"
    ,"PremiseGroupName"
    ,"PremiseGroupUseKindId"
    ,"PremiseGroupBuildingFloor"
    ,"PremiseGroupPremiseCount"
    ,"PremiseGroupArea"
    ,"PremiseGroupSurveyDate"
    ,"PremiseGroupAcceptionYears"
    ,"NotForLandBook"
    ,date_created
    )
  SELECT s."PremiseGroupCadastreNr"
    ,s."BuildingCadastreNr"
    ,s."PremiseGroupName"
    ,s."PremiseGroupUseKindId"
    ,s."PremiseGroupBuildingFloor"
    ,s."PremiseGroupPremiseCount"
    ,s."PremiseGroupArea"
    ,s."PremiseGroupSurveyDate"
    ,s."PremiseGroupAcceptionYears"
    ,s."NotForLandBook"
    ,d."PreparedDate"
  FROM nivkis_premisegroup_tmp3 s
  CROSS JOIN nivkis_premisegroup_tmp_prepareddate d
  INNER JOIN vzd.nivkis_premisegroup u ON s."PremiseGroupCadastreNr" = u."PremiseGroupCadastreNr"
  WHERE (
      COALESCE(u."BuildingCadastreNr", '') != COALESCE(s."BuildingCadastreNr", '')
      OR COALESCE(u."PremiseGroupName", '') != COALESCE(s."PremiseGroupName", '')
      OR COALESCE(u."PremiseGroupUseKindId", 0) != COALESCE(s."PremiseGroupUseKindId", 0)
      OR COALESCE(u."PremiseGroupBuildingFloor", 0) != COALESCE(s."PremiseGroupBuildingFloor", 0)
      OR COALESCE(u."PremiseGroupPremiseCount", 0) != COALESCE(s."PremiseGroupPremiseCount", 0)
      OR COALESCE(u."PremiseGroupArea", 0) != COALESCE(s."PremiseGroupArea", 0)
      OR COALESCE(u."PremiseGroupSurveyDate", '1900-01-01') != COALESCE(s."PremiseGroupSurveyDate", '1900-01-01')
      OR COALESCE(u."PremiseGroupAcceptionYears", '{0}') != COALESCE(s."PremiseGroupAcceptionYears", '{0}')
      OR COALESCE(u."NotForLandBook", FALSE) != COALESCE(s."NotForLandBook", FALSE)
      )
    AND u.date_deleted = d."PreparedDate";

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_premisegroup (
    "PremiseGroupCadastreNr"
    ,"BuildingCadastreNr"
    ,"PremiseGroupName"
    ,"PremiseGroupUseKindId"
    ,"PremiseGroupBuildingFloor"
    ,"PremiseGroupPremiseCount"
    ,"PremiseGroupArea"
    ,"PremiseGroupSurveyDate"
    ,"PremiseGroupAcceptionYears"
    ,"NotForLandBook"
    ,date_created
    )
  SELECT s."PremiseGroupCadastreNr"
    ,s."BuildingCadastreNr"
    ,s."PremiseGroupName"
    ,s."PremiseGroupUseKindId"
    ,s."PremiseGroupBuildingFloor"
    ,s."PremiseGroupPremiseCount"
    ,s."PremiseGroupArea"
    ,s."PremiseGroupSurveyDate"
    ,s."PremiseGroupAcceptionYears"
    ,s."NotForLandBook"
    ,d."PreparedDate"
  FROM nivkis_premisegroup_tmp3 s
  CROSS JOIN nivkis_premisegroup_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_premisegroup u ON s."PremiseGroupCadastreNr" = u."PremiseGroupCadastreNr"
  WHERE u."PremiseGroupCadastreNr" IS NULL;

  RAISE NOTICE 'Dati nivkis_premisegroup atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_premisegroup nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_premisegroup_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_premisegroup_proc() TO scheduler;