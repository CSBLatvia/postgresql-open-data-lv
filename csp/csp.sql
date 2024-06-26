DROP SCHEMA IF EXISTS csp CASCADE;

CREATE SCHEMA IF NOT EXISTS csp;

ALTER SCHEMA csp OWNER TO editor;

GRANT USAGE
  ON SCHEMA csp
  TO basic_user
    ,scheduler;

ALTER DEFAULT PRIVILEGES
FOR ROLE editor
IN SCHEMA csp
GRANT SELECT ON TABLES TO basic_user;

ALTER DEFAULT PRIVILEGES
FOR ROLE editor
IN SCHEMA csp
GRANT SELECT ON SEQUENCES TO basic_user;