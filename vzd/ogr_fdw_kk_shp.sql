DROP SERVER IF EXISTS kk_shp CASCADE;

CREATE SERVER kk_shp FOREIGN DATA WRAPPER ogr_fdw OPTIONS (
  datasource '/home/user/data/kk_shp/', 
  format 'ESRI Shapefile'
);

ALTER SERVER kk_shp OWNER TO editor;

DROP SCHEMA IF EXISTS kk_shp CASCADE;

CREATE SCHEMA IF NOT EXISTS kk_shp;

ALTER SCHEMA kk_shp OWNER TO editor;

GRANT ALL ON SCHEMA kk_shp TO editor;

GRANT USAGE ON SCHEMA kk_shp TO basic_user, scheduler;

ALTER DEFAULT PRIVILEGES IN SCHEMA kk_shp
GRANT SELECT ON TABLES TO editor, basic_user, scheduler;

IMPORT FOREIGN SCHEMA ogr_all FROM SERVER kk_shp INTO kk_shp;