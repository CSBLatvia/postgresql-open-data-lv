DROP SERVER IF EXISTS csv_csp CASCADE;

CREATE SERVER csv_csp FOREIGN DATA WRAPPER ogr_fdw OPTIONS (
  datasource '/home/user/data/csp'
  ,format 'CSV'
  );

ALTER SERVER csv_csp OWNER TO editor;

IMPORT FOREIGN SCHEMA ogr_all FROM SERVER csv_csp INTO csp;

GRANT SELECT
  ON TABLE csp.atu_nuts_codes
  TO scheduler;

GRANT SELECT
  ON TABLE csp.atvk_2021_parejas_tabula
  TO scheduler;

--Pārejas tabula 01.07.2022. izmaiņām.
CREATE VIEW csp.atvk_2022_parejas_tabula
AS
WITH o
AS (
  SELECT "level"
    ,code
    ,name
    ,c successors
    ,validity_period_end
  FROM csp.atu_nuts_codes
  INNER JOIN LATERAL UNNEST(STRING_TO_ARRAY(REPLACE(successors, ' ', ''), ',')) c ON true
  )
  ,d
AS (
  SELECT o.code code_old
    ,o.name name_old
    ,n.code code_new
    ,n.name name_new
  FROM csp.atu_nuts_codes n
  LEFT OUTER JOIN o ON n."level" = o."level"
    AND n."code" = o.successors
    AND n.validity_period_begin = o.validity_period_end
  WHERE n.validity_period_begin = '2022-07-01'
  )
SELECT at_kods
  ,at_nosaukums
  ,tv_kods
  ,tv_nosaukums
  ,a.at2021_kods at2022_kods
  ,a.at2021_nosaukums at2022_nosaukums
  ,CASE 
    WHEN d.code_new IS NOT NULL
      THEN d.code_new
    ELSE a.tv2021_kods
    END tv2022_kods
  ,CASE 
    WHEN d.code_new IS NOT NULL
      THEN d.name_new
    ELSE a.tv2021_nosaukums
    END tv2022_nosaukums
FROM csp.atvk_2021_parejas_tabula a
LEFT OUTER JOIN d ON a.tv2021_kods = d.code_old
WHERE a.at_kods NOT LIKE ' ';

GRANT SELECT
  ON TABLE csp.atvk_2022_parejas_tabula
  TO scheduler;