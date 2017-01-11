/*
 * Napoleon-Christos Oikonomou AEM:7952
 * Aggelos Vasileiadis AEM:8010
 * Alexandros-Charalampos Kyprianidis AEM:8012
 */



-- FUNCTION: public.calc_duration()

-- DROP FUNCTION public.calc_duration();

CREATE FUNCTION public.calc_duration()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE NOT LEAKPROOF
AS $BODY$

    BEGIN
    NEW.duration := NEW.end_time - NEW.start_time;
        RETURN NEW;
    END;

$BODY$;

ALTER FUNCTION public.calc_duration()
    OWNER TO postgres;

-- Trigger: calc_duration

-- DROP TRIGGER calc_duration ON public."RadioShow";

CREATE TRIGGER calc_duration
    BEFORE INSERT OR UPDATE
    ON public."RadioShow"
    FOR EACH ROW
    EXECUTE PROCEDURE calc_duration();
