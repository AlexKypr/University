/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



SELECT E."name",R."name",R."nickname",E."location"
FROM "RadioShowProducer" AS R JOIN "Event" AS E
ON E."nickname" = R."nickname"
WHERE R.name = 'Έβελυν Καρατζόγλου'
