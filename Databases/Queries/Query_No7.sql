/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



SELECT "Advertisement"."company_name","time_per_show"
FROM "Advertisement" JOIN "Advertisement-RadioShow"
ON "Advertisement"."company_name" = "Advertisement-RadioShow"."company_name"
WHERE name = 'Μαρμίτα'
