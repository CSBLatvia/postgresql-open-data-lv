--ZV.
---nitis_zv.
DROP TABLE IF EXISTS vzd.nitis_zv;

CREATE TABLE IF NOT EXISTS vzd.nitis_zv (
  id serial PRIMARY KEY
  ,gads SMALLINT NOT NULL
  ,darijuma_id INT NOT NULL
  ,darijuma_datums DATE NOT NULL
  ,kadastra_nr VARCHAR(11) NOT NULL
  ,adrese TEXT NOT NULL
  ,atvk VARCHAR(7) NULL
  ,darijuma_summa DECIMAL(10, 2) NOT NULL
  ,zemes_skaititajs BIGINT NULL
  ,zemes_saucejs BIGINT NULL
  ,apbuveta SMALLINT NOT NULL
  ,kopplatiba DECIMAL(10, 2) NOT NULL
  --,lauksaimniecibas_zeme DECIMAL(10, 2) NULL
  ,aramzeme DECIMAL(10, 2) NULL
  ,auglu_darzi DECIMAL(10, 2) NULL
  ,plavas DECIMAL(10, 2) NULL
  ,ganibas DECIMAL(10, 2) NULL
  ,melioreta_liz DECIMAL(10, 2) NULL
  ,mezi DECIMAL(10, 2) NULL
  ,krumaji DECIMAL(10, 2) NULL
  ,purvi DECIMAL(10, 2) NULL
  ,zem_udeniem DECIMAL(10, 2) NULL
  ,zem_dikiem DECIMAL(10, 2) NULL
  ,zem_ekam_un_pagalmiem DECIMAL(10, 2) NULL
  ,zem_celiem DECIMAL(10, 2) NULL
  ,pareja_zeme DECIMAL(10, 2) NULL
  );

CREATE UNIQUE INDEX zv_darijuma_id_idx ON vzd.nitis_zv (darijuma_id);

COMMENT ON TABLE vzd.nitis_zv IS 'NĪTIS darījumi ar zemi.';

COMMENT ON COLUMN vzd.nitis_zv.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_zv.gads IS 'Datu kopas gads.';

COMMENT ON COLUMN vzd.nitis_zv.darijuma_id IS 'Darījuma ID.';

COMMENT ON COLUMN vzd.nitis_zv.darijuma_datums IS 'Darījuma datums.';

COMMENT ON COLUMN vzd.nitis_zv.kadastra_nr IS 'Īpašuma kadastra numurs.';

COMMENT ON COLUMN vzd.nitis_zv.adrese IS 'Adreses pieraksts.';

COMMENT ON COLUMN vzd.nitis_zv.atvk IS 'ATVK.';

COMMENT ON COLUMN vzd.nitis_zv.darijuma_summa IS 'Darījuma summa, EUR.';

COMMENT ON COLUMN vzd.nitis_zv.zemes_skaititajs IS 'Zemes daļas skaitītājs.';

COMMENT ON COLUMN vzd.nitis_zv.zemes_saucejs IS 'Zemes daļas saucējs.';

COMMENT ON COLUMN vzd.nitis_zv.apbuveta IS 'Vai zeme ir apbūvēta (0 - nav, 1 - ir).';

COMMENT ON COLUMN vzd.nitis_zv.kopplatiba IS 'Pārdotā zemes kopplatība, m².';

--COMMENT ON COLUMN vzd.nitis_zv.lauksaimniecibas_zeme IS 'Pārdotā lauksaimniecības zemes platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.aramzeme IS 'Pārdotā aramzemes platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.auglu_darzi IS 'Pārdotā augļu dārzu platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.plavas IS 'Pārdotā pļavu platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.ganibas IS 'Pārdotā ganību platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.melioreta_liz IS 'Pārdotā meliorētās LIZ platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.mezi IS 'Pārdotā mežu zemes platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.krumaji IS 'Pārdotā krūmāju platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.purvi IS 'Pārdotā purvu platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.zem_udeniem IS 'Pārdotā zemes zem ūdeņiem platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.zem_dikiem IS 'Pārdotā zemes zem dīķiem platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.zem_ekam_un_pagalmiem IS 'Pārdotā zemes zem ēkām un pagalmiem platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.zem_celiem IS 'Pārdotā zemes zem ceļiem platība, m².';

COMMENT ON COLUMN vzd.nitis_zv.pareja_zeme IS 'Pārdotā pārējās zemes platība, m².';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nitis_zv
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_zv_id_seq
  TO scheduler;

---nitis_zv_nilm.
DROP TABLE IF EXISTS vzd.nitis_zv_nilm;

CREATE TABLE IF NOT EXISTS vzd.nitis_zv_nilm (
  id serial PRIMARY KEY
  ,darijuma_id INT NOT NULL
  ,kods VARCHAR(4) NOT NULL
  ,platiba INT NOT NULL
  );

COMMENT ON TABLE vzd.nitis_zv_nilm IS 'Nekustamā īpašuma lietošanas mērķi (NĪLM) NĪTIS darījumos ar zemi un zemi ar būvēm.';

COMMENT ON COLUMN vzd.nitis_zv_nilm.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_zv_nilm.darijuma_id IS 'Darījuma ID.';

COMMENT ON COLUMN vzd.nitis_zv_nilm.kods IS 'NĪLM kods.';

COMMENT ON COLUMN vzd.nitis_zv_nilm.platiba IS 'Platība.';

GRANT SELECT, INSERT
  ON TABLE vzd.nitis_zv_nilm
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_zv_nilm_id_seq
  TO scheduler;

---nitis_zv_kad_apz.
DROP TABLE IF EXISTS vzd.nitis_zv_kad_apz;

CREATE TABLE IF NOT EXISTS vzd.nitis_zv_kad_apz (
  id serial PRIMARY KEY
  ,darijuma_id INT NOT NULL
  ,kad_apz VARCHAR(11) NOT NULL
  ,geom geometry
  ,atvk varchar(7)
  ,apkaime varchar(7)
  );

CREATE INDEX nitis_zv_kad_apz_geom_idx ON vzd.nitis_zv_kad_apz USING GIST (geom);

COMMENT ON TABLE vzd.nitis_zv_kad_apz IS 'Kadastra apzīmējumi NĪTIS darījumos ar zemi un zemi ar būvēm.';

COMMENT ON COLUMN vzd.nitis_zv_kad_apz.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_zv_kad_apz.darijuma_id IS 'Darījuma ID.';

COMMENT ON COLUMN vzd.nitis_zv_kad_apz.kad_apz IS 'Kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nitis_zv_kad_apz.geom IS 'Ģeometrija.';

COMMENT ON COLUMN vzd.nitis_zv_kad_apz.atvk IS 'ATVK.';

COMMENT ON COLUMN vzd.nitis_zv_kad_apz.apkaime IS 'Apkaimes kods.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nitis_zv_kad_apz
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_zv_kad_apz_id_seq
  TO scheduler;

--NĪTIS objektu klasifikators.
DROP TABLE IF EXISTS vzd.nitis_k_objekti CASCADE;

CREATE TABLE IF NOT EXISTS vzd.nitis_k_objekti (
  id serial PRIMARY KEY
  ,nosaukums TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nitis_k_objekti IS 'NĪTIS objektu klasifikators.';

COMMENT ON COLUMN vzd.nitis_k_objekti.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_k_objekti.nosaukums IS 'Nosaukums.';

GRANT SELECT, INSERT
  ON TABLE vzd.nitis_k_objekti
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_k_objekti_id_seq
  TO scheduler;

--ZVB.
---nitis_zvb.
DROP TABLE IF EXISTS vzd.nitis_zvb;

CREATE TABLE IF NOT EXISTS vzd.nitis_zvb (
  id serial PRIMARY KEY
  ,gads SMALLINT NOT NULL
  ,darijuma_id INT NOT NULL
  ,darijuma_datums DATE NOT NULL
  ,objekts INT NOT NULL
  ,kadastra_nr VARCHAR(11) NOT NULL
  ,adrese TEXT NOT NULL
  ,atvk VARCHAR(7) NULL
  ,darijuma_summa DECIMAL(10, 2) NOT NULL
  ,zemes_skaititajs BIGINT NULL
  ,zemes_saucejs BIGINT NULL
  ,kopplatiba DECIMAL(10, 2) NOT NULL
  --,lauksaimniecibas_zeme DECIMAL(10, 2) NULL
  ,aramzeme DECIMAL(10, 2) NULL
  ,auglu_darzi DECIMAL(10, 2) NULL
  ,plavas DECIMAL(10, 2) NULL
  ,ganibas DECIMAL(10, 2) NULL
  ,melioreta_liz DECIMAL(10, 2) NULL
  ,mezi DECIMAL(10, 2) NULL
  ,krumaji DECIMAL(10, 2) NULL
  ,purvi DECIMAL(10, 2) NULL
  ,zem_udeniem DECIMAL(10, 2) NULL
  ,zem_dikiem DECIMAL(10, 2) NULL
  ,zem_ekam_un_pagalmiem DECIMAL(10, 2) NULL
  ,zem_celiem DECIMAL(10, 2) NULL
  ,pareja_zeme DECIMAL(10, 2) NULL
  );

CREATE UNIQUE INDEX zvb_darijuma_id_idx ON vzd.nitis_zvb (darijuma_id);

COMMENT ON TABLE vzd.nitis_zvb IS 'NĪTIS darījumi ar zemi un būvēm.';

COMMENT ON COLUMN vzd.nitis_zvb.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_zvb.gads IS 'Datu kopas gads.';

COMMENT ON COLUMN vzd.nitis_zvb.darijuma_id IS 'Darījuma ID.';

COMMENT ON COLUMN vzd.nitis_zvb.darijuma_datums IS 'Darījuma datums.';

COMMENT ON COLUMN vzd.nitis_zvb.objekts IS 'Objekta ID.';

COMMENT ON COLUMN vzd.nitis_zvb.kadastra_nr IS 'Īpašuma kadastra numurs.';

COMMENT ON COLUMN vzd.nitis_zvb.adrese IS 'Adreses pieraksts.';

COMMENT ON COLUMN vzd.nitis_zvb.atvk IS 'ATVK.';

COMMENT ON COLUMN vzd.nitis_zvb.darijuma_summa IS 'Darījuma summa, EUR.';

COMMENT ON COLUMN vzd.nitis_zvb.zemes_skaititajs IS 'Zemes daļas skaitītājs.';

COMMENT ON COLUMN vzd.nitis_zvb.zemes_saucejs IS 'Zemes daļas saucējs.';

COMMENT ON COLUMN vzd.nitis_zvb.kopplatiba IS 'Pārdotā zemes kopplatība, m².';

--COMMENT ON COLUMN vzd.nitis_zvb.lauksaimniecibas_zeme IS 'Pārdotā lauksaimniecības zemes platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.aramzeme IS 'Pārdotā aramzemes platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.auglu_darzi IS 'Pārdotā augļu dārzu platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.plavas IS 'Pārdotā pļavu platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.ganibas IS 'Pārdotā ganību platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.melioreta_liz IS 'Pārdotā meliorētās LIZ platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.mezi IS 'Pārdotā mežu zemes platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.krumaji IS 'Pārdotā krūmāju platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.purvi IS 'Pārdotā purvu platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.zem_udeniem IS 'Pārdotā zemes zem ūdeņiem platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.zem_dikiem IS 'Pārdotā zemes zem dīķiem platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.zem_ekam_un_pagalmiem IS 'Pārdotā zemes zem ēkām un pagalmiem platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.zem_celiem IS 'Pārdotā zemes zem ceļiem platība, m².';

COMMENT ON COLUMN vzd.nitis_zvb.pareja_zeme IS 'Pārdotā pārējās zemes platība, m².';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nitis_zvb
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_zvb_id_seq
  TO scheduler;

--Papildina objektu klasifikatoru.
INSERT INTO vzd.nitis_k_objekti (nosaukums)
SELECT DISTINCT objekts
FROM vzd.zvb
WHERE objekts NOT IN (
    SELECT nosaukums
    FROM vzd.nitis_k_objekti
    )
ORDER BY objekts;

ALTER TABLE vzd.nitis_zvb ADD CONSTRAINT nitis_zvb_fk_objekts FOREIGN KEY (objekts) REFERENCES vzd.nitis_k_objekti (id);

---nitis_b.
DROP TABLE IF EXISTS vzd.nitis_b;

CREATE TABLE IF NOT EXISTS vzd.nitis_b (
  id serial PRIMARY KEY
  ,gads SMALLINT NOT NULL
  ,darijuma_id INT NOT NULL
  ,darijuma_datums DATE NOT NULL
  ,objekts INT NOT NULL
  ,kadastra_nr VARCHAR(11) NOT NULL
  ,adrese TEXT NOT NULL
  ,atvk VARCHAR(7) NULL
  ,darijuma_summa DECIMAL(10, 2) NOT NULL
  );

CREATE UNIQUE INDEX b_darijuma_id_idx ON vzd.nitis_b (darijuma_id);

COMMENT ON TABLE vzd.nitis_b IS 'NĪTIS darījumi ar būvēm.';

COMMENT ON COLUMN vzd.nitis_b.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_b.gads IS 'Datu kopas gads.';

COMMENT ON COLUMN vzd.nitis_b.darijuma_id IS 'Darījuma ID.';

COMMENT ON COLUMN vzd.nitis_b.darijuma_datums IS 'Darījuma datums.';

COMMENT ON COLUMN vzd.nitis_b.objekts IS 'Objekta ID.';

COMMENT ON COLUMN vzd.nitis_b.kadastra_nr IS 'Īpašuma kadastra numurs.';

COMMENT ON COLUMN vzd.nitis_b.adrese IS 'Adreses pieraksts.';

COMMENT ON COLUMN vzd.nitis_b.atvk IS 'ATVK.';

COMMENT ON COLUMN vzd.nitis_b.darijuma_summa IS 'Darījuma summa, EUR.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nitis_b
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_b_id_seq
  TO scheduler;

ALTER TABLE vzd.nitis_b ADD CONSTRAINT nitis_b_fk_objekts FOREIGN KEY (objekts) REFERENCES vzd.nitis_k_objekti (id);

--TG.
---nitis_tg.
DROP TABLE IF EXISTS vzd.nitis_tg;

CREATE TABLE IF NOT EXISTS vzd.nitis_tg (
  id serial PRIMARY KEY
  ,gads SMALLINT NOT NULL
  ,darijuma_id INT NOT NULL
  ,darijuma_datums DATE NOT NULL
  ,objekts INT NOT NULL
  ,kadastra_nr VARCHAR(11) NOT NULL
  ,adrese TEXT NOT NULL
  ,atvk VARCHAR(7) NULL
  ,darijuma_summa DECIMAL(10, 2) NOT NULL
  ,zemes_skaititajs BIGINT NULL
  ,zemes_saucejs BIGINT NULL
  ,zemes_kopplatiba DECIMAL(10, 2) NULL
  ,buves_kad_apz TEXT[] NOT NULL
  );

CREATE UNIQUE INDEX tg_darijuma_id_idx ON vzd.nitis_tg (darijuma_id);

COMMENT ON TABLE vzd.nitis_tg IS 'NĪTIS darījumi ar telpu grupām.';

COMMENT ON COLUMN vzd.nitis_tg.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_tg.gads IS 'Datu kopas gads.';

COMMENT ON COLUMN vzd.nitis_tg.darijuma_id IS 'Darījuma ID.';

COMMENT ON COLUMN vzd.nitis_tg.darijuma_datums IS 'Darījuma datums.';

COMMENT ON COLUMN vzd.nitis_tg.objekts IS 'Objekta ID.';

COMMENT ON COLUMN vzd.nitis_tg.kadastra_nr IS 'Īpašuma kadastra numurs.';

COMMENT ON COLUMN vzd.nitis_tg.adrese IS 'Adreses pieraksts.';

COMMENT ON COLUMN vzd.nitis_tg.atvk IS 'ATVK.';

COMMENT ON COLUMN vzd.nitis_tg.darijuma_summa IS 'Darījuma summa, EUR.';

COMMENT ON COLUMN vzd.nitis_tg.zemes_skaititajs IS 'Zemes daļas skaitītājs.';

COMMENT ON COLUMN vzd.nitis_tg.zemes_saucejs IS 'Zemes daļas saucējs.';

COMMENT ON COLUMN vzd.nitis_tg.zemes_kopplatiba IS 'Pārdotā zemes kopplatība, m².';

COMMENT ON COLUMN vzd.nitis_tg.buves_kad_apz IS 'Būvju kadastra apzīmējumi (viena darījuma ietvaros).';

GRANT SELECT, INSERT
  ON TABLE vzd.nitis_tg
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_tg_id_seq
  TO scheduler;

--Papildina objektu klasifikatoru.
INSERT INTO vzd.nitis_k_objekti (nosaukums)
SELECT DISTINCT objekts
FROM vzd.tg
WHERE objekts NOT IN (
    SELECT nosaukums
    FROM vzd.nitis_k_objekti
    )
ORDER BY objekts;

ALTER TABLE vzd.nitis_tg ADD CONSTRAINT nitis_tg_fk_objekts FOREIGN KEY (objekts) REFERENCES vzd.nitis_k_objekti (id);

---Būvju klasifikācija no https://likumi.lv/ta/id/299645-buvju-klasifikacijas-noteikumi.
DROP TABLE IF EXISTS vzd.nitis_k_liet_veidi CASCADE;

CREATE TABLE IF NOT EXISTS vzd.nitis_k_liet_veidi (
  id serial PRIMARY KEY
  ,kods SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  );

INSERT INTO vzd.nitis_k_liet_veidi (
  kods
  ,nosaukums
  )
VALUES (
  1110
  ,'Viena dzīvokļa mājas'
  )
  ,(
  1121
  ,'Divu dzīvokļu mājas'
  )
  ,(
  1122
  ,'Triju vai vairāku dzīvokļu mājas'
  )
  ,(
  1130
  ,'Dažādu sociālo grupu kopdzīvojamās mājas'
  )
  ,(
  1200
  ,'Koplietošanas telpu grupa'
  )
  ,(
  1211
  ,'Viesnīcas un sabiedriskās ēdināšanas ēkas'
  )
  ,(
  1212
  ,'Citas īslaicīgas apmešanās ēkas'
  )
  ,(
  1220
  ,'Biroju ēkas'
  )
  ,(
  1230
  ,'Vairumtirdzniecības un mazumtirdzniecības ēkas'
  )
  ,(
  1241
  ,'Sakaru ēkas, stacijas, termināļi un ar tiem saistītās ēkas'
  )
  ,(
  1242
  ,'Garāžu ēkas'
  )
  ,(
  1251
  ,'Rūpnieciskās ražošanas ēkas'
  )
  ,(
  1252
  ,'Noliktavas, rezervuāri, bunkuri un silosi'
  )
  ,(
  1261
  ,'Ēkas plašizklaides pasākumiem'
  )
  ,(
  1262
  ,'Muzeji un bibliotēkas'
  )
  ,(
  1263
  ,'Skolas, universitātes un zinātniskajai pētniecībai paredzētās ēkas'
  )
  ,(
  1264
  ,'Ārstniecības vai veselības aprūpes iestāžu ēkas'
  )
  ,(
  1265
  ,'Sporta ēkas'
  )
  ,(
  1271
  ,'Lauksaimniecības nedzīvojamās ēkas'
  )
  ,(
  1272
  ,'Kulta ēkas'
  )
  ,(
  1273
  ,'Kultūrvēsturiskie objekti'
  )
  ,(
  1274
  ,'Citas, iepriekš neklasificētas, ēkas'
  )
  ,(
  2111
  ,'Autoceļi'
  )
  ,(
  2112
  ,'Ielas, ceļi un laukumi'
  )
  ,(
  2121
  ,'Dzelzceļi'
  )
  ,(
  2122
  ,'Pilsētas sliežu ceļi'
  )
  ,(
  2130
  ,'Lidlauku skrejceļi'
  )
  ,(
  2141
  ,'Tilti un estakādes'
  )
  ,(
  2142
  ,'Tuneļi un pazemes ceļi'
  )
  ,(
  2151
  ,'Ostas un kuģojamie kanāli'
  )
  ,(
  2152
  ,'Dambji'
  )
  ,(
  2153
  ,'Akvedukti, apūdeņošanas un meliorācijas hidrobūves'
  )
  ,(
  2211
  ,'Maģistrālie naftas produktu un gāzes cauruļvadi'
  )
  ,(
  2212
  ,'Maģistrālie ūdensapgādes cauruļvadi'
  )
  ,(
  2213
  ,'Maģistrālās sakaru līnijas'
  )
  ,(
  2214
  ,'Maģistrālās elektropārvades un elektrosadales līnijas'
  )
  ,(
  2221
  ,'Gāzes sadales sistēmas'
  )
  ,(
  2222
  ,'Vietējās nozīmes aukstā un karstā ūdens apgādes būves'
  )
  ,(
  2223
  ,'Vietējās nozīmes notekūdeņu cauruļvadi un attīrīšanas būves'
  )
  ,(
  2224
  ,'Vietējās nozīmes elektropārvades un sakaru kabeļu būves'
  )
  ,(
  2301
  ,'Ieguves rūpniecības vai iežieguves būves'
  )
  ,(
  2302
  ,'Spēkstaciju būves'
  )
  ,(
  2303
  ,'Ķīmiskās rūpniecības uzņēmumu būves'
  )
  ,(
  2304
  ,'Iepriekš neklasificētas smagās rūpniecības uzņēmumu būves'
  )
  ,(
  2411
  ,'Sporta laukumi'
  )
  ,(
  2412
  ,'Citas sporta un atpūtas būves'
  )
  ,(
  2420
  ,'Citas, iepriekš neklasificētas, inženierbūves'
  );

CREATE UNIQUE INDEX liet_veida_kods_idx ON vzd.nitis_k_liet_veidi (kods);

COMMENT ON TABLE vzd.nitis_k_liet_veidi IS 'Būves lietošanas veidu klasifikators.';

COMMENT ON COLUMN vzd.nitis_k_liet_veidi.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_k_liet_veidi.kods IS 'Būves lietošanas veida kods.';

COMMENT ON COLUMN vzd.nitis_k_liet_veidi.nosaukums IS 'Būves lietošanas veida nosaukums.';

GRANT SELECT, INSERT
  ON TABLE vzd.nitis_k_liet_veidi
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_k_liet_veidi_id_seq
  TO scheduler;

---Ēku konstruktīvo elementu materiālu klasifikācija no https://likumi.lv/ta/id/243153-buvju-kadastralas-uzmerisanas-noteikumi.
DROP TABLE IF EXISTS vzd.nitis_k_materiali;

CREATE TABLE IF NOT EXISTS vzd.nitis_k_materiali (
  id serial PRIMARY KEY
  ,kods SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  );

INSERT INTO vzd.nitis_k_materiali (
  kods
  ,nosaukums
  )
VALUES (
  1
  ,'Dabiskie materiāli'
  )
  ,(
  11
  ,'Kokmateriāli'
  )
  ,(
  1101
  ,'Koka baļķi'
  )
  ,(
  1102
  ,'Koka brusas'
  )
  ,(
  1103
  ,'Koka dēļi'
  )
  ,(
  1104
  ,'Koka jumstiņi'
  )
  ,(
  1105
  ,'Koka karkasa konstrukcijas'
  )
  ,(
  1106
  ,'Koka sijas'
  )
  ,(
  1107
  ,'Koka skaidas (lubas)'
  )
  ,(
  1108
  ,'Koka spāres'
  )
  ,(
  1109
  ,'Koka stabi'
  )
  ,(
  1110
  ,'Koka vairogi'
  )
  ,(
  12
  ,'Būvakmeņi'
  )
  ,(
  1201
  ,'Dolomīts'
  )
  ,(
  1202
  ,'Granīts'
  )
  ,(
  1203
  ,'Laukakmens'
  )
  ,(
  1204
  ,'Kaļķakmens'
  )
  ,(
  1205
  ,'Marmors'
  )
  ,(
  1206
  ,'Šūnakmens'
  )
  ,(
  13
  ,'Pārējie dabiskie materiāli'
  )
  ,(
  1301
  ,'Niedres'
  )
  ,(
  1302
  ,'Salmi'
  )
  ,(
  1303
  ,'Slānekļa plātnes'
  )
  ,(
  1304
  ,'Smiltis'
  )
  ,(
  1305
  ,'Grants'
  )
  ,(
  2
  ,'Mākslīgie materiāli'
  )
  ,(
  21
  ,'Azbestcements'
  )
  ,(
  2101
  ,'Azbestcementa caurules'
  )
  ,(
  2102
  ,'Azbestcementa loksnes'
  )
  ,(
  2103
  ,'Azbestcementa paneļi'
  )
  ,(
  22
  ,'Betons'
  )
  ,(
  2201
  ,'Betona kārniņi'
  )
  ,(
  2202
  ,'Betona plātnes'
  )
  ,(
  2203
  ,'Betona bloki'
  )
  ,(
  2204
  ,'Monolītais betons'
  )
  ,(
  23
  ,'Dzelzsbetons'
  )
  ,(
  2301
  ,'Dzelzsbetona bloki'
  )
  ,(
  2302
  ,'Dzelzsbetona karkasa konstrukcijas'
  )
  ,(
  2303
  ,'Dzelzsbetona paneļi'
  )
  ,(
  2304
  ,'Dzelzsbetona pāļi'
  )
  ,(
  2305
  ,'Dzelzsbetona plātnes'
  )
  ,(
  2306
  ,'Dzelzsbetona sijas'
  )
  ,(
  2307
  ,'Monolītais dzelzsbetons'
  )
  ,(
  24
  ,'Elastīgie lokšņu materiāli'
  )
  ,(
  2401
  ,'Bitumena plātnes (šindeļi)'
  )
  ,(
  2402
  ,'Ruberoīds'
  )
  ,(
  25
  ,'Mastikas'
  )
  ,(
  2501
  ,'Mastikas nestiegrotie segumi'
  )
  ,(
  2502
  ,'Mastikas stiegrotie segumi'
  )
  ,(
  2503
  ,'Asfalts'
  )
  ,(
  2504
  ,'Asfaltbetons'
  )
  ,(
  2505
  ,'Ar bitumu apstrādāta grants'
  )
  ,(
  26
  ,'Metāli'
  )
  ,(
  2601
  ,'Skārda loksnes ar antikorozijas pārklājumu'
  )
  ,(
  2602
  ,'Skārda loksnes bez antikorozijas pārklājuma'
  )
  ,(
  2603
  ,'Metāla caurules'
  )
  ,(
  2604
  ,'Metāla dakstiņi'
  )
  ,(
  2605
  ,'Metāla karkasa konstrukcijas'
  )
  ,(
  2606
  ,'Metāla plātnes'
  )
  ,(
  2607
  ,'Metāla sijas'
  )
  ,(
  2608
  ,'Profilētā tērauda loksnes'
  )
  ,(
  27
  ,'Polimēri (plastmasa)'
  )
  ,(
  2701
  ,'Polimēru bloki'
  )
  ,(
  2702
  ,'Polimēru caurules'
  )
  ,(
  2703
  ,'Polimēru plātnes'
  )
  ,(
  2704
  ,'Polimēru plēve'
  )
  ,(
  28
  ,'Vieglbetoni'
  )
  ,(
  2801
  ,'Arbolīta bloki'
  )
  ,(
  2802
  ,'Gāzbetona bloki'
  )
  ,(
  2803
  ,'Gāzbetona paneļi'
  )
  ,(
  2804
  ,'Ģipšbetona bloki'
  )
  ,(
  2805
  ,'Ģipšbetona paneļi'
  )
  ,(
  2806
  ,'Izdedžbetona bloki'
  )
  ,(
  2807
  ,'Keramzītbetona bloki'
  )
  ,(
  2808
  ,'Keramzītbetona paneļi'
  )
  ,(
  2809
  ,'Māla kleķis'
  )
  ,(
  2810
  ,'Skaidbetons'
  )
  ,(
  29
  ,'Pārējie mākslīgie materiāli'
  )
  ,(
  2901
  ,'Fibrolīta plātnes'
  )
  ,(
  2902
  ,'Keramikas bloki'
  )
  ,(
  2903
  ,'Keramikas plātnes'
  )
  ,(
  2904
  ,'Kokšķiedru plātnes'
  )
  ,(
  2905
  ,'Māla kārniņi'
  )
  ,(
  2906
  ,'Minerālvates plātnes (stikla vates, akmens vates)'
  )
  ,(
  2907
  ,'Māla ķieģeļi'
  )
  ,(
  2908
  ,'Silikātķieģeļi'
  )
  ,(
  2909
  ,'Sintētisko materiālu audums'
  )
  ,(
  2910
  ,'Sintētisko materiālu loksnes'
  )
  ,(
  2911
  ,'Stikla konstrukcijas'
  )
  ,(
  2912
  ,'Šķiedrcementa loksnes'
  )
  ,(
  2913
  ,'Zaļo jumtu segums un augsnes kārta'
  )
  ,(
  2914
  ,'Cits neklasificēts materiāls'
  );

CREATE UNIQUE INDEX materiala_kods_idx ON vzd.nitis_k_materiali (kods);

COMMENT ON TABLE vzd.nitis_k_materiali IS 'Ēku konstruktīvo elementu materiālu klasifikators.';

COMMENT ON COLUMN vzd.nitis_k_materiali.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_k_materiali.kods IS 'Materiāla kods.';

COMMENT ON COLUMN vzd.nitis_k_materiali.nosaukums IS 'Materiāla nosaukums.';

GRANT SELECT, INSERT
  ON TABLE vzd.nitis_k_materiali
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_k_materiali_id_seq
  TO scheduler;

--B_KAD_APZ.
DROP TABLE IF EXISTS vzd.nitis_b_kad_apz;

CREATE TABLE IF NOT EXISTS vzd.nitis_b_kad_apz (
  id serial PRIMARY KEY
  ,darijuma_id INT NOT NULL
  ,kad_apz VARCHAR(14) NOT NULL
  ,skaititajs BIGINT NULL
  ,saucejs BIGINT NULL
  ,liet_veids SMALLINT NULL
  ,stavi SMALLINT NULL
  ,apbuves_laukums DECIMAL(7, 1) NULL
  ,kopplatiba DECIMAL(7, 1) NULL
  ,buvtilpums INT NULL
  ,ekspl_gads SMALLINT[] NULL
  ,arsienas SMALLINT[] NULL
  ,nolietojums SMALLINT NULL
  ,geom geometry
  ,atvk varchar(7)
  ,apkaime varchar(7)
  );

ALTER TABLE vzd.nitis_b_kad_apz ADD CONSTRAINT nitis_b_kad_apz_fk_liet_veids FOREIGN KEY (liet_veids) REFERENCES vzd.nitis_k_liet_veidi (kods);

CREATE INDEX nitis_b_kad_apz_geom_idx ON vzd.nitis_b_kad_apz USING GIST (geom);

COMMENT ON TABLE vzd.nitis_b_kad_apz IS 'Būvju kadastra objekti NĪTIS darījumos ar būvēm.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.darijuma_id IS 'Darījuma ID.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.kad_apz IS 'Kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.skaititajs IS 'Būves daļas skaitītājs.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.saucejs IS 'Būves daļas saucējs.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.liet_veids IS 'Būves lietošanas veida kods.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.stavi IS 'Būves virszemes stāvu skaits.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.apbuves_laukums IS 'Būves apbūves laukums, m².';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.kopplatiba IS 'Būves kopplatība, m².';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.buvtilpums IS 'Būves būvtilpums, m³.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.ekspl_gads IS 'Būves ekspluatācijas uzsākšanas gadi.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.arsienas IS 'Būves ārsienu materiālu kodi.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.nolietojums IS 'Būves fiziskais nolietojums, %.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.geom IS 'Ģeometrija.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.atvk IS 'ATVK.';

COMMENT ON COLUMN vzd.nitis_b_kad_apz.apkaime IS 'Apkaimes kods.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nitis_b_kad_apz
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_b_kad_apz_id_seq
  TO scheduler;

--TG_KAD_APZ.
DROP TABLE IF EXISTS vzd.nitis_tg_kad_apz;

CREATE TABLE IF NOT EXISTS vzd.nitis_tg_kad_apz (
  id serial PRIMARY KEY
  ,darijuma_id INT NOT NULL
  ,buves_kad_apz VARCHAR(14) NOT NULL
  ,kad_apz VARCHAR(17) NOT NULL
  ,skaititajs BIGINT NOT NULL
  ,saucejs BIGINT NOT NULL
  ,liet_veids SMALLINT NOT NULL
  ,stavs_min SMALLINT NULL
  ,stavs_max SMALLINT NULL
  ,platiba DECIMAL(6, 1) NOT NULL
  ,platiba_dz DECIMAL(6, 1) NULL
  ,telpas SMALLINT NULL
  ,istabas SMALLINT NULL
  ,geom geometry
  ,atvk varchar(7)
  ,apkaime varchar(7)
  );

ALTER TABLE vzd.nitis_tg_kad_apz ADD CONSTRAINT nitis_tg_kad_apz_fk_liet_veids FOREIGN KEY (liet_veids) REFERENCES vzd.nitis_k_liet_veidi (kods);

CREATE INDEX nitis_tg_kad_apz_geom_idx ON vzd.nitis_tg_kad_apz USING GIST (geom);

COMMENT ON TABLE vzd.nitis_tg_kad_apz IS 'Telpu grupu kadastra objekti NĪTIS darījumos.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.id IS 'ID.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.darijuma_id IS 'Darījuma ID.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.buves_kad_apz IS 'Būves kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.kad_apz IS 'Telpu grupas kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.skaititajs IS 'Telpu grupas daļas skaitītājs.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.saucejs IS 'Telpu grupas daļas saucējs.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.liet_veids IS 'Telpu grupas lietošanas veida kods.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.stavs_min IS 'Telpu grupas zemākais stāvs.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.stavs_max IS 'Telpu grupas augstākais stāvs.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.platiba IS 'Telpu grupas platība, m².';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.platiba_dz IS 'Dzīvokļa kopplatība, m².';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.telpas IS 'Telpu skaits telpu grupā.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.istabas IS 'Istabu skaits dzīvoklī.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.geom IS 'Ģeometrija.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.atvk IS 'ATVK.';

COMMENT ON COLUMN vzd.nitis_tg_kad_apz.apkaime IS 'Apkaimes kods.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nitis_tg_kad_apz
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nitis_tg_kad_apz_id_seq
  TO scheduler;