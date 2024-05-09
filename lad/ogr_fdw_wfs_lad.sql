--Lauku bloki.
DROP SERVER IF EXISTS wfs_lad_field_blocks CASCADE;

CREATE SERVER wfs_lad_field_blocks FOREIGN DATA WRAPPER ogr_fdw OPTIONS (
  datasource 'WFS:https://karte.lad.gov.lv/arcgis/services/lauku_bloki/MapServer/WFSServer'
  ,format 'WFS'
  ,config_options 'GDAL_HTTP_UNSAFESSL=YES'
  );

ALTER SERVER wfs_lad_field_blocks OWNER TO editor;

IMPORT FOREIGN SCHEMA ogr_all FROM SERVER wfs_lad_field_blocks INTO lad;

GRANT SELECT
  ON TABLE lad.lad_lauku_bloki
  TO scheduler;

--Lauki.
DROP SERVER IF EXISTS wfs_lad_fields CASCADE;

CREATE SERVER wfs_lad_fields FOREIGN DATA WRAPPER ogr_fdw OPTIONS (
  datasource 'WFS:https://karte.lad.gov.lv/arcgis/services/lauki/MapServer/WFSServer'
  ,format 'WFS'
  ,config_options 'GDAL_HTTP_UNSAFESSL=YES'
  );

ALTER SERVER wfs_lad_fields OWNER TO editor;

IMPORT FOREIGN SCHEMA ogr_all FROM SERVER wfs_lad_fields INTO lad;

GRANT SELECT
  ON TABLE lad.lad_lauki
  TO scheduler;