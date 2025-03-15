--------------------------------------------------------
--  DDL for Function INCHESTOMILLIMETERS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "WEATHERSTATION"."INCHESTOMILLIMETERS" (inches IN NUMBER)
RETURN NUMBER
IS
  millimeters NUMBER;
BEGIN
  millimeters := inches * 25.4;
  RETURN millimeters;
END;


/
