CREATE OR REPLACE PROCEDURE vzd.nivkis_building_pre_reg_proc(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

DROP TABLE IF EXISTS vzd.nivkis_building_pre_reg;

CREATE TABLE vzd.nivkis_building_pre_reg (
  id serial PRIMARY KEY
  ,"BuildingCadastreNr" VARCHAR(14) NOT NULL
  ,"BuildingName" TEXT NOT NULL
  ,"BuildingAddress" TEXT
  ,"BuildingGroundFloors" SMALLINT
  ,"BuildingConstrArea" DECIMAL(11, 2)
  ,"MaterialKindName" TEXT
  ,"BuildingRegisterDate" DATE
  ,"ParcelCadastreNr" VARCHAR(11) NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_building_pre_reg IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmā pirmsreģistrētās būves.';

COMMENT ON COLUMN vzd.nivkis_building_pre_reg.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_building_pre_reg."BuildingCadastreNr" IS 'Būves kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_building_pre_reg."BuildingName" IS 'Būves nosaukums.';

COMMENT ON COLUMN vzd.nivkis_building_pre_reg."BuildingAddress" IS 'Būves adrese.';

COMMENT ON COLUMN vzd.nivkis_building_pre_reg."BuildingGroundFloors" IS 'Virszemes stāvu skaits.';

COMMENT ON COLUMN vzd.nivkis_building_pre_reg."BuildingConstrArea" IS 'Apbūves laukums, m².';

COMMENT ON COLUMN vzd.nivkis_building_pre_reg."MaterialKindName" IS 'Ārsienu materiāla nosaukums.';

COMMENT ON COLUMN vzd.nivkis_building_pre_reg."BuildingRegisterDate" IS 'Būves reģistrēšanas datums.';

COMMENT ON COLUMN vzd.nivkis_building_pre_reg."ParcelCadastreNr" IS 'Zemes vienības kadastra apzīmējums.';

INSERT INTO vzd.nivkis_building_pre_reg (
  "BuildingCadastreNr"
  ,"BuildingName"
  ,"BuildingAddress"
  ,"BuildingGroundFloors"
  ,"BuildingConstrArea"
  ,"MaterialKindName"
  ,"BuildingRegisterDate"
  ,"ParcelCadastreNr"
  )
SELECT b__ves_kadastra_apz__m__jums
  ,b__ves_nosaukums
  ,b__ves_adrese
  ,st__vu_skaits
  ,apb__ves_laukums
  ,__rsienu_materi__ls
  ,b__ves_re__istr____anas_datums
  ,zemes_vien__bas_kadastra_apz__m__jums
FROM vzd.pirmreg_buves
ORDER BY b__ves_re__istr____anas_datums
  ,b__ves_kadastra_apz__m__jums;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nivkis_building_pre_reg_proc() TO scheduler;