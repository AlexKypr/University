/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



SELECT "name","date","time","location"
FROM "Event"
WHERE location = 'Regency Casino' OR location = 'I.Vellidis Hall'
