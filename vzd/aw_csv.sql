DROP SCHEMA IF EXISTS aw_csv CASCADE;

CREATE SCHEMA IF NOT EXISTS aw_csv;

ALTER SCHEMA aw_csv OWNER TO editor;

GRANT ALL ON SCHEMA aw_csv TO editor;

GRANT USAGE ON SCHEMA aw_csv TO basic_user, scheduler;

ALTER DEFAULT PRIVILEGES IN SCHEMA aw_csv
GRANT SELECT
  ON TABLES
  TO editor
    ,basic_user;

--aw_ciems.
DROP TABLE IF EXISTS aw_csv.aw_ciems;

CREATE TABLE aw_csv.aw_ciems (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,apstipr BOOLEAN
  ,apst_pak SMALLINT
  ,statuss CHAR(3) NOT NULL
  ,sort_nos TEXT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT
  ,atrib TEXT
  ,std TEXT
  );

--aw_ciems_his.
DROP TABLE IF EXISTS aw_csv.aw_ciems_his;

CREATE TABLE aw_csv.aw_ciems_his (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT NOT NULL
  ,std TEXT
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  );

--aw_dziv.
DROP TABLE IF EXISTS aw_csv.aw_dziv;

CREATE TABLE aw_csv.aw_dziv (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,statuss CHAR(3) NOT NULL
  ,apstipr BOOLEAN
  ,apst_pak SMALLINT
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,sort_nos TEXT NOT NULL
  ,atrib TEXT
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT
  ,std TEXT
  );

--aw_dziv_his.
DROP TABLE IF EXISTS aw_csv.aw_dziv_his;

CREATE TABLE aw_csv.aw_dziv_his (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT NOT NULL
  ,std TEXT
  ,nosaukums TEXT
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  );

--aw_eka.
DROP TABLE IF EXISTS aw_csv.aw_eka;

CREATE TABLE aw_csv.aw_eka (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,statuss CHAR(3) NOT NULL
  ,apstipr BOOLEAN
  ,apst_pak SMALLINT
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,sort_nos TEXT NOT NULL
  ,atrib TEXT
  ,pnod_cd INT
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT
  ,for_build BOOLEAN NOT NULL
  ,plan_adr BOOLEAN NOT NULL
  ,std TEXT
  ,koord_x DECIMAL(9, 3)
  ,koord_y DECIMAL(9, 3)
  ,dd_n DECIMAL(8, 6)
  ,dd_e DECIMAL(8, 6)
  );

--aw_eka_his.
DROP TABLE IF EXISTS aw_csv.aw_eka_his;

CREATE TABLE aw_csv.aw_eka_his (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,kods_his INT
  ,tips_cd SMALLINT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT
  ,std TEXT
  ,nosaukums TEXT
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  );

--aw_iela.
DROP TABLE IF EXISTS aw_csv.aw_iela;

CREATE TABLE aw_csv.aw_iela (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,apstipr BOOLEAN
  ,apst_pak SMALLINT
  ,statuss CHAR(3) NOT NULL
  ,sort_nos TEXT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT
  ,atrib TEXT
  ,std TEXT
  );

--aw_iela_his.
DROP TABLE IF EXISTS aw_csv.aw_iela_his;

CREATE TABLE aw_csv.aw_iela_his (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT NOT NULL
  ,std TEXT
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  );

--aw_novads.
DROP TABLE IF EXISTS aw_csv.aw_novads;

CREATE TABLE aw_csv.aw_novads (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,apstipr BOOLEAN
  ,apst_pak SMALLINT
  ,statuss CHAR(3) NOT NULL
  ,sort_nos TEXT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT
  ,atrib TEXT
  ,std TEXT
  );

--aw_novads_his.
DROP TABLE IF EXISTS aw_csv.aw_novads_his;

CREATE TABLE aw_csv.aw_novads_his (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT NOT NULL
  ,std TEXT
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  );

--aw_pagasts.
DROP TABLE IF EXISTS aw_csv.aw_pagasts;

CREATE TABLE aw_csv.aw_pagasts (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,apstipr BOOLEAN
  ,apst_pak SMALLINT
  ,statuss CHAR(3) NOT NULL
  ,sort_nos TEXT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT
  ,atrib TEXT
  ,std TEXT
  );

--aw_pagasts_his.
DROP TABLE IF EXISTS aw_csv.aw_pagasts_his;

CREATE TABLE aw_csv.aw_pagasts_his (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT NOT NULL
  ,std TEXT
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  );

--aw_pilseta.
DROP TABLE IF EXISTS aw_csv.aw_pilseta;

CREATE TABLE aw_csv.aw_pilseta (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,apstipr BOOLEAN
  ,apst_pak SMALLINT
  ,statuss CHAR(3) NOT NULL
  ,sort_nos TEXT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT
  ,atrib TEXT
  ,std TEXT
  );

--aw_pilseta_his.
DROP TABLE IF EXISTS aw_csv.aw_pilseta_his;

CREATE TABLE aw_csv.aw_pilseta_his (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT NOT NULL
  ,std TEXT
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  );

--aw_ppils.
DROP TABLE IF EXISTS aw_csv.aw_ppils;

CREATE TABLE aw_csv.aw_ppils (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,ppils TEXT NOT NULL
  );

--aw_rajons.
DROP TABLE IF EXISTS aw_csv.aw_rajons;

CREATE TABLE aw_csv.aw_rajons (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,apstipr BOOLEAN
  ,apst_pak SMALLINT
  ,statuss CHAR(3) NOT NULL
  ,sort_nos TEXT NOT NULL
  ,dat_sak TEXT NOT NULL
  ,dat_mod TEXT NOT NULL
  ,dat_beig TEXT
  ,atrib TEXT
  );

--aw_vietu_centroidi.
DROP TABLE IF EXISTS aw_csv.aw_vietu_centroidi;

CREATE TABLE aw_csv.aw_vietu_centroidi (
  id serial PRIMARY KEY
  ,kods INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,std TEXT
  ,koord_x DECIMAL(9, 3)
  ,koord_y DECIMAL(9, 3)
  ,dd_n DECIMAL(8, 6)
  ,dd_e DECIMAL(8, 6)
  );

--Ar superlietotāja tiesībām.
ALTER DEFAULT PRIVILEGES
FOR ROLE scheduler IN SCHEMA aw_csv
GRANT SELECT
  ON TABLES
  TO editor
    ,basic_user;

ALTER DEFAULT PRIVILEGES
FOR ROLE scheduler IN SCHEMA aw_csv
GRANT SELECT
  ON SEQUENCES
  TO editor
    ,basic_user;

ALTER TABLE aw_csv.aw_ciems OWNER TO scheduler;
ALTER TABLE aw_csv.aw_ciems_his OWNER TO scheduler;
ALTER TABLE aw_csv.aw_dziv OWNER TO scheduler;
ALTER TABLE aw_csv.aw_dziv_his OWNER TO scheduler;
ALTER TABLE aw_csv.aw_eka OWNER TO scheduler;
ALTER TABLE aw_csv.aw_eka_his OWNER TO scheduler;
ALTER TABLE aw_csv.aw_iela OWNER TO scheduler;
ALTER TABLE aw_csv.aw_iela_his OWNER TO scheduler;
ALTER TABLE aw_csv.aw_novads OWNER TO scheduler;
ALTER TABLE aw_csv.aw_novads_his OWNER TO scheduler;
ALTER TABLE aw_csv.aw_pagasts OWNER TO scheduler;
ALTER TABLE aw_csv.aw_pagasts_his OWNER TO scheduler;
ALTER TABLE aw_csv.aw_pilseta OWNER TO scheduler;
ALTER TABLE aw_csv.aw_pilseta_his OWNER TO scheduler;
ALTER TABLE aw_csv.aw_ppils OWNER TO scheduler;
ALTER TABLE aw_csv.aw_rajons OWNER TO scheduler;
ALTER TABLE aw_csv.aw_vietu_centroidi OWNER TO scheduler;

GRANT SELECT ON TABLE aw_csv.aw_ciems TO editor;
GRANT SELECT ON TABLE aw_csv.aw_ciems_his TO editor;
GRANT SELECT ON TABLE aw_csv.aw_dziv TO editor;
GRANT SELECT ON TABLE aw_csv.aw_dziv_his TO editor;
GRANT SELECT ON TABLE aw_csv.aw_eka TO editor;
GRANT SELECT ON TABLE aw_csv.aw_eka_his TO editor;
GRANT SELECT ON TABLE aw_csv.aw_iela TO editor;
GRANT SELECT ON TABLE aw_csv.aw_iela_his TO editor;
GRANT SELECT ON TABLE aw_csv.aw_novads TO editor;
GRANT SELECT ON TABLE aw_csv.aw_novads_his TO editor;
GRANT SELECT ON TABLE aw_csv.aw_pagasts TO editor;
GRANT SELECT ON TABLE aw_csv.aw_pagasts_his TO editor;
GRANT SELECT ON TABLE aw_csv.aw_pilseta TO editor;
GRANT SELECT ON TABLE aw_csv.aw_pilseta_his TO editor;
GRANT SELECT ON TABLE aw_csv.aw_ppils TO editor;
GRANT SELECT ON TABLE aw_csv.aw_rajons TO editor;
GRANT SELECT ON TABLE aw_csv.aw_vietu_centroidi TO editor;