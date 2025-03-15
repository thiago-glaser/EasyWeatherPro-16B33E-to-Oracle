--------------------------------------------------------
--  DDL for Function GETDATEFROMUNIXTIMESTAMP
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "WEATHERSTATION"."GETDATEFROMUNIXTIMESTAMP" (UNIXTIMESTAMP NUMBER) return TIMESTAMP is
  Result TIMESTAMP;
begin
    SELECT From_tz(Cast(To_timestamp('1970-01-01 00:00:00.0',
                        'YYYY-MM-DD HH24:MI:SS.FF')
                        + Numtodsinterval(UNIXTIMESTAMP,
                                       'SECOND') AS TIMESTAMP), 'UTC') AT local
    INTO   Result
    FROM   dual;
  return(Result);
end GETDATEFROMUNIXTIMESTAMP;

/
