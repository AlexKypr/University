/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



SELECT Rs."nickname"
FROM "RadioShow" JOIN "RadioShow-RadioShowProducer" AS Rs
	ON "RadioShow"."name" = Rs."name"
WHERE "RadioShow".start_time > '20:00:00'
