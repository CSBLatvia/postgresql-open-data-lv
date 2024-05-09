--Adresācijas objektu tipi.
DROP TABLE IF EXISTS vzd.adreses_tips;

CREATE TABLE vzd.adreses_tips (
  tips_cd SMALLINT NOT NULL PRIMARY KEY
  ,nosaukums TEXT
  );

COMMENT ON TABLE vzd.adreses_tips IS 'Adresācijas objektu tipi.';

COMMENT ON COLUMN vzd.adreses_tips.tips_cd IS 'Kods.';

COMMENT ON COLUMN vzd.adreses_tips.nosaukums IS 'Adresācijas objekta tips.';

GRANT REFERENCES
  ON TABLE vzd.adreses_tips
  TO scheduler;

INSERT INTO vzd.adreses_tips (
  tips_cd
  ,nosaukums
  )
VALUES (
  101
  ,'Latvijas Republika'
  )
  ,(
  102
  ,'Rajons'
  )
  ,(
  104
  ,'Pilsēta'
  )
  ,(
  105
  ,'Pagasts'
  )
  ,(
  106
  ,'Ciems/mazciems'
  )
  ,(
  107
  ,'Iela'
  )
  ,(
  108
  ,'Ēka, apbūvei paredzēta zemes vienība'
  )
  ,(
  109
  ,'Telpu grupa'
  )
  ,(
  113
  ,'Novads'
  );

--Adresācijas objektu apstiprinājuma pakāpes.
DROP TABLE IF EXISTS vzd.adreses_apst_pak;

CREATE TABLE vzd.adreses_apst_pak (
  apst_pak SMALLINT NOT NULL PRIMARY KEY
  ,nosaukums TEXT
  ,apraksts TEXT
  );

COMMENT ON TABLE vzd.adreses_apst_pak IS 'Adresācijas objektu apstiprinājuma pakāpes.';

COMMENT ON COLUMN vzd.adreses_apst_pak.apst_pak IS 'Kods.';

COMMENT ON COLUMN vzd.adreses_apst_pak.nosaukums IS 'Saīsinājums.';

COMMENT ON COLUMN vzd.adreses_apst_pak.apraksts IS 'Apstiprinājuma pakāpe.';

GRANT REFERENCES
  ON TABLE vzd.adreses_apst_pak
  TO scheduler;

INSERT INTO vzd.adreses_apst_pak (
  apst_pak
  ,nosaukums
  ,apraksts
  )
VALUES (
  251
  ,'Kļūdains apstiprinājums'
  ,'Kļūdains apstiprinājums.'
  )
  ,(
  252
  ,'Oficiāls apstiprinājums'
  ,'Apstiprinājums, pamatojoties uz oficiālu informāciju, ja par adresācijas objekta reģistrāciju vai datu aktualizāciju iesniegts normatīvajos aktos norādītais dokuments.'
  )
  ,(
  253
  ,'Daļējs apstiprinājums'
  ,'Apstiprinājums, pamatojoties uz dokumentiem bez atbilstoša juridiska statusa vai, ja par adresācijas objekta reģistrāciju vai datu aktualizāciju iesniegts pašvaldības cita veida rakstisks tā pastāvēšanas apliecinājums.'
  )
  ,(
  254
  ,'Citu reģistru apstiprinājums'
  ,'Saņemta (nepārbaudīta) no ārējiem reģistriem, ja dati par adresācijas objektu iegūti no citām valsts informācijas sistēmām (piemēram, datu sākotnējās uzkrāšanas laikā).'
  );

--Tabula dzēsto ēku un apbūvei paredzēto zemes vienību adresācijas objektu koordinātu uzkrāšanai.
DROP TABLE IF EXISTS vzd.adreses_ekas_koord_del;

CREATE TABLE vzd.adreses_ekas_koord_del (
  id serial PRIMARY KEY
  ,adr_cd INT NOT NULL
  ,geom geometry(Point, 3059)
  );

COMMENT ON TABLE vzd.adreses_ekas_koord_del IS 'Dzēsto ēku un apbūvei paredzēto zemes vienību adresācijas objektu koordinātas.';

COMMENT ON COLUMN vzd.adreses_ekas_koord_del.id IS 'ID.';

COMMENT ON COLUMN vzd.adreses_ekas_koord_del.adr_cd IS 'Adresācijas objekta kods.';

COMMENT ON COLUMN vzd.adreses_ekas_koord_del.geom IS 'Ģeometrija.';

GRANT SELECT, INSERT
  ON TABLE vzd.adreses_ekas_koord_del
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.adreses_ekas_koord_del_id_seq
  TO scheduler;

--Vēsturisko datu imports no Latvijas atvērto datu portālā publicētajiem datiem.
INSERT INTO vzd.adreses_ekas_koord_del (
  adr_cd
  ,geom
  )
SELECT dz__st__s_adreses_kods
  ,ST_SetSRID(ST_MakePoint(koordin__ta_y__austrumu__virziens_, koordin__ta_x__zieme__u_virziens__), 3059)
FROM vzd.aw_eka_del
ORDER BY beigu_datums::DATE;

--Adrešu vēsturiskie pieraksti.
DROP TABLE IF EXISTS vzd.adreses_his;

CREATE TABLE vzd.adreses_his (
  id serial PRIMARY KEY
  ,adr_cd INT NOT NULL
  ,adr_cd_his INT
  ,tips_cd SMALLINT NOT NULL
  ,std TEXT
  ,nosaukums TEXT NOT NULL
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,dat_sak DATE NOT NULL
  ,dat_mod TIMESTAMP NOT NULL
  ,dat_beig DATE NULL
  );

ALTER TABLE vzd.adreses_his ADD CONSTRAINT adreses_his_fk_tips_cd FOREIGN KEY (tips_cd) REFERENCES vzd.adreses_tips (tips_cd);

COMMENT ON TABLE vzd.adreses_his IS 'Adrešu vēsturiskie pieraksti.';

COMMENT ON COLUMN vzd.adreses_his.id IS 'ID.';

COMMENT ON COLUMN vzd.adreses_his.adr_cd IS 'Adresācijas objekta kods.';

COMMENT ON COLUMN vzd.adreses_his.adr_cd_his IS 'Adresācijas objekta vēsturiskais kods (gadījumos, kad viena adrese bija lietota vairākiem objektiem).';

COMMENT ON COLUMN vzd.adreses_his.tips_cd IS 'Adresācijas objekta tipa kods.';

COMMENT ON COLUMN vzd.adreses_his.std IS 'Adresācijas objekta pilnais vēsturiskais adreses pieraksts.';

COMMENT ON COLUMN vzd.adreses_his.nosaukums IS 'Adresācijas objekta vēsturiskais nosaukums.';

COMMENT ON COLUMN vzd.adreses_his.vkur_cd IS 'Tā adresācijas objekta kods, kam hierarhiski pakļauts attiecīgais adresācijas objekts.';

COMMENT ON COLUMN vzd.adreses_his.vkur_tips IS 'Tā adresācijas objekta tipa kods, kam hierarhiski pakļauts attiecīgais adresācijas objekts.';

COMMENT ON COLUMN vzd.adreses_his.dat_sak IS 'Adresācijas objekta izveidošanas vai pirmreizējās reģistrācijas datums, ja nav zināms precīzs adresācijas objekta izveides datums.';

COMMENT ON COLUMN vzd.adreses_his.dat_mod IS 'Datums un laiks, kad pēdējo reizi informācijas sistēmā tehniski modificēts ieraksts/dati par adresācijas objektu (piemēram, aktualizēts statuss, apstiprinājuma pakāpe, pievienots atribūts u.c.) vai mainīts pilnais adreses pieraksts.';

COMMENT ON COLUMN vzd.adreses_his.dat_beig IS 'Adresācijas objekta likvidācijas datums.';

GRANT SELECT, INSERT, DELETE
  ON TABLE vzd.adreses_his
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.adreses_his_id_seq
  TO scheduler;

--Pa laukiem sadalīti adrešu vēsturiskie pieraksti.
DROP TABLE IF EXISTS vzd.adreses_his_ekas_split;

CREATE TABLE vzd.adreses_his_ekas_split (
  id INT NOT NULL PRIMARY KEY
  ,nosaukums TEXT NOT NULL
  ,iela TEXT
  ,ciems TEXT
  ,pilseta TEXT
  ,pagasts TEXT
  ,novads TEXT
  ,rajons TEXT
  );

ALTER TABLE vzd.adreses_his_ekas_split ADD CONSTRAINT adreses_his_ekas_split_fk_id FOREIGN KEY (id) REFERENCES vzd.adreses_his (id);

COMMENT ON TABLE vzd.adreses_his_ekas_split IS 'Adrešu vēsturiskie pieraksti sadalīti pa laukiem.';

COMMENT ON COLUMN vzd.adreses_his_ekas_split.id IS 'ID.';

COMMENT ON COLUMN vzd.adreses_his_ekas_split.nosaukums IS 'Ēkas Nr. vai nosaukums.';

COMMENT ON COLUMN vzd.adreses_his_ekas_split.iela IS 'Ielas nosaukums.';

COMMENT ON COLUMN vzd.adreses_his_ekas_split.ciems IS 'Ciema/mazciema nosaukums.';

COMMENT ON COLUMN vzd.adreses_his_ekas_split.pilseta IS 'Pilsētas nosaukums.';

COMMENT ON COLUMN vzd.adreses_his_ekas_split.pagasts IS 'Pagasta nosaukums.';

COMMENT ON COLUMN vzd.adreses_his_ekas_split.novads IS 'Novada nosaukums.';

COMMENT ON COLUMN vzd.adreses_his_ekas_split.rajons IS 'Rajona nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.adreses_his_ekas_split
  TO scheduler;