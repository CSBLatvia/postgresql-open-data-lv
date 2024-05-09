--Pievieno paplašinājumus datubāzē.
CREATE EXTENSION postgis;
CREATE EXTENSION ogr_fdw;

--Nosaka pieejas tiesības datubāzei.
GRANT ALL
  ON DATABASE spatial
  TO editor, basic_user;

GRANT CONNECT
  ON DATABASE spatial
  TO scheduler;

--Nosaka pieejas tiesības, kas drīkst izmantot ogr_fdw.
GRANT USAGE
  ON FOREIGN DATA WRAPPER ogr_fdw
  TO editor, basic_user;