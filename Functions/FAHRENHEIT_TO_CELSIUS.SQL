--------------------------------------------------------
--  DDL for Function FAHRENHEIT_TO_CELSIUS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "WEATHERSTATION"."FAHRENHEIT_TO_CELSIUS" (fahrenheit IN NUMBER)
RETURN NUMBER IS
    celsius NUMBER;
BEGIN
    celsius := (fahrenheit - 32) * 5 / 9;
    RETURN celsius;
END fahrenheit_to_celsius;

/
