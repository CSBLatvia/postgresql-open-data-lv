--Būves.
CREATE TABLE vzd.nivkis_buves (
  id SERIAL PRIMARY KEY
  ,code VARCHAR(14) NOT NULL
  ,object_code BIGINT NOT NULL
  ,parcel_code VARCHAR(11) NOT NULL
  ,geom geometry NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_buves IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie telpiskie dati par būvēm.';

COMMENT ON COLUMN vzd.nivkis_buves.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_buves.code IS 'Kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_buves.object_code IS 'Objekta kods (5201011110 – uzmērīta ēka, 5201011310 – vektorizēta ēka, 5201013110 – uzmērīta pazemes ēka, 5201013310 – vektorizēta pazemes ēka, 6211003100 – uzmērīta laukumveida inženierbūve, 6211003110 – vektorizēta laukumveida inženierbūve).';

COMMENT ON COLUMN vzd.nivkis_buves.parcel_code IS 'Galvenās zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_buves.geom IS 'Ģeometrija.';

COMMENT ON COLUMN vzd.nivkis_buves.date_created IS 'Izveidošanas datums. Atbilst lejupielādes datumam.';

COMMENT ON COLUMN vzd.nivkis_buves.date_deleted IS 'Dzēšanas datums. Atbilst vecākās datu kopas, kurā vairs nav objekta ar šādiem atribūtiem, lejupielādes datumam.';

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE vzd.nivkis_buves
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_buves_id_seq
  TO scheduler;

CREATE INDEX nivkis_buves_geom_idx ON vzd.nivkis_buves USING GIST (geom);

--Zemes vienības.
CREATE TABLE vzd.nivkis_zemes_vienibas (
  id SERIAL PRIMARY KEY
  ,code VARCHAR(11) NOT NULL
  ,geom_actual_date DATE NOT NULL
  ,object_code BIGINT NOT NULL
  ,geom geometry NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_zemes_vienibas IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie telpiskie dati par zemes vienībām.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibas.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibas.code IS 'Kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibas.geom_actual_date IS 'Objekta ģeometrijas aktualizācijas datums.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibas.object_code IS 'Objekta kods (7201060110 – uzmērīta zemes vienība, 7201060210 – ierādīta zemes vienība, 7201060310 – projektēta zemes vienība).';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibas.geom IS 'Ģeometrija.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibas.date_created IS 'Izveidošanas datums. Atbilst lejupielādes datumam.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibas.date_deleted IS 'Dzēšanas datums. Atbilst vecākās datu kopas, kurā vairs nav objekta ar šādiem atribūtiem, lejupielādes datumam.';

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE vzd.nivkis_zemes_vienibas
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_zemes_vienibas_id_seq
  TO scheduler;

CREATE INDEX nivkis_zemes_vienibas_geom_idx ON vzd.nivkis_zemes_vienibas USING GIST (geom);

--Zemes vienību daļas.
CREATE TABLE vzd.nivkis_zemes_vienibu_dalas (
  id SERIAL PRIMARY KEY
  ,code VARCHAR(15) NOT NULL
  ,parcel_code VARCHAR(11) NOT NULL
  ,geom geometry NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_zemes_vienibu_dalas IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie telpiskie dati par zemes vienību daļām.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibu_dalas.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibu_dalas.code IS 'Kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibu_dalas.parcel_code IS 'Zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibu_dalas.geom IS 'Ģeometrija.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibu_dalas.date_created IS 'Izveidošanas datums. Atbilst lejupielādes datumam.';

COMMENT ON COLUMN vzd.nivkis_zemes_vienibu_dalas.date_deleted IS 'Dzēšanas datums. Atbilst vecākās datu kopas, kurā vairs nav objekta ar šādiem atribūtiem, lejupielādes datumam.';

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE vzd.nivkis_zemes_vienibu_dalas
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_zemes_vienibu_dalas_id_seq
  TO scheduler;

CREATE INDEX nivkis_zemes_vienibu_dalas_geom_idx ON vzd.nivkis_zemes_vienibu_dalas USING GIST (geom);

--Apgrūtinājumu ceļa servitūtu teritorijas.
CREATE TABLE vzd.nivkis_servituti (
  id SERIAL PRIMARY KEY
  ,code VARCHAR(15) NOT NULL
  ,parcel_code VARCHAR(11) NOT NULL
  ,geom geometry NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_servituti IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie telpiskie dati par apgrūtinājumu ceļa servitūtu teritorijām.';

COMMENT ON COLUMN vzd.nivkis_servituti.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_servituti.code IS 'Servitūta identifikators (apgrūtinājuma kods + numurs pēc kārtas: 7315010100 – ēku servitūta teritorija, 7315020100 – ūdens lietošanas servitūta teritorija, 7315030100 – ceļa servitūta teritorija).';

COMMENT ON COLUMN vzd.nivkis_servituti.parcel_code IS 'Zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_servituti.geom IS 'Ģeometrija.';

COMMENT ON COLUMN vzd.nivkis_servituti.date_created IS 'Izveidošanas datums. Atbilst lejupielādes datumam.';

COMMENT ON COLUMN vzd.nivkis_servituti.date_deleted IS 'Dzēšanas datums. Atbilst vecākās datu kopas, kurā vairs nav objekta ar šādiem atribūtiem, lejupielādes datumam.';

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE vzd.nivkis_servituti
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_servituti_id_seq
  TO scheduler;

CREATE INDEX nivkis_servituti_geom_idx ON vzd.nivkis_servituti USING GIST (geom);
