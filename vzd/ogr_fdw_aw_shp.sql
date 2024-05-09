DROP SERVER IF EXISTS aw_shp CASCADE;

CREATE SERVER aw_shp FOREIGN DATA WRAPPER ogr_fdw OPTIONS (
  datasource '/home/user/data/aw_shp/', 
  format 'ESRI Shapefile'
);

ALTER SERVER aw_shp OWNER TO editor;

DROP SCHEMA IF EXISTS aw_shp CASCADE;

CREATE SCHEMA IF NOT EXISTS aw_shp;

ALTER SCHEMA aw_shp OWNER TO editor;

GRANT ALL ON SCHEMA aw_shp TO editor;

GRANT USAGE ON SCHEMA aw_shp TO basic_user, scheduler;

ALTER DEFAULT PRIVILEGES IN SCHEMA aw_shp
GRANT SELECT ON TABLES TO editor, basic_user, scheduler;

IMPORT FOREIGN SCHEMA ogr_all FROM SERVER aw_shp INTO aw_shp;