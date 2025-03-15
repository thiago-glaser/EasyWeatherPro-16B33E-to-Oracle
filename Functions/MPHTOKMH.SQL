--------------------------------------------------------
--  DDL for Function MPHTOKMH
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "WEATHERSTATION"."MPHTOKMH" (mph IN NUMBER)
RETURN NUMBER
IS
  kmh NUMBER;
BEGIN
  kmh := mph * 1.60934;
  RETURN kmh;
END;


/
