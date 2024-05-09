DROP SERVER IF EXISTS aw_del CASCADE;

CREATE SERVER aw_del FOREIGN DATA WRAPPER ogr_fdw OPTIONS (
  datasource '/home/user/data/aw_del/aw_eka_del.xlsx'
  ,format 'XLSX'
  );

ALTER SERVER aw_del OWNER TO editor;

--IMPORT FOREIGN SCHEMA ogr_all FROM SERVER aw_del INTO vzd;

DROP FOREIGN TABLE IF EXISTS vzd.aw_eka_del;

CREATE FOREIGN TABLE vzd.aw_eka_del (
  fid BIGINT NOT NULL
  ,dz__st__s_adreses_kods INTEGER OPTIONS(column_name 'Dzēstās adreses kods') NOT NULL
  ,beigu_datums CHARACTER VARYING OPTIONS(column_name 'Beigu datums') NOT NULL
  ,koordin__ta_x__zieme__u_virziens__ DOUBLE PRECISION OPTIONS(column_name 'Koordināta X (ziemeļu virziens) ') NOT NULL
  ,koordin__ta_y__austrumu__virziens_ DOUBLE PRECISION OPTIONS(column_name 'Koordināta Y (austrumu  virziens)') NOT NULL
  ,dz__st__s_adreses_standartpieraksts CHARACTER VARYING OPTIONS(column_name 'Dzēstās adreses standartpieraksts') NOT NULL
  )
  SERVER aw_del
  OPTIONS (layer 'Export Worksheet');