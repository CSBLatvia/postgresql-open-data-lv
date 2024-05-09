DROP SERVER IF EXISTS csv_nitis CASCADE;

CREATE SERVER csv_nitis FOREIGN DATA WRAPPER ogr_fdw OPTIONS (
  datasource '/home/user/data/nitis'
  ,format 'CSV'
  );

ALTER SERVER csv_nitis OWNER TO editor;

DROP FOREIGN TABLE IF EXISTS vzd.zv
  ,vzd.zvb
  ,vzd.tg;

IMPORT FOREIGN SCHEMA ogr_all FROM SERVER csv_nitis INTO vzd;

GRANT SELECT
  ON TABLE vzd.zv
  TO scheduler;

GRANT SELECT
  ON TABLE vzd.zvb
  TO scheduler;

GRANT SELECT
  ON TABLE vzd.tg
  TO scheduler;