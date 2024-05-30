DROP SERVER IF EXISTS pre_reg_buildings CASCADE;

CREATE SERVER pre_reg_buildings FOREIGN DATA WRAPPER ogr_fdw OPTIONS (
  datasource '/home/user/data/nivkis_txt/pirmreg_buves.xlsx'
  ,format 'XLSX'
  );

ALTER SERVER pre_reg_buildings OWNER TO editor;

--IMPORT FOREIGN SCHEMA ogr_all FROM SERVER pre_reg_buildings INTO vzd;

DROP FOREIGN TABLE IF EXISTS vzd.pirmreg_buves;

CREATE FOREIGN TABLE IF NOT EXISTS vzd.pirmreg_buves (
  fid BIGINT NOT NULL
  ,administrat__v___teritorija CHARACTER VARYING OPTIONS(column_name 'Administratīvā teritorija') NOT NULL
  ,administrat__vi_teritori__l___vien__ba CHARACTER VARYING OPTIONS(column_name 'Administratīvi teritoriālā vienība') NOT NULL
  ,b__ves_kadastra_apz__m__jums CHARACTER VARYING OPTIONS(column_name 'Būves kadastra apzīmējums') NOT NULL
  ,b__ves_nosaukums CHARACTER VARYING OPTIONS(column_name 'Būves nosaukums') NOT NULL
  ,b__ves_adrese CHARACTER VARYING OPTIONS(column_name 'Būves adrese')
  ,st__vu_skaits INTEGER OPTIONS(column_name 'Stāvu skaits')
  ,apb__ves_laukums DOUBLE PRECISION OPTIONS(column_name 'Apbūves laukums')
  ,__rsienu_materi__ls CHARACTER VARYING OPTIONS(column_name 'Ārsienu materiāls')
  ,b__ves_re__istr____anas_datums DATE OPTIONS(column_name 'Būves reģistrēšanas datums')
  ,zemes_vien__bas_kadastra_apz__m__jums CHARACTER VARYING OPTIONS(column_name 'Zemes vienības kadastra apzīmējums') NOT NULL
  ,zemes_vien__bas_adrese CHARACTER VARYING OPTIONS(column_name 'Zemes vienības adrese')
  ,dati_atlas__ti_uz DATE OPTIONS(column_name 'Dati atlasīti uz') NOT NULL
  )
    SERVER pre_reg_buildings
    OPTIONS (layer 'Sheet1');

GRANT SELECT
  ON TABLE vzd.pirmreg_buves
  TO scheduler;