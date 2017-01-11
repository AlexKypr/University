/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: Noisy_Parrot; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "Noisy_Parrot" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'C';


ALTER DATABASE "Noisy_Parrot" OWNER TO postgres;

\connect "Noisy_Parrot"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Advertisement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Advertisement" (
    company_name character varying(70) NOT NULL,
    duration integer NOT NULL,
    time_per_show integer NOT NULL,
    phone_number character varying(40) NOT NULL,
    email_address character varying(2044),
    file_path character varying(255) NOT NULL,
    CONSTRAINT "CK_email_address" CHECK (((email_address)::text !~ '^\S+@\S+$ '::text)),
    CONSTRAINT "CK_phone_number" CHECK (((phone_number)::text ~ '^[0-9]+$'::text))
);


ALTER TABLE "Advertisement" OWNER TO postgres;

--
-- Name: Advertisement-RadioShow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Advertisement-RadioShow" (
    company_name character varying(70) NOT NULL,
    name character varying(70) NOT NULL
);


ALTER TABLE "Advertisement-RadioShow" OWNER TO postgres;

--
-- Name: Contest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Contest" (
    unique_id integer NOT NULL,
    name character varying(70) NOT NULL,
    starting_date date NOT NULL,
    ending_date date NOT NULL,
    ending_time time without time zone NOT NULL,
    gift character varying(255) NOT NULL,
    CONSTRAINT "CK_ending_date" CHECK ((ending_date > starting_date))
);


ALTER TABLE "Contest" OWNER TO postgres;

--
-- Name: Days; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Days" (
    name character varying(70) NOT NULL,
    days character varying(60) NOT NULL,
    CONSTRAINT "CK_days" CHECK (((days)::text ~ '(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)'::text))
);


ALTER TABLE "Days" OWNER TO postgres;

--
-- Name: Event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Event" (
    name character varying(70) NOT NULL,
    nickname character varying(20) NOT NULL,
    date date NOT NULL,
    "time" time without time zone NOT NULL,
    location character varying(50) NOT NULL,
    info character varying(2044) NOT NULL,
    CONSTRAINT "CK_info" CHECK (true)
);


ALTER TABLE "Event" OWNER TO postgres;

--
-- Name: Listener; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Listener" (
    phone_number character varying(42) NOT NULL,
    name character varying(70),
    CONSTRAINT "CK_name" CHECK (((name)::text !~ '/^[a-zA-Z\s]*$/'::text)),
    CONSTRAINT "CK_phone_number" CHECK (((phone_number)::text ~ '^[0-9]+$'::text))
);


ALTER TABLE "Listener" OWNER TO postgres;

--
-- Name: Listener-Contest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Listener-Contest" (
    phone_number character varying(42) NOT NULL,
    unique_id integer NOT NULL,
    CONSTRAINT "CK_phone_number" CHECK (((phone_number)::text ~ '^[0-9]+$'::text))
);


ALTER TABLE "Listener-Contest" OWNER TO postgres;

--
-- Name: Listener-RadioShow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Listener-RadioShow" (
    phone_number character varying(42) NOT NULL,
    name character varying(70) NOT NULL,
    context character varying(2044),
    CONSTRAINT "CK_context" CHECK (true),
    CONSTRAINT "CK_phone_number" CHECK (((phone_number)::text ~ '^[0-9]+$'::text))
);


ALTER TABLE "Listener-RadioShow" OWNER TO postgres;

--
-- Name: RadioShow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "RadioShow" (
    name character varying(70) NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    theme character varying(50) NOT NULL,
    duration time without time zone,
    CONSTRAINT "CK_end_time" CHECK ((end_time > start_time))
);


ALTER TABLE "RadioShow" OWNER TO postgres;

--
-- Name: RadioShow-RadioShowProducer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "RadioShow-RadioShowProducer" (
    name character varying(70) NOT NULL,
    nickname character varying(70) NOT NULL
);


ALTER TABLE "RadioShow-RadioShowProducer" OWNER TO postgres;

--
-- Name: RadioShowProducer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "RadioShowProducer" (
    nickname character varying(20) NOT NULL,
    name character varying(70) NOT NULL,
    phone_number character varying(40),
    email_address character varying(320),
    CONSTRAINT "CK_email_address" CHECK (((email_address)::text !~ '^\S+@\S+$ '::text)),
    CONSTRAINT "CK_name" CHECK (((name)::text !~ '/^[a-zA-Z\s]*$/'::text)),
    CONSTRAINT "CK_phone_number" CHECK (((phone_number)::text ~ '^[0-9]+$'::text))
);


ALTER TABLE "RadioShowProducer" OWNER TO postgres;

--
-- Name: Song; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Song" (
    title character varying(50) NOT NULL,
    genre character varying(50) NOT NULL,
    album character varying(50),
    release_year smallint NOT NULL,
    artist character varying(70) NOT NULL,
    file_path character varying(255) NOT NULL,
    CONSTRAINT "CK_genre" CHECK (((genre)::text ~ '(Pop|Rock|Metal|Punk|Blues|Classical|Hip-Hop|Jazz|Opera|Rap|Reggae|R&B|Country|Swing|Alternative|Electro|House)'::text)),
    CONSTRAINT "CK_release_year" CHECK (((release_year)::text ~ '^[0-9]'::text))
);


ALTER TABLE "Song" OWNER TO postgres;

--
-- Name: Song-RadioShow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Song-RadioShow" (
    title character varying(50) NOT NULL,
    release_year smallint NOT NULL,
    artist character varying(70) NOT NULL,
    name character varying(70) NOT NULL,
    CONSTRAINT "CK_release_year" CHECK (((release_year)::text ~ '^[0-9]'::text))
);


ALTER TABLE "Song-RadioShow" OWNER TO postgres;

--
-- Data for Name: Advertisement; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Advertisement" (company_name, duration, time_per_show, phone_number, email_address, file_path) VALUES ('Kanelopoulos', 60, 1, '23106987784', 'kanelopoulos@gmail.com', 'C://ads/ad5.wav
');
INSERT INTO "Advertisement" (company_name, duration, time_per_show, phone_number, email_address, file_path) VALUES ('Masoutis', 45, 2, '21048963324', 'info@masoutis.gr', 'C://ads/ad3.wav
');
INSERT INTO "Advertisement" (company_name, duration, time_per_show, phone_number, email_address, file_path) VALUES ('Skip', 60, 1, '21069985638', 'skipgr@skip.gr', 'C://ads/ad1.wav
');
INSERT INTO "Advertisement" (company_name, duration, time_per_show, phone_number, email_address, file_path) VALUES ('Toyotomi', 45, 1, '21048856675', 'info@toyotomi.gr', 'C://ads/ad4.wav
');
INSERT INTO "Advertisement" (company_name, duration, time_per_show, phone_number, email_address, file_path) VALUES ('Fairy', 30, 2, '21098778264', 'fairy@fairy.gr', 'C://ads/ad6.wav
');
INSERT INTO "Advertisement" (company_name, duration, time_per_show, phone_number, email_address, file_path) VALUES ('Carglass', 60, 1, '21069785266', 'carglass@gmail.com', 'C://ads/ad2.wav
');


--
-- Data for Name: Advertisement-RadioShow; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Advertisement-RadioShow" (company_name, name) VALUES ('Skip', 'BreakfastClub');
INSERT INTO "Advertisement-RadioShow" (company_name, name) VALUES ('Carglass', 'Μαρμίτα');
INSERT INTO "Advertisement-RadioShow" (company_name, name) VALUES ('Masoutis', 'Non-stop');
INSERT INTO "Advertisement-RadioShow" (company_name, name) VALUES ('Toyotomi', 'FAN-club');
INSERT INTO "Advertisement-RadioShow" (company_name, name) VALUES ('Kanelopoulos', 'Ειδήσεις');
INSERT INTO "Advertisement-RadioShow" (company_name, name) VALUES ('Fairy', 'Κοσμοεπιτυχίες');


--
-- Data for Name: Contest; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Contest" (unique_id, name, starting_date, ending_date, ending_time, gift) VALUES (78, 'MLS Contest
', '2016-07-22', '2016-07-29', '24:00:00', 'Δωροεπιταγή 200 ευρώ
');
INSERT INTO "Contest" (unique_id, name, starting_date, ending_date, ending_time, gift) VALUES (1548, 'Giveaway', '2016-10-14', '2016-11-14', '24:00:00', 'iPhone 7');
INSERT INTO "Contest" (unique_id, name, starting_date, ending_date, ending_time, gift) VALUES (1425, 'Beautify', '2015-01-01', '2015-02-01', '24:00:00', 'Αποτρίχωση');
INSERT INTO "Contest" (unique_id, name, starting_date, ending_date, ending_time, gift) VALUES (1123, 'Yummy Contest', '2016-05-15', '2016-06-15', '12:00:00', 'Παγωτομηχανή');
INSERT INTO "Contest" (unique_id, name, starting_date, ending_date, ending_time, gift) VALUES (2265, 'Xmas Contest', '2015-12-01', '2015-12-31', '23:59:00', 'Ταξίδι στη Λαπωνία');
INSERT INTO "Contest" (unique_id, name, starting_date, ending_date, ending_time, gift) VALUES (85, 'Carnival', '2016-02-23', '2016-03-23', '12:00:00', 'Εισητήρια για Ρίο Ντε Τζανέιρο
');
INSERT INTO "Contest" (unique_id, name, starting_date, ending_date, ending_time, gift) VALUES (1488, 'HappyHour', '2016-01-15', '2016-01-16', '24:00:00', 'Δωροεπιταγή 200 ευρώ
');
INSERT INTO "Contest" (unique_id, name, starting_date, ending_date, ending_time, gift) VALUES (9656, 'Pet Contest', '2016-10-28', '2016-11-17', '20:00:00', 'Σκυλοτροφή');


--
-- Data for Name: Days; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Days" (name, days) VALUES ('Μαρμίτα', 'Monday');
INSERT INTO "Days" (name, days) VALUES ('Μαρμίτα', 'Tuesday');
INSERT INTO "Days" (name, days) VALUES ('Μαρμίτα', 'Thursday');
INSERT INTO "Days" (name, days) VALUES ('Κοσμοεπιτυχίες', 'Wednesday');
INSERT INTO "Days" (name, days) VALUES ('GossipGirls', 'Sunday');
INSERT INTO "Days" (name, days) VALUES ('FAN-club', 'Sunday');
INSERT INTO "Days" (name, days) VALUES ('FAN-club', 'Saturday');
INSERT INTO "Days" (name, days) VALUES ('Ειδήσεις', 'Saturday');
INSERT INTO "Days" (name, days) VALUES ('Ειδήσεις', 'Sunday');


--
-- Data for Name: Event; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Event" (name, nickname, date, "time", location, info) VALUES ('GlamorousNights
', 'Mr.Bombastic', '2016-07-22', '22:00:00', 'Regency Casino
', 'Gala');
INSERT INTO "Event" (name, nickname, date, "time", location, info) VALUES ('ForTheKids', 'Big bad wolf', '2016-10-14', '22:00:00', 'Regency Casino
', 'Charity');
INSERT INTO "Event" (name, nickname, date, "time", location, info) VALUES ('MadVMAwards', 'Starlet', '2016-10-18', '21:00:00', 'I.Vellidis Hall', 'RadioAwards');
INSERT INTO "Event" (name, nickname, date, "time", location, info) VALUES ('BreakThePoverty', 'KityKat', '2016-01-15', '20:00:00', 'I.Vellidis Hall', 'Charity');
INSERT INTO "Event" (name, nickname, date, "time", location, info) VALUES ('IceBucketMEETUP', 'Princess', '2015-01-01', '20:00:00', 'Apothiki G, SKG
', 'Charity');
INSERT INTO "Event" (name, nickname, date, "time", location, info) VALUES ('SportsAwards', 'Ραπ', '2015-08-06', '21:00:00', 'Apothiki G, SKG
', 'RadioAwards');


--
-- Data for Name: Listener; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Listener" (phone_number, name) VALUES ('6978856954', 'Βασιλειάδης Άγγελος
');
INSERT INTO "Listener" (phone_number, name) VALUES ('6978536552', 'Κυπριανίδης Αλέξανδρος
');
INSERT INTO "Listener" (phone_number, name) VALUES ('6984565523', 'Σιδερίδης Βασίλης
');
INSERT INTO "Listener" (phone_number, name) VALUES ('6978859866', 'Μάστορας Ραφαήλ');
INSERT INTO "Listener" (phone_number, name) VALUES ('6945685789', 'Οικονόμου Ναπολέων ');
INSERT INTO "Listener" (phone_number, name) VALUES ('6988852639', 'Μητσέας Πέτρος');
INSERT INTO "Listener" (phone_number, name) VALUES ('6975837475', 'Μπαζούκη Ευαγγελία
');


--
-- Data for Name: Listener-Contest; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Listener-Contest" (phone_number, unique_id) VALUES ('6978856954', 78);
INSERT INTO "Listener-Contest" (phone_number, unique_id) VALUES ('6978536552', 1548);
INSERT INTO "Listener-Contest" (phone_number, unique_id) VALUES ('6945685789', 1123);
INSERT INTO "Listener-Contest" (phone_number, unique_id) VALUES ('6988852639', 1488);
INSERT INTO "Listener-Contest" (phone_number, unique_id) VALUES ('6984565523', 1425);
INSERT INTO "Listener-Contest" (phone_number, unique_id) VALUES ('6975837475', 85);
INSERT INTO "Listener-Contest" (phone_number, unique_id) VALUES ('6978859866', 2265);


--
-- Data for Name: Listener-RadioShow; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Listener-RadioShow" (phone_number, name, context) VALUES ('6978856954', 'BreakfastClub', '«Καλησπέρα»');
INSERT INTO "Listener-RadioShow" (phone_number, name, context) VALUES ('6978536552', 'Μαρμίτα', '«Τι θα κάνει ο γαύρος σήμερα;»');
INSERT INTO "Listener-RadioShow" (phone_number, name, context) VALUES ('6945685789', 'Non-stop', '«Πολλά φιλιά από Πάτρα»');
INSERT INTO "Listener-RadioShow" (phone_number, name, context) VALUES ('6988852639', 'FAN-club', '«Αφιερωμένο!!!»');
INSERT INTO "Listener-RadioShow" (phone_number, name, context) VALUES ('6984565523', 'Ειδήσεις', '«Παραπληροφόρηση είστε κύριοι!»');
INSERT INTO "Listener-RadioShow" (phone_number, name, context) VALUES ('6975837475', 'Κοσμοεπιτυχίες', '«Ο καλύτερος σταθμός της πόλης!»');
INSERT INTO "Listener-RadioShow" (phone_number, name, context) VALUES ('6978859866', 'GossipGirls', '«Τελικά η Σκορδά χώρισε;»');


--
-- Data for Name: RadioShow; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "RadioShow" (name, start_time, end_time, theme, duration) VALUES ('Non-stop', '14:00:00', '17:00:00', 'Μουσική', '03:00:00');
INSERT INTO "RadioShow" (name, start_time, end_time, theme, duration) VALUES ('FAN-club', '18:00:00', '20:00:00', 'Μουσική', '02:00:00');
INSERT INTO "RadioShow" (name, start_time, end_time, theme, duration) VALUES ('GossipGirls', '10:00:00', '12:00:00', 'Gossip', '02:00:00');
INSERT INTO "RadioShow" (name, start_time, end_time, theme, duration) VALUES ('BreakfastClub', '06:00:00', '10:00:00', 'Διασκέδαση', '04:00:00');
INSERT INTO "RadioShow" (name, start_time, end_time, theme, duration) VALUES ('RadioMadness', '20:00:00', '23:00:00', 'Μουσική', '03:00:00');
INSERT INTO "RadioShow" (name, start_time, end_time, theme, duration) VALUES ('Κοσμοεπιτυχίες', '17:00:00', '18:00:00', 'Μουσική', '01:00:00');
INSERT INTO "RadioShow" (name, start_time, end_time, theme, duration) VALUES ('Μαρμίτα', '22:00:00', '24:00:00', 'Αθλητικά', '02:00:00');
INSERT INTO "RadioShow" (name, start_time, end_time, theme, duration) VALUES ('Ειδήσεις', '12:00:00', '14:00:00', 'Ενημέρωση', '02:00:00');


--
-- Data for Name: RadioShow-RadioShowProducer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "RadioShow-RadioShowProducer" (name, nickname) VALUES ('BreakfastClub', 'Mr.Bombastic');
INSERT INTO "RadioShow-RadioShowProducer" (name, nickname) VALUES ('Non-stop', 'Starlet');
INSERT INTO "RadioShow-RadioShowProducer" (name, nickname) VALUES ('FAN-club', 'KityKat');
INSERT INTO "RadioShow-RadioShowProducer" (name, nickname) VALUES ('Ειδήσεις', 'Princess');
INSERT INTO "RadioShow-RadioShowProducer" (name, nickname) VALUES ('GossipGirls', 'The big boss');
INSERT INTO "RadioShow-RadioShowProducer" (name, nickname) VALUES ('Μαρμίτα', 'Ραπ');
INSERT INTO "RadioShow-RadioShowProducer" (name, nickname) VALUES ('Κοσμοεπιτυχίες', 'Big bad wolf');
INSERT INTO "RadioShow-RadioShowProducer" (name, nickname) VALUES ('Μαρμίτα', 'Κόκκινος');


--
-- Data for Name: RadioShowProducer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('Τίγρης', 'Νίκος Μάρκογλου', '6978856954', 'nikosmarkoglou@gmail.com');
INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('Σούπερμαν', 'Νίκος Χαλκούσης', '6978536552', 'nikosxalk@gmail.com');
INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('Mr.Bombastic', 'Γρηγόρης Χριστοδούλου', '6945685789', 'gxristodoulou@windowslive.com');
INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('Big bad wolf', 'Άκης Διαλυνός', '6988852639', 'akisdbigbagwolf@gmail.com');
INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('Starlet', 'Αναστασία Βλάχου', '6984565523', 'starletvlaxou@gmail.com');
INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('KityKat', 'Μαίρη Ρετσίνα', '6977723526', 'mairyretsina@windowslive.com');
INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('Princess', 'Έβελυν Καρατζόγλου', '6984566253', 'Ev.karatzoglou@gmail.com');
INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('Ραπ', 'Κωστής Ραπτόπουλος', '6978884596', 'raptopoulosk@gmail.com');
INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('The big boss', 'Βασίλης Νάκης', '6977936245', 'nakisvasilis@windowslive.com');
INSERT INTO "RadioShowProducer" (nickname, name, phone_number, email_address) VALUES ('Κόκκινος', 'Γρηγόρης Κόκκινος', '6986547264', 'gregkok@gmail.com');


--
-- Data for Name: Song; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('Everything', 'Rock', 'Everything', 2002, 'Vast', 'C://Users/songs/everything.mp3
');
INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('Starboy', 'R&B
', 'Starboy', 2016, 'The Weeknd', 'C://Users/songs/ starboy.mp3
');
INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('Gangsta’s Paradise
', 'Hip-Hop
', 'Dangerous Minds
', 1995, 'Coolio', 'C://Users/songs/bamboom.mp3
');
INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('Atlas, Rise!
', 'Metal', 'Hardwired to self-destruct
', 2016, 'Metallica
', 'C://Users/atlasrise.mp3
');
INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('Layla', 'Rock', 'Clapton Chronicles
', 1999, 'Eric Clapton
', 'C://Users/songs/layla.mp3
');
INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('Hurt', 'Country', 'The Man Comes Around
', 2002, 'Johnny Cash
', 'C://Users/songs/hurt.mp3
');
INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('On hold', 'Alternative', 'I see you', 2016, 'The xx', 'C://Users/songs/onhold.mp3
');
INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('Ain’t My fault
', 'Pop', 'Ain’t My fault
', 2016, 'Zara Larsson', 'C://Users/songs/aintmyfault.mp3
');
INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('I know Better', 'R&B
', 'Darkness and Light
', 2016, 'John Legend', 'C://Users/songs/iknowbetter.mp3
');
INSERT INTO "Song" (title, genre, album, release_year, artist, file_path) VALUES ('Do it', 'Hip-Hop
', 'Cocaine mafia
', 2011, 'French Montana', 'C://Users/songs/dododooit.mp3
');


--
-- Data for Name: Song-RadioShow; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "Song-RadioShow" (title, release_year, artist, name) VALUES ('On hold', 2016, 'The xx', 'BreakfastClub');
INSERT INTO "Song-RadioShow" (title, release_year, artist, name) VALUES ('Ain’t My fault
', 2016, 'Zara Larsson', 'Μαρμίτα');
INSERT INTO "Song-RadioShow" (title, release_year, artist, name) VALUES ('I know Better', 2016, 'John Legend', 'Non-stop');
INSERT INTO "Song-RadioShow" (title, release_year, artist, name) VALUES ('Everything', 2002, 'Vast', 'FAN-club');
INSERT INTO "Song-RadioShow" (title, release_year, artist, name) VALUES ('Starboy', 2016, 'The Weeknd', 'Κοσμοεπιτυχίες');
INSERT INTO "Song-RadioShow" (title, release_year, artist, name) VALUES ('Gangsta’s Paradise
', 1995, 'Coolio', 'Κοσμοεπιτυχίες');
INSERT INTO "Song-RadioShow" (title, release_year, artist, name) VALUES ('Do it', 2011, 'French Montana', 'FAN-club');


--
-- Name: Advertisement-RadioShow Advertisement-RadioShow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Advertisement-RadioShow"
    ADD CONSTRAINT "Advertisement-RadioShow_pkey" PRIMARY KEY (company_name, name);


--
-- Name: Advertisement Advertisement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Advertisement"
    ADD CONSTRAINT "Advertisement_pkey" PRIMARY KEY (company_name);


--
-- Name: Contest CK_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Contest"
    ADD CONSTRAINT "CK_unique" UNIQUE (name, starting_date, ending_date);


--
-- Name: Contest Contest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Contest"
    ADD CONSTRAINT "Contest_pkey" PRIMARY KEY (unique_id);


--
-- Name: Days Days_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Days"
    ADD CONSTRAINT "Days_pkey" PRIMARY KEY (name, days);


--
-- Name: Event Event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Event"
    ADD CONSTRAINT "Event_pkey" PRIMARY KEY (name);


--
-- Name: Listener-Contest Listener-Contest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Listener-Contest"
    ADD CONSTRAINT "Listener-Contest_pkey" PRIMARY KEY (phone_number, unique_id);


--
-- Name: Listener-RadioShow Listener-RadioShow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Listener-RadioShow"
    ADD CONSTRAINT "Listener-RadioShow_pkey" PRIMARY KEY (phone_number, name);


--
-- Name: Listener Listener_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Listener"
    ADD CONSTRAINT "Listener_pkey" PRIMARY KEY (phone_number);


--
-- Name: RadioShow-RadioShowProducer RadioShow-RadioShowProducer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "RadioShow-RadioShowProducer"
    ADD CONSTRAINT "RadioShow-RadioShowProducer_pkey" PRIMARY KEY (name, nickname);


--
-- Name: RadioShowProducer RadioShowProducer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "RadioShowProducer"
    ADD CONSTRAINT "RadioShowProducer_pkey" PRIMARY KEY (nickname);


--
-- Name: RadioShow RadioShow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "RadioShow"
    ADD CONSTRAINT "RadioShow_pkey" PRIMARY KEY (name);


--
-- Name: Song-RadioShow Song-RadioShow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Song-RadioShow"
    ADD CONSTRAINT "Song-RadioShow_pkey" PRIMARY KEY (title, release_year, artist, name);


--
-- Name: Song Song_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Song"
    ADD CONSTRAINT "Song_pkey" PRIMARY KEY (title, release_year, artist);


--
-- Name: Advertisement-RadioShow Link_Advertisement_Advertisement-RadioShow; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Advertisement-RadioShow"
    ADD CONSTRAINT "Link_Advertisement_Advertisement-RadioShow" FOREIGN KEY (company_name) REFERENCES "Advertisement"(company_name) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Listener-Contest Link_Contest_Listener-Contest; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Listener-Contest"
    ADD CONSTRAINT "Link_Contest_Listener-Contest" FOREIGN KEY (unique_id) REFERENCES "Contest"(unique_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Listener-Contest Link_Listener_Listener-Contest; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Listener-Contest"
    ADD CONSTRAINT "Link_Listener_Listener-Contest" FOREIGN KEY (phone_number) REFERENCES "Listener"(phone_number) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Listener-RadioShow Link_Listener_Listener-RadioShow; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Listener-RadioShow"
    ADD CONSTRAINT "Link_Listener_Listener-RadioShow" FOREIGN KEY (phone_number) REFERENCES "Listener"(phone_number) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Event Link_RadioShowProducer_Event; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Event"
    ADD CONSTRAINT "Link_RadioShowProducer_Event" FOREIGN KEY (nickname) REFERENCES "RadioShowProducer"(nickname) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RadioShow-RadioShowProducer Link_RadioShowProducer_RadioShow-RadioShowProducer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "RadioShow-RadioShowProducer"
    ADD CONSTRAINT "Link_RadioShowProducer_RadioShow-RadioShowProducer" FOREIGN KEY (nickname) REFERENCES "RadioShowProducer"(nickname) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Advertisement-RadioShow Link_RadioShow_Advertisement-RadioShow; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Advertisement-RadioShow"
    ADD CONSTRAINT "Link_RadioShow_Advertisement-RadioShow" FOREIGN KEY (name) REFERENCES "RadioShow"(name) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Days Link_RadioShow_Days; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Days"
    ADD CONSTRAINT "Link_RadioShow_Days" FOREIGN KEY (name) REFERENCES "RadioShow"(name) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Listener-RadioShow Link_RadioShow_Listener-RadioShow; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Listener-RadioShow"
    ADD CONSTRAINT "Link_RadioShow_Listener-RadioShow" FOREIGN KEY (name) REFERENCES "RadioShow"(name) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RadioShow-RadioShowProducer Link_RadioShow_RadioShow-RadioShowProducer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "RadioShow-RadioShowProducer"
    ADD CONSTRAINT "Link_RadioShow_RadioShow-RadioShowProducer" FOREIGN KEY (name) REFERENCES "RadioShow"(name) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Song-RadioShow Link_RadioShow_Song-RadioShow; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Song-RadioShow"
    ADD CONSTRAINT "Link_RadioShow_Song-RadioShow" FOREIGN KEY (name) REFERENCES "RadioShow"(name) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Song-RadioShow Link_Song_Song-RadioShow; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Song-RadioShow"
    ADD CONSTRAINT "Link_Song_Song-RadioShow" FOREIGN KEY (title, release_year, artist) REFERENCES "Song"(title, release_year, artist) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--
