/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



SELECT "name","starting_date","ending_date","gift"
FROM "Contest"
WHERE starting_date > '2016-10-28' AND ending_date < '2016-11-17'
