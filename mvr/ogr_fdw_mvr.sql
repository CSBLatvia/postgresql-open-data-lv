DROP SERVER IF EXISTS mvr CASCADE;

CREATE SERVER mvr FOREIGN DATA WRAPPER ogr_fdw OPTIONS (
  datasource '/home/user/data/mvr/', 
  format 'ESRI Shapefile'
);

ALTER SERVER mvr OWNER TO editor;

IMPORT FOREIGN SCHEMA ogr_all FROM SERVER mvr INTO mvr;

GRANT SELECT
  ON TABLE mvr.mvr
  TO scheduler;