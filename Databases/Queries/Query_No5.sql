/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



SELECT "RadioShow"."name","start_time","duration","theme"
FROM "RadioShow" JOIN "Days"
ON "RadioShow"."name" = "Days"."name"
WHERE (((days = 'Monday' OR days = 'Tuesday' OR days =  'Wednesday' OR days = 'Thursday' OR days = 'Friday') AND theme = 'Ενημέρωση')) OR ((days = 'Saturday' OR days = 'Sunday') AND theme = 'Ενημέρωση')
