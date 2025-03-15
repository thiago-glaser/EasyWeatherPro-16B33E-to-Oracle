--------------------------------------------------------
--  DDL for Procedure GETHISTORICDATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "WEATHERSTATION"."GETHISTORICDATA" (startdate IN TIMESTAMP, enddate IN TIMESTAMP) is

  json_obj            JSON_OBJECT_T;
  sensor_obj          JSON_OBJECT_T;
  sensor_list         JSON_OBJECT_T;
  keys_list           JSON_KEY_LIST;
  sensor_key          VARCHAR2(50);
  sensor_value        VARCHAR2(50);
  X NUMBER;



  /* Variable declarations */
  l_output            dbms_output.chararr;
  l_lines             INTEGER := 1000;
  r                   VARCHAR2(32000);
  cmd                 VARCHAR2(2000);
  filename            VARCHAR2(50);

  /* API credentials */
  application_key     VARCHAR2(40) := 'XXXXXXXXXXXXXXXXXXXX';
  api_key             VARCHAR2(40) := 'XXXXXXXXXXXXXXXXXXXX';
  mac                 VARCHAR2(40) := 'XXXXXXXXXXXXXXXXXXXX';
  
  recordExists        NUMBER;

begin
    /* Enable output buffering */
    dbms_output.ENABLE(1000000);

    dbms_java.Set_output(1000000);

    filename := Sys_guid();
    
    /* Construct the API call string */
    cmd :=
'curl "https://api.ecowitt.net/api/v3/device/history?application_key='
|| application_key
|| Chr(38)
||'api_key='
|| api_key
|| Chr(38)
||'mac='
|| mac
|| Chr(38)
|| 'start_date='
|| replace(TO_CHAR(startdate, 'YYYY-MM-DD HH24:MI:SS'), ' ', '%20')
|| Chr(38)
|| 'end_date='
|| replace(TO_CHAR(enddate, 'YYYY-MM-DD HH24:MI:SS'), ' ', '%20')
|| Chr(38)
||'call_back=outdoor,indoor,battery,wind,solar_and_uvi,rainfall,wind,pressure" -o c:\temp\'
||filename
||'.txt';
    
    /* Execute system commands */
    Host_command(cmd);

    Host_command('type c:\temp\'
                 ||filename
                 ||'.txt');
    
    Host_command('type c:\temp\'
                 ||filename
                 ||'.txt');


    /* Get output lines */
    dbms_output.Get_lines(l_output, l_lines);

    /* Build response string */

    r := L_output(1);

    Host_command('del c:\temp\'
                 ||filename
                 ||'.txt');

    if length(r)= 56 then --Empty file
        return;
    end if;
   
    -- Parse JSON data into a JSON object
    json_obj := JSON_OBJECT_T.parse(r);
    
    ------------------OUTDOOR TEMPERATURE----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('outdoor').get_Object('temperature');
    sensor_list := sensor_obj.get_Object('list');
    
    -- Get list of keys in the temperature list object
    keys_list := sensor_list.get_Keys();
    
    -- Loop through each timestamp key in the temperature list
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                         -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); -- Get the temperature as a string value
        
        SELECT COUNT(*) INTO recordExists from STATION X WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key) and X.ORIGEM = 1;

        if recordExists = 0 then
          INSERT INTO STATION(id,
                     localtimestamp,
                     externaltemperature,
                     batterystatus,
                     origem)
          VALUES(Sys_guid(), GETDATEFROMUNIXTIMESTAMP(sensor_key),fahrenheit_to_celsius(sensor_value), 0, 1);
          
        end if;  
    END LOOP;
    ------------------INDOOR TEMPERATURE----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('indoor').get_Object('temperature');
    sensor_list := sensor_obj.get_Object('list');
    
    -- Get list of keys in the temperature list object
    keys_list := sensor_list.get_Keys();
    
    -- Loop through each timestamp key in the temperature list
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); -- Get the temperature as a string value

        UPDATE STATION X
        SET X.internaltemperature = fahrenheit_to_celsius(sensor_value)  
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;

    ------------------OUTDOOR FEELS LIKE----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('outdoor').get_Object('feels_like');
    sensor_list := sensor_obj.get_Object('list');
    
    -- Get list of keys in the temperature list object
    keys_list := sensor_list.get_Keys();
    
    -- Loop through each timestamp key in the temperature list
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); -- Get the temperature as a string value
       
        UPDATE STATION X
        SET X.feelslike = fahrenheit_to_celsius(sensor_value)  
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;

    ------------------OUTDOOR APPARENT TEMPERATURE----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('outdoor').get_Object('app_temp');
    sensor_list := sensor_obj.get_Object('list');
    
    -- Get list of keys in the temperature list object
    keys_list := sensor_list.get_Keys();
    
    -- Loop through each timestamp key in the temperature list
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); -- Get the temperature as a string value
       
        UPDATE STATION X
        SET X.apparenttemperature = fahrenheit_to_celsius(sensor_value)  
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;
    
    ------------------OUTDOOR DEW PONIT ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('outdoor').get_Object('dew_point');
    sensor_list := sensor_obj.get_Object('list');
    
    -- Get list of keys in the temperature list object
    keys_list := sensor_list.get_Keys();
    
    -- Loop through each timestamp key in the temperature list
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); -- Get the temperature as a string value
       
        UPDATE STATION X
        SET X.dewpoint = fahrenheit_to_celsius(sensor_value)  
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;
    
    ------------------OUTDOOR HUMIDITY ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('outdoor').get_Object('humidity');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.externalhumidity = sensor_value 
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;
    
    ------------------INDOOR HUMIDITY ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('indoor').get_Object('humidity');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.internalhumidity = sensor_value 
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------SOLAR ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('solar_and_uvi').get_Object('solar');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 

        UPDATE STATION X
        SET X.solarradiation = sensor_value 
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;    END LOOP;    

    ------------------UVI ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('solar_and_uvi').get_Object('uvi');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.uv = sensor_value 
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    


    ------------------PRESSURE RELATIVE ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('pressure').get_Object('relative');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.internalpressurerel = inchesofmercurytohectopascal(sensor_value) 
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------PRESSURE ABSOLUTE ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('pressure').get_Object('absolute');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.internalpressureabs = inchesofmercurytohectopascal(sensor_value) 
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------WIND SPEED ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('wind').get_Object('wind_speed');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.windspeed = mphtokmh(sensor_value) 
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------WIND GUST ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('wind').get_Object('wind_gust');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.windgust = mphtokmh(sensor_value) 
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------WIND DIRECTION ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('wind').get_Object('wind_direction');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.winddirection = sensor_value
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------RAIN RATE ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('rainfall').get_Object('rain_rate');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.rain = inchestomillimeters(sensor_value)
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------DAILY RAIN ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('rainfall').get_Object('daily');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.dailyrain = inchestomillimeters(sensor_value)
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------EVENT RAIN ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('rainfall').get_Object('event');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();

    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.eventrain = inchestomillimeters(sensor_value)
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------WEEKLY RAIN ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('rainfall').get_Object('weekly');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.weeklyrain = inchestomillimeters(sensor_value)
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------MONTHKY RAIN ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('rainfall').get_Object('monthly');
    sensor_list := sensor_obj.get_Object('list');
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key); 
       
        UPDATE STATION X
        SET X.monthlyrain = inchestomillimeters(sensor_value)
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    ------------------YEARLY RAIN ----------------------------------------------------
    sensor_obj := json_obj.get_Object('data').get_Object('rainfall').get_Object('yearly');
    sensor_list := sensor_obj.get_Object('list'); 
    
    keys_list := sensor_list.get_Keys();
    
    FOR i IN 1 .. keys_list.COUNT LOOP
        sensor_key := keys_list(i);                    -- Get the timestamp as a string key
        sensor_value := sensor_list.get_Number(sensor_key);
       
        UPDATE STATION X
        SET X.yearlyrain = inchestomillimeters(sensor_value)
        WHERE X.localtimestamp = GETDATEFROMUNIXTIMESTAMP(sensor_key)
          AND X.ORIGEM = 1;
    END LOOP;    

    COMMIT;

end GETHISTORICDATA;

/
