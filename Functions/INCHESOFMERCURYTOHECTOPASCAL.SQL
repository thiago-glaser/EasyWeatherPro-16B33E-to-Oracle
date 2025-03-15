--------------------------------------------------------
--  DDL for Function INCHESOFMERCURYTOHECTOPASCAL
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "WEATHERSTATION"."INCHESOFMERCURYTOHECTOPASCAL" (inchesOfMercury IN NUMBER)
RETURN NUMBER
IS
  hectopascals NUMBER;
  InchesToMillibarConversion CONSTANT NUMBER := 33.8639;
BEGIN
  hectopascals := inchesOfMercury * InchesToMillibarConversion;
  RETURN hectopascals;
END;


/
