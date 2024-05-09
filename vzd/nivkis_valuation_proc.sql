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

  --ObjectRelation, ValuationRecData.
  CREATE TEMPORARY TABLE nivkis_valuation_tmp2 AS
  SELECT DISTINCT (XPATH('/ValuationItemData/ObjectRelation/ObjectCadastreNr/text()', "ValuationItemData")) [1]::TEXT "ObjectCadastreNr"
    ,(XPATH('/ValuationItemData/ObjectRelation/ObjectType/text()', "ValuationItemData")) [1]::TEXT "ObjectType"
    ,(XPATH('/ValuationItemData/PropertyValuation/text()', "ValuationItemData")) [1]::TEXT::INT "PropertyValuation"
    ,(XPATH('/ValuationItemData/PropertyValuationDate/text()', "ValuationItemData")) [1]::TEXT::DATE "PropertyValuationDate"
    ,(XPATH('/ValuationItemData/PropertyCadastralValue/text()', "ValuationItemData")) [1]::TEXT::INT "PropertyCadastralValue"
    ,(XPATH('/ValuationItemData/PropertyCadastralValueDate/text()', "ValuationItemData")) [1]::TEXT::DATE "PropertyCadastralValueDate"
    ,(XPATH('/ValuationItemData/ObjectCadastralValue/text()', "ValuationItemData")) [1]::TEXT::INT "ObjectCadastralValue"
    ,(XPATH('/ValuationItemData/ObjectCadastralValueDate/text()', "ValuationItemData")) [1]::TEXT::DATE "ObjectCadastralValueDate"
    ,(XPATH('/ValuationItemData/ObjectForestValue/text()', "ValuationItemData")) [1]::TEXT::INT "ObjectForestValue"
    ,(XPATH('/ValuationItemData/ObjectForestValueDate/text()', "ValuationItemData")) [1]::TEXT::DATE "ObjectForestValueDate"
  FROM nivkis_valuation_tmp1;

  --nivkis_valuation_property.
  ---Īpašums vairāk neeksistē.
  UPDATE vzd.nivkis_valuation_property uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_valuation_property u
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_valuation_tmp2 s ON u."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" = 'PROPERTY'
  WHERE s."ObjectCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_valuation_property
  SET date_deleted = d."PreparedDate"
  FROM nivkis_valuation_tmp2 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  WHERE nivkis_valuation_property."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" = 'PROPERTY'
    AND nivkis_valuation_property.date_deleted IS NULL
    AND (
      COALESCE(nivkis_valuation_property."Valuation", 0) != COALESCE(s."PropertyValuation", 0)
      OR COALESCE(nivkis_valuation_property."ValuationDate", '1900-01-01') != COALESCE(s."PropertyValuationDate", '1900-01-01')
      OR COALESCE(nivkis_valuation_property."CadastralValue", 0) != COALESCE(s."PropertyCadastralValue", 0)
      OR COALESCE(nivkis_valuation_property."CadastralValueDate", '1900-01-01') != COALESCE(s."PropertyCadastralValueDate", '1900-01-01')
      );

  INSERT INTO vzd.nivkis_valuation_property (
    "ObjectCadastreNr"
    ,"Valuation"
    ,"ValuationDate"
    ,"CadastralValue"
    ,"CadastralValueDate"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."PropertyValuation"
    ,s."PropertyValuationDate"
    ,s."PropertyCadastralValue"
    ,s."PropertyCadastralValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp2 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  INNER JOIN vzd.nivkis_valuation_property u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE (
      COALESCE(u."Valuation", 0) != COALESCE(s."PropertyValuation", 0)
      OR COALESCE(u."ValuationDate", '1900-01-01') != COALESCE(s."PropertyValuationDate", '1900-01-01')
      OR COALESCE(u."CadastralValue", 0) != COALESCE(s."PropertyCadastralValue", 0)
      OR COALESCE(u."CadastralValueDate", '1900-01-01') != COALESCE(s."PropertyCadastralValueDate", '1900-01-01')
      )
    AND u.date_deleted = d."PreparedDate"
    AND s."ObjectType" = 'PROPERTY';

  ---Jauns īpašums.
  INSERT INTO vzd.nivkis_valuation_property (
    "ObjectCadastreNr"
    ,"Valuation"
    ,"ValuationDate"
    ,"CadastralValue"
    ,"CadastralValueDate"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."PropertyValuation"
    ,s."PropertyValuationDate"
    ,s."PropertyCadastralValue"
    ,s."PropertyCadastralValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp2 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_valuation_property u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE u."ObjectCadastreNr" IS NULL
    AND s."ObjectType" = 'PROPERTY';

  --nivkis_valuation_object.
  ---Kadastra objekts vairāk neeksistē.
  UPDATE vzd.nivkis_valuation_object uorig
  SET date_deleted = d."PreparedDate"
  FROM vzd.nivkis_valuation_object u
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN nivkis_valuation_tmp2 s ON u."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" != 'PROPERTY'
  WHERE s."ObjectCadastreNr" IS NULL
    AND u.date_deleted IS NULL
    AND uorig.id = u.id;

  ---Mainīti atribūti.
  UPDATE vzd.nivkis_valuation_object
  SET date_deleted = d."PreparedDate"
  FROM nivkis_valuation_tmp2 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  WHERE nivkis_valuation_object."ObjectCadastreNr" = s."ObjectCadastreNr"
    AND s."ObjectType" != 'PROPERTY'
    AND nivkis_valuation_object.date_deleted IS NULL
    AND (
      COALESCE(nivkis_valuation_object."CadastralValue", 0) != COALESCE(s."ObjectCadastralValue", 0)
      OR COALESCE(nivkis_valuation_object."CadastralValueDate", '1900-01-01') != COALESCE(s."ObjectCadastralValueDate", '1900-01-01')
      OR COALESCE(nivkis_valuation_object."ForestValue", 0) != COALESCE(s."ObjectForestValue", 0)
      OR COALESCE(nivkis_valuation_object."ForestValueDate", '1900-01-01') != COALESCE(s."ObjectForestValueDate", '1900-01-01')
      );

  INSERT INTO vzd.nivkis_valuation_object (
    "ObjectCadastreNr"
    ,"CadastralValue"
    ,"CadastralValueDate"
    ,"ForestValue"
    ,"ForestValueDate"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ObjectCadastralValue"
    ,s."ObjectCadastralValueDate"
    ,s."ObjectForestValue"
    ,s."ObjectForestValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp2 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  INNER JOIN vzd.nivkis_valuation_object u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE (
      COALESCE(u."CadastralValue", 0) != COALESCE(s."ObjectCadastralValue", 0)
      OR COALESCE(u."CadastralValueDate", '1900-01-01') != COALESCE(s."ObjectCadastralValueDate", '1900-01-01')
      OR COALESCE(u."ForestValue", 0) != COALESCE(s."ObjectForestValue", 0)
      OR COALESCE(u."ForestValueDate", '1900-01-01') != COALESCE(s."ObjectForestValueDate", '1900-01-01')
      )
    AND u.date_deleted = d."PreparedDate"
    AND s."ObjectType" != 'PROPERTY';

  ---Jauns kadastra objekts.
  INSERT INTO vzd.nivkis_valuation_object (
    "ObjectCadastreNr"
    ,"CadastralValue"
    ,"CadastralValueDate"
    ,"ForestValue"
    ,"ForestValueDate"
    ,date_created
    )
  SELECT s."ObjectCadastreNr"
    ,s."ObjectCadastralValue"
    ,s."ObjectCadastralValueDate"
    ,s."ObjectForestValue"
    ,s."ObjectForestValueDate"
    ,d."PreparedDate"
  FROM nivkis_valuation_tmp2 s
  CROSS JOIN nivkis_valuation_tmp_prepareddate d
  LEFT OUTER JOIN vzd.nivkis_valuation_object u ON s."ObjectCadastreNr" = u."ObjectCadastreNr"
  WHERE u."ObjectCadastreNr" IS NULL
    AND s."ObjectType" != 'PROPERTY';

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