--Loma lietotājiem ar rediģēšanas tiesībām.
DROP ROLE IF EXISTS editor;

CREATE ROLE editor
  WITH NOLOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT pg_signal_backend TO editor;

--Loma lietotājiem tikai ar lasīšanas tiesībām, kā arī tiesībām veidot jaunus objektus datubāzē.
DROP ROLE IF EXISTS basic_user;

CREATE ROLE basic_user
  WITH NOLOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

--Lietotājs cron darbu izpildei.
DROP USER IF EXISTS scheduler;

CREATE USER scheduler
  WITH PASSWORD 'password' LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;