/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



GRANT ALL ON TABLE public."Advertisement" TO "Administrator";

GRANT SELECT ON TABLE public."Advertisement" TO "Radio_Producer";

GRANT ALL ON TABLE public."Advertisement-RadioShow" TO "Administrator";

GRANT SELECT ON TABLE public."Advertisement-RadioShow" TO "Auditioner";

GRANT SELECT ON TABLE public."Advertisement-RadioShow" TO "Radio_Producer";

GRANT ALL ON TABLE public."Contest" TO "Administrator";

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."Contest" TO "Radio_Producer";

GRANT ALL ON TABLE public."Days" TO "Administrator";

GRANT SELECT, UPDATE ON TABLE public."Days" TO "Radio_Producer";

GRANT ALL ON TABLE public."Event" TO "Administrator";

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."Event" TO "Radio_Producer";

GRANT ALL ON TABLE public."Listener" TO "Administrator";

GRANT INSERT, SELECT ON TABLE public."Listener" TO "Auditioner";

GRANT SELECT, UPDATE, DELETE ON TABLE public."Listener" TO "Radio_Producer";

GRANT ALL ON TABLE public."Listener-Contest" TO "Administrator";

GRANT INSERT, SELECT ON TABLE public."Listener-Contest" TO "Auditioner";

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."Listener-Contest" TO "Radio_Producer";

GRANT ALL ON TABLE public."Listener-RadioShow" TO "Administrator";

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."Listener-RadioShow" TO "Auditioner";

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."Listener-RadioShow" TO "Radio_Producer";

GRANT ALL ON TABLE public."RadioShow" TO "Administrator";

GRANT INSERT, SELECT ON TABLE public."RadioShow" TO "Auditioner";

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."RadioShow" TO "Radio_Producer";

GRANT ALL ON TABLE public."RadioShow-RadioShowProducer" TO "Administrator";

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."RadioShow-RadioShowProducer" TO "Auditioner";

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."RadioShow-RadioShowProducer" TO "Radio_Producer";

GRANT ALL ON TABLE public."RadioShowProducer" TO "Administrator";

GRANT SELECT ON TABLE public."RadioShowProducer" TO "Auditioner";

GRANT INSERT, SELECT, UPDATE ON TABLE public."RadioShowProducer" TO "Radio_Producer";

GRANT ALL ON TABLE public."Song" TO "Administrator";

GRANT INSERT, SELECT, UPDATE ON TABLE public."Song" TO "Radio_Producer";

GRANT ALL ON TABLE public."Song-RadioShow" TO "Administrator";

GRANT SELECT ON TABLE public."Song-RadioShow" TO "Auditioner";

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE public."Song-RadioShow" TO "Radio_Producer";

GRANT INSERT, SELECT, DELETE ON TABLE public."ListenerContestView" TO "Administrator";

GRANT SELECT ON TABLE public."ListenerContestView" TO "Auditioner";

GRANT INSERT, SELECT, DELETE ON TABLE public."PlayListView" TO "Administrator";

GRANT SELECT ON TABLE public."PlayListView" TO "Radio_Producer";
