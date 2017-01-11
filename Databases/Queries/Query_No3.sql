/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



SELECT "name","start_time","theme"
FROM "RadioShow"
WHERE start_time > '18:00:00' AND NOT (theme = 'Αθλητικά')
