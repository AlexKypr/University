/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



-- View: public."ListenerContestView"

-- DROP VIEW public."ListenerContestView";

CREATE OR REPLACE VIEW public."ListenerContestView" AS
 SELECT "Listener".name AS ln,
    "Contest".name AS cn,
    "Contest".starting_date AS cs,
    "Contest".ending_date AS ce,
    "Contest".ending_time AS cet,
    "Contest".gift AS cg
   FROM "Listener"
     JOIN "Listener-Contest" ON "Listener".phone_number::text = "Listener-Contest".phone_number::text
     JOIN "Contest" ON "Contest".unique_id = "Listener-Contest".unique_id;

ALTER TABLE public."ListenerContestView"
    OWNER TO postgres;

    -- View: public."PlayListView"

    -- DROP VIEW public."PlayListView";

    CREATE OR REPLACE VIEW public."PlayListView" AS
     SELECT "RadioShowProducer".name AS rspname,
        "RadioShow".name AS rsname,
        "Song".title AS st,
        "Song".album AS sa,
        "Song".artist AS sar
       FROM "RadioShowProducer"
         JOIN "RadioShow-RadioShowProducer" ON "RadioShowProducer".nickname::text = "RadioShow-RadioShowProducer".nickname::text
         JOIN "RadioShow" ON "RadioShow".name::text = "RadioShow-RadioShowProducer".name::text
         JOIN "Song-RadioShow" ON "Song-RadioShow".name::text = "RadioShow".name::text
         JOIN "Song" ON "Song".title::text = "Song-RadioShow".title::text AND "Song".release_year = "Song-RadioShow".release_year AND "Song-RadioShow".artist::text = "Song".artist::text;

    ALTER TABLE public."PlayListView"
        OWNER TO postgres;
