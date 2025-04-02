CREATE OR REPLACE PROCEDURE vzd.adreses(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

--Tukša tabula pirmajai izpildes reizei.
CREATE TABLE IF NOT EXISTS vzd.adreses_ekas (
  id serial PRIMARY KEY
  ,adr_cd INT NOT NULL
  ,pnod_cd INT
  ,for_build BOOLEAN NOT NULL
  ,plan_adr BOOLEAN NOT NULL
  ,geom geometry(Point, 3059)
  );

--Pievieno dzēstās ēku adrešu koordinātas.
INSERT INTO vzd.adreses_ekas_koord_del (
  adr_cd
  ,geom
  )
SELECT a.adr_cd
  ,a.geom
FROM vzd.adreses_ekas a
INNER JOIN aw_csv.aw_eka b ON a.adr_cd = b.kods
WHERE a.geom IS NOT NULL
  AND b.koord_x IS NULL
  AND a.adr_cd NOT IN (
    SELECT adr_cd
    FROM vzd.adreses_ekas_koord_del
    );

--Aktuālās, kļūdainās un dzēstās adreses.
---Pamattabula ar adresācijas objektiem.
DROP TABLE IF EXISTS vzd.adreses CASCADE;

CREATE TABLE vzd.adreses (
  id serial PRIMARY KEY
  ,adr_cd INT NOT NULL
  ,tips_cd SMALLINT NOT NULL
  ,statuss CHAR(3) NOT NULL
  ,apstipr BOOLEAN
  ,apst_pak SMALLINT
  ,std TEXT
  ,vkur_cd INT NOT NULL
  ,vkur_tips SMALLINT NOT NULL
  ,nosaukums TEXT NOT NULL
  ,sort_nos TEXT NOT NULL
  ,atrib TEXT
  ,dat_sak DATE NOT NULL
  ,dat_mod DATE NOT NULL
  ,dat_beig DATE
  );

ALTER TABLE vzd.adreses ADD CONSTRAINT adreses_fk_apst_pak FOREIGN KEY (apst_pak) REFERENCES vzd.adreses_apst_pak (apst_pak);

ALTER TABLE vzd.adreses ADD CONSTRAINT adreses_fk_tips_cd FOREIGN KEY (tips_cd) REFERENCES vzd.adreses_tips (tips_cd);

COMMENT ON TABLE vzd.adreses IS 'Adresācijas objekti.';

COMMENT ON COLUMN vzd.adreses.id IS 'ID.';

COMMENT ON COLUMN vzd.adreses.adr_cd IS 'Adresācijas objekta kods.';

COMMENT ON COLUMN vzd.adreses.tips_cd IS 'Adresācijas objekta tipa kods.';

COMMENT ON COLUMN vzd.adreses.statuss IS 'Adresācijas objekta statuss (EKS – eksistējošs, DEL – likvidēts, ERR – kļūdains).';

COMMENT ON COLUMN vzd.adreses.apstipr IS 'Vai adresācijas objekts ir apstiprināts.';

COMMENT ON COLUMN vzd.adreses.apst_pak IS 'Adresācijas objekta apstiprinājuma pakāpes kods.';

COMMENT ON COLUMN vzd.adreses.std IS 'Adresācijas objekta pilnais adreses pieraksts.';

COMMENT ON COLUMN vzd.adreses.vkur_cd IS 'Tā adresācijas objekta kods, kuram hierarhiski pakļauts attiecīgais adresācijas objekts.';

COMMENT ON COLUMN vzd.adreses.vkur_tips IS 'Tā adresācijas objekta tipa kods, kuram hierarhiski pakļauts attiecīgais adresācijas objekts.';

COMMENT ON COLUMN vzd.adreses.nosaukums IS 'Adresācijas objekta aktuālais nosaukums.';

COMMENT ON COLUMN vzd.adreses.sort_nos IS 'Kārtošanas nosacījums adresācijas objekta nosaukumam (ja nosaukumā ir tikai teksts, kārtošanas nosacījums ir identisks nosaukumam).';

COMMENT ON COLUMN vzd.adreses.atrib IS 'Rajoniem, novadiem, pagastiem un pilsētām ATVK kods; ciemiem vērtība "1" norāda, ka objekts ir mazciems (ciems, kuram nav robeža); ēkām un apbūvei paredzētām zemes vienībām pasta indekss.';

COMMENT ON COLUMN vzd.adreses.dat_sak IS 'Adresācijas objekta izveidošanas vai pirmreizējās reģistrācijas datums, ja nav zināms precīzs adresācijas objekta izveides datums.';

COMMENT ON COLUMN vzd.adreses.dat_mod IS 'Datums, kad pēdējo reizi informācijas sistēmā tehniski modificēts ieraksts/dati par adresācijas objektu (piemēram, aktualizēts statuss, apstiprinājuma pakāpe, pievienots atribūts u.c.) vai mainīts pilnais adreses pieraksts.';

COMMENT ON COLUMN vzd.adreses.dat_beig IS 'Adresācijas objekta likvidācijas datums, ja adresācijas objekts beidza pastāvēt.';

---Dzīvokļi.
INSERT INTO vzd.adreses (
  adr_cd
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,std
  ,vkur_cd
  ,vkur_tips
  ,nosaukums
  ,sort_nos
  ,atrib
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,vkur_cd
  ,vkur_tips
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,TRIM(regexp_replace(sort_nos, '\s+', ' ', 'g'))
  ,atrib
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_dziv;

---Ēkas.
INSERT INTO vzd.adreses (
  adr_cd
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,std
  ,vkur_cd
  ,vkur_tips
  ,nosaukums
  ,sort_nos
  ,atrib
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,vkur_cd
  ,vkur_tips
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,TRIM(regexp_replace(sort_nos, '\s+', ' ', 'g'))
  ,atrib
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_eka;

---Ielas.
INSERT INTO vzd.adreses (
  adr_cd
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,std
  ,vkur_cd
  ,vkur_tips
  ,nosaukums
  ,sort_nos
  ,atrib
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,vkur_cd
  ,vkur_tips
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,TRIM(regexp_replace(sort_nos, '\s+', ' ', 'g'))
  ,atrib
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_iela;

---Ciemi.
INSERT INTO vzd.adreses (
  adr_cd
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,std
  ,vkur_cd
  ,vkur_tips
  ,nosaukums
  ,sort_nos
  ,atrib
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,vkur_cd
  ,vkur_tips
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,TRIM(regexp_replace(sort_nos, '\s+', ' ', 'g'))
  ,atrib
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_ciems;

---Pilsētas.
INSERT INTO vzd.adreses (
  adr_cd
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,std
  ,vkur_cd
  ,vkur_tips
  ,nosaukums
  ,sort_nos
  ,atrib
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,vkur_cd
  ,vkur_tips
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,TRIM(regexp_replace(sort_nos, '\s+', ' ', 'g'))
  ,atrib
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_pilseta;

---Pagasti.
INSERT INTO vzd.adreses (
  adr_cd
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,std
  ,vkur_cd
  ,vkur_tips
  ,nosaukums
  ,sort_nos
  ,atrib
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,vkur_cd
  ,vkur_tips
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,TRIM(regexp_replace(sort_nos, '\s+', ' ', 'g'))
  ,atrib
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_pagasts;

---Novadi.
INSERT INTO vzd.adreses (
  adr_cd
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,std
  ,vkur_cd
  ,vkur_tips
  ,nosaukums
  ,sort_nos
  ,atrib
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,vkur_cd
  ,vkur_tips
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,TRIM(regexp_replace(sort_nos, '\s+', ' ', 'g'))
  ,atrib
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_novads;

---Rajoni.
INSERT INTO vzd.adreses (
  adr_cd
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,std
  ,vkur_cd
  ,vkur_tips
  ,nosaukums
  ,sort_nos
  ,atrib
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,statuss
  ,apstipr
  ,apst_pak
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,vkur_cd
  ,vkur_tips
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,TRIM(regexp_replace(sort_nos, '\s+', ' ', 'g'))
  ,atrib
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_rajons;

---Rīgas priekšpilsētas.
DROP TABLE IF EXISTS vzd.adreses_pp;

CREATE TABLE vzd.adreses_pp (
  id serial PRIMARY KEY
  ,adr_cd INT NOT NULL
  ,ppils TEXT NOT NULL
  );

COMMENT ON TABLE vzd.adreses_pp IS 'Sasaiste starp ēku vai apbūvei paredzētu zemes vienību adresēm ar priekšpilsētām Rīgā.';

COMMENT ON COLUMN vzd.adreses_pp.id IS 'ID.';

COMMENT ON COLUMN vzd.adreses_pp.adr_cd IS 'Adresācijas objekta kods ēkai vai apbūvei paredzētai zemes vienībai.';

COMMENT ON COLUMN vzd.adreses_pp.ppils IS 'Priekšpilsētas nosaukums.';

INSERT INTO vzd.adreses_pp (
  adr_cd
  ,ppils
  )
SELECT kods
  ,TRIM(regexp_replace(ppils, '\s+', ' ', 'g'))
FROM aw_csv.aw_ppils;

---Papildus dati par ēkām.
DROP TABLE IF EXISTS vzd.adreses_ekas;

CREATE TABLE vzd.adreses_ekas (
  id serial PRIMARY KEY
  ,adr_cd INT NOT NULL
  ,pnod_cd INT
  ,for_build BOOLEAN NOT NULL
  ,plan_adr BOOLEAN NOT NULL
  ,geom geometry(Point, 3059)
  );

COMMENT ON TABLE vzd.adreses_ekas IS 'Papildus dati par ēku un apbūvei paredzētu zemes vienību adresācijas objektiem.';

COMMENT ON COLUMN vzd.adreses_ekas.id IS 'ID.';

COMMENT ON COLUMN vzd.adreses_ekas.adr_cd IS 'Adresācijas objekta kods.';

COMMENT ON COLUMN vzd.adreses_ekas.pnod_cd IS 'Pasta nodaļas apkalpes teritorijas kods.';

COMMENT ON COLUMN vzd.adreses_ekas.for_build IS 'Pazīme, ka adresācijas objekts ir apbūvei paredzēta zemes vienība (true – apbūvei paredzēta zemes vienība, false – ēka).';

COMMENT ON COLUMN vzd.adreses_ekas.plan_adr IS 'Pazīme, ka adrese ir plānota (true – plānotā adrese nav piesaistīta nevienam objektam Kadastra informācijas sistēmā, false – plānotā adrese ir piesaistīta nekustamā īpašuma objektam Kadastra informācijas sistēmā).';

COMMENT ON COLUMN vzd.adreses_ekas.geom IS 'Ģeometrija.';

INSERT INTO vzd.adreses_ekas (
  adr_cd
  ,pnod_cd
  ,for_build
  ,plan_adr
  ,geom
  )
SELECT kods
  ,pnod_cd
  ,for_build
  ,plan_adr
  ,ST_SetSRID(ST_MakePoint(koord_y, koord_x), 3059)
FROM aw_csv.aw_eka;

CREATE INDEX adreses_ekas_geom_idx ON vzd.adreses_ekas USING GIST (geom);

--Ēkas ar aktuālo adreses pierakstu, kas sadalīts pa laukiem. Par pamatu ņemts kods no https://github.com/laacz/vzd-importer.
DROP MATERIALIZED VIEW IF EXISTS vzd.adreses_ekas_sadalitas;

CREATE MATERIALIZED VIEW vzd.adreses_ekas_sadalitas
AS
SELECT a.adr_cd
  ,a.statuss
  ,a.nosaukums
  ,iela.nosaukums iela
  ,COALESCE(ciems.nosaukums, ciems_no_ielas.nosaukums) ciems
  ,COALESCE(pilseta.nosaukums, pilseta_no_ielas.nosaukums) pilseta
  ,COALESCE(pagasts.nosaukums, pagasts_no_ciema.nosaukums, pagasts_no_ciema_no_ielas.nosaukums) pagasts
  ,COALESCE(novads.nosaukums, novads_no_pagasta.nosaukums, novads_no_pagasta_no_ciema.nosaukums, novads_no_ciema.nosaukums, novads_no_pagasta_no_ciema_no_ielas.nosaukums, novads_no_pilsetas.nosaukums, novads_no_pilsetas_no_ielas.nosaukums) novads
  ,COALESCE(rajons_no_pagasta.nosaukums, rajons_no_pagasta_no_ciema.nosaukums, rajons_no_pagasta_no_ciema_no_ielas.nosaukums, rajons_no_pilsetas.nosaukums, rajons_no_pilsetas_no_ielas.nosaukums) rajons
  ,a.atrib
  ,a.std
  ,COALESCE(b.geom, c.geom) geom
FROM vzd.adreses a
LEFT JOIN vzd.adreses_ekas b ON a.adr_cd = b.adr_cd
LEFT JOIN vzd.adreses_ekas_koord_del c ON a.adr_cd = c.adr_cd
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 107
  ) iela ON iela.adr_cd = a.vkur_cd
---House is directly in a village.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 106
  ) ciems ON ciems.adr_cd = a.vkur_cd
---House is on a street in a village.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 106
  ) ciems_no_ielas ON ciems_no_ielas.adr_cd = iela.vkur_cd
---House is directly in a city.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 104
  ) pilseta ON pilseta.adr_cd = a.vkur_cd
---House is on a street in a city.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 104
  ) pilseta_no_ielas ON pilseta_no_ielas.adr_cd = iela.vkur_cd
---House is directly in a rural territory.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 105
  ) pagasts ON pagasts.adr_cd = a.vkur_cd
---House is directly in a village in a rural territory.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 105
  ) pagasts_no_ciema ON pagasts_no_ciema.adr_cd = ciems.vkur_cd
---House is on a street in a village in a rural territory.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 105
  ) pagasts_no_ciema_no_ielas ON pagasts_no_ciema_no_ielas.adr_cd = ciems_no_ielas.vkur_cd
---House is directly in a municipality. Deleted (historical) data only.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 113
  ) novads ON novads.adr_cd = a.vkur_cd
---House in in a rural territory in a municipality.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 113
  ) novads_no_pagasta ON novads_no_pagasta.adr_cd = pagasts.vkur_cd
---House is in a village in a rural territory in a municipality.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 113
  ) novads_no_pagasta_no_ciema ON novads_no_pagasta_no_ciema.adr_cd = pagasts_no_ciema.vkur_cd
---House is in a village in a municipality. Deleted (historical) data only.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 113
  ) novads_no_ciema ON novads_no_ciema.adr_cd = ciems.vkur_cd
---House is on a street in a village in a rural territory in a municipality.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 113
  ) novads_no_pagasta_no_ciema_no_ielas ON novads_no_pagasta_no_ciema_no_ielas.adr_cd = pagasts_no_ciema_no_ielas.vkur_cd
---House is directly in a town in a municipality.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 113
  ) novads_no_pilsetas ON novads_no_pilsetas.adr_cd = pilseta.vkur_cd
---House is on a street in a town in a municipality.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 113
  ) novads_no_pilsetas_no_ielas ON novads_no_pilsetas_no_ielas.adr_cd = pilseta_no_ielas.vkur_cd
---House in in a rural territory in a district. Deleted (historical) data only.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 102
  ) rajons_no_pagasta ON rajons_no_pagasta.adr_cd = pagasts.vkur_cd
---House is in a village in a rural territory in a district. Deleted (historical) data only.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 102
  ) rajons_no_pagasta_no_ciema ON rajons_no_pagasta_no_ciema.adr_cd = pagasts_no_ciema.vkur_cd
---House is on a street in a village in a rural territory in a district. Deleted (historical) data only.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 102
  ) rajons_no_pagasta_no_ciema_no_ielas ON rajons_no_pagasta_no_ciema_no_ielas.adr_cd = pagasts_no_ciema_no_ielas.vkur_cd
---House is directly in a town in a district. Deleted (historical) data only.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 102
  ) rajons_no_pilsetas ON rajons_no_pilsetas.adr_cd = pilseta.vkur_cd
---House is on a street in a town in a district. Deleted (historical) data only.
LEFT JOIN (
  SELECT *
  FROM vzd.adreses
  WHERE tips_cd = 102
  ) rajons_no_pilsetas_no_ielas ON rajons_no_pilsetas_no_ielas.adr_cd = pilseta_no_ielas.vkur_cd
WHERE a.tips_cd = 108;

COMMENT ON MATERIALIZED VIEW vzd.adreses_ekas_sadalitas IS 'Ēku un apbūvei paredzēto zemes vienību adresācijas objekti ar aktuālo adreses pierakstu, kas sadalīts pa laukiem.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.adr_cd IS 'Adresācijas objekta kods.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.statuss IS 'Adresācijas objekta statuss (EKS – eksistējošs, DEL – likvidēts, ERR – kļūdains).';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.nosaukums IS 'Ēkas Nr. vai nosaukums.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.iela IS 'Ielas nosaukums.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.ciems IS 'Ciema/mazciema nosaukums.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.pilseta IS 'Pilsētas nosaukums.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.pagasts IS 'Pagasta nosaukums.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.novads IS 'Novada nosaukums.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.rajons IS 'Rajona nosaukums.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.atrib IS 'Pasta indekss.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.std IS 'Adresācijas objekta pilnais adreses pieraksts.';

COMMENT ON COLUMN vzd.adreses_ekas_sadalitas.geom IS 'Ģeometrija.';

CREATE UNIQUE INDEX ON vzd.adreses_ekas_sadalitas (adr_cd);

CREATE INDEX adreses_ekas_sadalitas_geom_idx ON vzd.adreses_ekas_sadalitas USING GIST (geom);

--Adrešu vēsturiskie pieraksti.
---Dzīvokļi.
INSERT INTO vzd.adreses_his (
  adr_cd
  ,tips_cd
  ,std
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_dziv_his
WHERE dat_mod::DATE > (
    SELECT COALESCE(MAX(dat_mod), '1900-01-01')
    FROM vzd.adreses_his
    WHERE tips_cd = 109
    );

---Ēkas.
INSERT INTO vzd.adreses_his (
  adr_cd
  ,adr_cd_his
  ,tips_cd
  ,std
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,kods_his
  ,tips_cd
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'))
  ,vkur_cd
  ,vkur_tips
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_eka_his
WHERE dat_mod::DATE > (
    SELECT COALESCE(MAX(dat_mod), '1900-01-01')
    FROM vzd.adreses_his
    WHERE tips_cd = 108
    );

---Ielas.
INSERT INTO vzd.adreses_his (
  adr_cd
  ,tips_cd
  ,std
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_iela_his
WHERE dat_mod::DATE > (
    SELECT COALESCE(MAX(dat_mod), '1900-01-01')
    FROM vzd.adreses_his
    WHERE tips_cd = 107
    );

---Ciemi.
INSERT INTO vzd.adreses_his (
  adr_cd
  ,tips_cd
  ,std
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_ciems_his
WHERE dat_mod::DATE > (
    SELECT COALESCE(MAX(dat_mod), '1900-01-01')
    FROM vzd.adreses_his
    WHERE tips_cd = 106
    );

---Pilsētas.
INSERT INTO vzd.adreses_his (
  adr_cd
  ,tips_cd
  ,std
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_pilseta_his
WHERE dat_mod::DATE > (
    SELECT COALESCE(MAX(dat_mod), '1900-01-01')
    FROM vzd.adreses_his
    WHERE tips_cd = 104
    );

---Pagasti.
INSERT INTO vzd.adreses_his (
  adr_cd
  ,tips_cd
  ,std
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_pagasts_his
WHERE dat_mod::DATE > (
    SELECT COALESCE(MAX(dat_mod), '1900-01-01')
    FROM vzd.adreses_his
    WHERE tips_cd = 105
    );

---Novadi.
INSERT INTO vzd.adreses_his (
  adr_cd
  ,tips_cd
  ,std
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak
  ,dat_mod
  ,dat_beig
  )
SELECT kods
  ,tips_cd
  ,TRIM(regexp_replace(std, '\s+', ' ', 'g'))
  ,nosaukums
  ,vkur_cd
  ,vkur_tips
  ,dat_sak::DATE
  ,dat_mod::DATE
  ,dat_beig::DATE
FROM aw_csv.aw_novads_his
WHERE dat_mod::DATE > (
    SELECT COALESCE(MAX(dat_mod), '1900-01-01')
    FROM vzd.adreses_his
    WHERE tips_cd = 113
    );

DELETE
FROM vzd.adreses_his
WHERE adr_cd = adr_cd_his;

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.adreses() TO scheduler;
