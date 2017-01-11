/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



-- Role: "Administrator"
-- DROP ROLE "Administrator";

CREATE ROLE "Administrator" WITH
  NOLOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION;

COMMENT ON ROLE "Administrator" IS 'Admin  user type of Noisy_Parrot database.';

-- Role: "Auditioner"
-- DROP ROLE "Auditioner";

CREATE ROLE "Auditioner" WITH
  NOLOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION;

COMMENT ON ROLE "Auditioner" IS 'Auditioner user type of Noisy_Parrot database.';

-- Role: "Radio_Producer"
-- DROP ROLE "Radio_Producer";

CREATE ROLE "Radio_Producer" WITH
  NOLOGIN
  NOSUPERUSER
  INHERIT
  NOCREATEDB
  NOCREATEROLE
  NOREPLICATION;

COMMENT ON ROLE "Radio_Producer" IS 'Radio producer user type of Noisy_Parrot database.';
