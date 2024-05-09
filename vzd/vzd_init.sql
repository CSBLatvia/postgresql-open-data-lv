DROP TABLE IF EXISTS vzd.ciemi;

CREATE TABLE vzd.ciemi (
  id SERIAL PRIMARY KEY
  ,code INTEGER NOT NULL
  ,code_version SMALLINT NOT NULL
  ,name VARCHAR(25) NOT NULL
  ,geom geometry(MultiPolygon, 3059) NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.ciemi IS 'Valsts adrešu reģistra informācijas sistēmas atvērtie telpiskie dati par ciemiem.';

COMMENT ON COLUMN vzd.ciemi.id IS 'ID.';

COMMENT ON COLUMN vzd.ciemi.code IS 'Adresācijas objekta kods.';

COMMENT ON COLUMN vzd.ciemi.code_version IS 'Adresācijas objekta koda versija.';

COMMENT ON COLUMN vzd.ciemi.name IS 'Nosaukums.';

COMMENT ON COLUMN vzd.ciemi.geom IS 'Ģeometrija.';

COMMENT ON COLUMN vzd.ciemi.date_created IS 'Izveidošanas datums. Atbilst lejupielādes datumam.';

COMMENT ON COLUMN vzd.ciemi.date_deleted IS 'Dzēšanas datums. Atbilst vecākās datu kopas, kurā vairs nav objekta ar šādiem atribūtiem, lejupielādes datumam.';

GRANT ALL
  ON TABLE vzd.ciemi
  TO editor;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE vzd.ciemi
  TO scheduler;

GRANT ALL
  ON SEQUENCE vzd.ciemi_id_seq
  TO editor;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.ciemi_id_seq
  TO scheduler;

CREATE INDEX ciemi_geom_idx ON vzd.ciemi USING GIST (geom);