--lauku bloki.
DROP TABLE IF EXISTS lad.field_blocks;

CREATE TABLE lad.field_blocks (
  id SERIAL PRIMARY KEY
  ,block_number VARCHAR(11) NOT NULL
  ,mla VARCHAR(5)
  ,valid_from TIMESTAMP
  ,geom geometry(MultiPolygon, 3059) NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE
  );

GRANT SELECT, INSERT, UPDATE
  ON TABLE lad.field_blocks
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE lad.field_blocks_id_seq
  TO scheduler;

CREATE INDEX field_blocks_idx ON lad.field_blocks (block_number);

CREATE INDEX field_blocks_geom_idx ON lad.field_blocks USING GIST (geom);

--Produktu kodi.
DROP TABLE IF EXISTS lad.products;

CREATE TABLE lad.products (
  id SERIAL PRIMARY KEY
  ,product_code SMALLINT
  ,product_description VARCHAR
  );

GRANT SELECT, INSERT, UPDATE
  ON TABLE lad.products
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE lad.products_id_seq
  TO scheduler;

CREATE UNIQUE INDEX products_idx ON lad.products (product_code);

--Lauki.
DROP TABLE IF EXISTS lad.fields;

CREATE TABLE lad.fields (
  id SERIAL PRIMARY KEY
  ,parcel_id INTEGER NOT NULL
  ,period_code SMALLINT NOT NULL
  ,product_code SMALLINT NOT NULL
  ,aid_forms VARCHAR NOT NULL
  ,area_declared REAL NOT NULL
  ,data_changed_date TIMESTAMP NOT NULL
  ,geom geometry(MultiPolygon, 3059) NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE
);

GRANT SELECT, INSERT, UPDATE
  ON TABLE lad.fields
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE lad.fields_id_seq
  TO scheduler;

CREATE INDEX fields_geom_idx ON lad.fields USING GIST (geom);

CREATE INDEX fields_idx ON lad.fields (parcel_id);

ALTER TABLE lad.fields ADD CONSTRAINT fields_fk_product_code FOREIGN KEY (product_code) REFERENCES lad.products (product_code);