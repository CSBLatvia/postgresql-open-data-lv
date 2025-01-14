CREATE OR REPLACE PROCEDURE vzd.nivkis_valuation_proc(
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
  FROM vzd.nivkis_valuation_property

  UNION

  SELECT date_deleted "date"
  FROM vzd.nivkis_valuation_property
  WHERE date_deleted IS NOT NULL

  UNION

  SELECT date_created "date"
  FROM vzd.nivkis_valuation_object

  UNION

  SELECT date_deleted "date"
  FROM vzd.nivkis_valuation_object
  WHERE date_deleted IS NOT NULL
  )
SELECT COALESCE(MAX("date"), '1900-01-01')
FROM a);

--PreparedDate.
CREATE TEMPORARY TABLE nivkis_valuation_tmp_prepareddate AS
WITH a
AS (
  SELECT UNNEST((XPATH('ValuationFullData/PreparedDate/text()', data)))::TEXT::DATE "PreparedDate"
  FROM vzd.nivkis_valuation_tmp
  )
SELECT MAX("PreparedDate") "PreparedDate"
FROM a;

date_files :=
(SELECT "PreparedDate"
FROM nivkis_valuation_tmp_prepareddate);

IF date_files > date_db THEN

  RAISE NOTICE 'Uzsāk nivkis_valuation atjaunošanu ar % datiem.', date_files;

  --ValuationItemData.
  CREATE TEMPORARY TABLE nivkis_valuation_tmp1 AS
  SELECT UNNEST(XPATH('ValuationFullData/ValuationItemList/ValuationItemData', data)) "ValuationItemData"
  FROM vzd.nivkis_valuation_tmp;

  DROP TABLE IF EXISTS vzd.nivkis_valuation_tmp;

  --ObjectRelation, ValuationRowData.
  CREATE TEMPORARY TABLE nivkis_valuation_tmp2 AS
  WITH a
  AS (
  SELECT DISTINCT (XPATH('/ValuationItemData/ObjectRelation/ObjectCadastreNr/text()', "ValuationItemData")) [1]::TEXT "ObjectCadastreNr"
    ,(XPATH('/ValuationItemData/ObjectRelation/ObjectType/text()', "ValuationItemData")) [1]::TEXT "ObjectType"
    ,(XPATH('/ValuationItemData/ObjectForestValue/text()', "ValuationItemData")) [1]::TEXT::INT "ObjectForestValue"
    ,(XPATH('/ValuationItemData/ObjectForestValueDate/text()', "ValuationItemData")) [1]::TEXT::DATE "ObjectForestValueDate"
    ,t."ValuationRowData"
  FROM nivkis_valuation_tmp1 a
      ,LATERAL UNNEST((XPATH('/ValuationItemData/ValuationDataList/ValuationRowData', "ValuationItemData"))::TEXT[]) t("ValuationRowData")
    )
    ,b
  AS (
    SELECT "ObjectCadastreNr"
      ,"ObjectType"
      ,"ObjectForestValue"
      ,"ObjectForestValueDate"
      ,"ValuationRowData"::XML "ValuationRowData"
    FROM a
    )
  SELECT DISTINCT "ObjectCadastreNr"
    ,"ObjectType"
    ,(XPATH('/ValuationRowData/ValueType/text()', "ValuationRowData")) [1]::TEXT "ValueType"
    ,(XPATH('/ValuationRowData/ValDescription/text()', "ValuationRowData")) [1]::TEXT "ValDescription"
    ,(XPATH('/ValuationRowData/PropertyValuation/text()', "ValuationRowData")) [1]::TEXT::INT "PropertyValuation"
    ,(XPATH('/ValuationRowData/PropertyValuationDate/text()', "ValuationRowData")) [1]::TEXT::DATE "PropertyValuationDate"
    ,(XPATH('/ValuationRowData/PropertyCadastralValue/text()', "ValuationRowData")) [1]::TEXT::INT "PropertyCadastralValue"
    ,(XPATH('/ValuationRowData/PropertyCadastralValueDate/text()', "ValuationRowData")) [1]::TEXT::DATE "PropertyCadastralValueDate"
    ,(XPATH('/ValuationRowData/ObjectCadastralValue/text()', "ValuationRowData")) [1]::TEXT::INT "ObjectCadastralValue"
    ,(XPATH('/ValuationRowData/ObjectCadastralValueDate/text()', "ValuationRowData")) [1]::TEXT::DATE "ObjectCadastralValueDate"
    ,"ObjectForestValue"
    ,"ObjectForestValueDate"
  FROM b;

  --Papildina ValueType klasifikatoru.
  INSERT INTO vzd.nivkis_valuation_type ("ValueType", "ValDescription")
  SELECT DISTINCT a."ValueType"
    ,a."ValDescription"
  FROM nivkis_valuation_tmp2 a
  LEFT OUTER JOIN vzd.nivkis_valuation_type b ON a."ValueType" = b."ValueType"
    AND a."ValDescription" = b."ValDescription"
  WHERE b."ValueType" IS NULL
  ORDER BY "ValueType"
    ,"ValDescription";

  --Izmanto ID no klasifikatoriem.
  CREATE TEMPORARY TABLE nivkis_valuation_tmp3 AS
  SELECT a."ObjectCadastreNr"
    ,a."ObjectType"
    ,b.id "ValueType"
    ,a."PropertyValuation"
    ,a."PropertyValuationDate"
    ,a."PropertyCadastralValue"
    ,a."PropertyCadastralValueDate"
    ,a."ObjectCadastralValue"
    ,a."ObjectCadastralValueDate"
    ,a."ObjectForestValue"
    ,a."ObjectForestValueDate"
  FROM nivkis_valuation_tmp2 a
  INNER JOIN vzd.nivkis_valuation_type b ON a."ValueType" = b."ValueType"
    AND a."ValDescription" = b."ValDescription";

  --nivkis_valuation_property.
  ---Īpašums un/vai tā atribūti vairāk neeksistē.
  UPDATE vzd.nivkis_valuation_property uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_valuation_property u
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_valuation_tmp3 s ON u."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" = 'PROPERTY'
    AND COALESCE(u."ValueType", 0) = COALESCE(s."ValueType", 0)
  WHERE s."ObjectCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_valuation_property
  SET date_deleted = d."PreparedDate"
  FROM nivkis_valuation_tmp3 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  WHERE nivkis_valuation_property."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" = 'PROPERTY'
    AND COALESCE(nivkis_valuation_property."ValueType", 0) = COALESCE(s."ValueType", 0)
    AND nivkis_valuation_property.date_deleted IS NULL
    AND (
      COALESCE(nivkis_valuation_property."Valuation", 0) != COALESCE(s."PropertyValuation", 0)
      OR COALESCE(nivkis_valuation_property."ValuationDate", '1900-01-01') != COALESCE(s."PropertyValuationDate", '1900-01-01')
      OR COALESCE(nivkis_valuation_property."CadastralValue", 0) != COALESCE(s."PropertyCadastralValue", 0)
      OR COALESCE(nivkis_valuation_property."CadastralValueDate", '1900-01-01') != COALESCE(s."PropertyCadastralValueDate", '1900-01-01')
      );

  INSERT INTO vzd.nivkis_valuation_property (
    "ObjectCadastreNr"
    ,"ValueType"
    ,"Valuation"
    ,"ValuationDate"
    ,"CadastralValue"
    ,"CadastralValueDate"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ValueType"
    ,s."PropertyValuation"
    ,s."PropertyValuationDate"
    ,s."PropertyCadastralValue"
    ,s."PropertyCadastralValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp3 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  INNER JOIN vzd.nivkis_valuation_property u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE (
      COALESCE(u."Valuation", 0) != COALESCE(s."PropertyValuation", 0)
      OR COALESCE(u."ValuationDate", '1900-01-01') != COALESCE(s."PropertyValuationDate", '1900-01-01')
      OR COALESCE(u."CadastralValue", 0) != COALESCE(s."PropertyCadastralValue", 0)
      OR COALESCE(u."CadastralValueDate", '1900-01-01') != COALESCE(s."PropertyCadastralValueDate", '1900-01-01')
      )
    AND u.date_deleted = d."PreparedDate"
    AND s."ObjectType" = 'PROPERTY'
    AND COALESCE(u."ValueType", 0) = COALESCE(s."ValueType", 0);

  ---Jauns īpašums.
  INSERT INTO vzd.nivkis_valuation_property (
    "ObjectCadastreNr"
    ,"ValueType"
    ,"Valuation"
    ,"ValuationDate"
    ,"CadastralValue"
    ,"CadastralValueDate"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ValueType"
    ,s."PropertyValuation"
    ,s."PropertyValuationDate"
    ,s."PropertyCadastralValue"
    ,s."PropertyCadastralValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp3 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_valuation_property u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
    AND COALESCE(s."ValueType", 0) = COALESCE(u."ValueType", 0)
  WHERE u."ObjectCadastreNr" IS NULL
    AND s."ObjectType" = 'PROPERTY';

  --nivkis_valuation_object.
  ---Kadastra objekts un/vai tā atribūti vairāk neeksistē.
  UPDATE vzd.nivkis_valuation_object uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_valuation_object u
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_valuation_tmp3 s ON u."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" != 'PROPERTY'
    AND COALESCE(u."ValueType", 0) = COALESCE(s."ValueType", 0)
  WHERE s."ObjectCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_valuation_object
  SET date_deleted = d."PreparedDate"
  FROM nivkis_valuation_tmp3 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  WHERE nivkis_valuation_object."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" != 'PROPERTY'
    AND COALESCE(nivkis_valuation_object."ValueType", 0) = COALESCE(s."ValueType", 0)
    AND nivkis_valuation_object.date_deleted IS NULL
    AND (
      COALESCE(nivkis_valuation_object."CadastralValue", 0) != COALESCE(s."ObjectCadastralValue", 0)
      OR COALESCE(nivkis_valuation_object."CadastralValueDate", '1900-01-01') != COALESCE(s."ObjectCadastralValueDate", '1900-01-01')
      );

  INSERT INTO vzd.nivkis_valuation_object (
    "ObjectCadastreNr"
    ,"ValueType"
    ,"CadastralValue"
    ,"CadastralValueDate"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ValueType"
    ,s."ObjectCadastralValue"
    ,s."ObjectCadastralValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp3 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  INNER JOIN vzd.nivkis_valuation_object u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE (
      COALESCE(u."CadastralValue", 0) != COALESCE(s."ObjectCadastralValue", 0)
      OR COALESCE(u."CadastralValueDate", '1900-01-01') != COALESCE(s."ObjectCadastralValueDate", '1900-01-01')
      )
    AND u.date_deleted = d."PreparedDate"
    AND s."ObjectType" != 'PROPERTY'
    AND COALESCE(u."ValueType", 0) = COALESCE(s."ValueType", 0);

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_valuation_object (
    "ObjectCadastreNr"
    ,"ValueType"
    ,"CadastralValue"
    ,"CadastralValueDate"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ValueType"
    ,s."ObjectCadastralValue"
    ,s."ObjectCadastralValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp3 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_valuation_object u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
    AND COALESCE(s."ValueType", 0) = COALESCE(u."ValueType", 0)
  WHERE u."ObjectCadastreNr" IS NULL
    AND s."ObjectType" != 'PROPERTY';

  --nivkis_valuation_forest.
  ---Kadastra objekts vairāk neeksistē.
  UPDATE vzd.nivkis_valuation_forest uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_valuation_forest u
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_valuation_tmp2 s ON u."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" != 'PROPERTY'
  WHERE s."ObjectCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_valuation_forest
  SET date_deleted = d."PreparedDate"
  FROM nivkis_valuation_tmp2 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  WHERE nivkis_valuation_forest."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" != 'PROPERTY'
    AND nivkis_valuation_forest.date_deleted IS NULL
    AND (
      COALESCE(nivkis_valuation_forest."ForestValue", 0) != COALESCE(s."ObjectForestValue", 0)
      OR COALESCE(nivkis_valuation_forest."ForestValueDate", '1900-01-01') != COALESCE(s."ObjectForestValueDate", '1900-01-01')
      );

  INSERT INTO vzd.nivkis_valuation_forest (
    "ObjectCadastreNr"
    ,"ForestValue"
    ,"ForestValueDate"
    ,date_created
    )
  SELECT DISTINCT s."ObjectCadastreNr"
    ,s."ObjectForestValue"
    ,s."ObjectForestValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp2 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  INNER JOIN vzd.nivkis_valuation_forest u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE (
      COALESCE(u."ForestValue", 0) != COALESCE(s."ObjectForestValue", 0)
      OR COALESCE(u."ForestValueDate", '1900-01-01') != COALESCE(s."ObjectForestValueDate", '1900-01-01')
      )
    AND u.date_deleted = d."PreparedDate"
    AND s."ObjectType" != 'PROPERTY';

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_valuation_forest (
    "ObjectCadastreNr"
    ,"ForestValue"
    ,"ForestValueDate"
    ,date_created
    )
  SELECT DISTINCT s."ObjectCadastreNr"
    ,s."ObjectForestValue"
    ,s."ObjectForestValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp2 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_valuation_forest u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE u."ObjectCadastreNr" IS NULL
    AND s."ObjectType" != 'PROPERTY'
    AND s."ObjectForestValue" IS NOT NULL;

  RAISE NOTICE 'Dati nivkis_valuation atjaunoti.';

ELSE

  RAISE NOTICE 'Dati nivkis_valuation nav jāatjauno.';

  DROP TABLE IF EXISTS vzd.nivkis_valuation_tmp;

END IF;

END
$$ LANGUAGE plpgsql;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_valuation_proc() TO scheduler;