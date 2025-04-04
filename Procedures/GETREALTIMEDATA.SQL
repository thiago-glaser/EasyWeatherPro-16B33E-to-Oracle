create or replace NONEDITIONABLE PROCEDURE "GETREALTIMEDATA"
AS
  /* Variable declarations */
  l_output            dbms_output.chararr;
  l_lines             INTEGER := 1000;
  r                   VARCHAR2(32000);
  cmd                 VARCHAR2(2000);
  filename            VARCHAR2(50);
  /* API credentials */
  application_key     VARCHAR2(40) := '--------------------------';
  api_key             VARCHAR2(40) := '--------------------------';
  mac                 VARCHAR2(40) := '------------------';
  /* Weather data variables */
  externaltemperature NUMBER;
  internaltemperature NUMBER;
  local_date          TIMESTAMP;
  externalhumidity    NUMBER;
  internalhumidity    NUMBER;
  internalpressureabs NUMBER;
  internalpressurerel NUMBER;
  windspeed           NUMBER;
  windgust            NUMBER;
  winddirection       NUMBER;
  solarradiation      NUMBER;
  uv                  NUMBER;
  rain                NUMBER;
  eventrain           NUMBER;
  dailyrain           NUMBER;
  weeklyrain          NUMBER;
  monthlyrain         NUMBER;
  yearlyrain          NUMBER;
  batterystatus       NUMBER;
  feelslike           NUMBER;
  apparenttemperature NUMBER;
  dewpoint            NUMBER;
  existrecord         NUMBER;
BEGIN
    /* Enable output buffering */
    dbms_output.ENABLE(1000000);

    dbms_java.Set_output(1000000);

    filename := Sys_guid();

    /* Construct the API call string */
    cmd :=
'curl "https://api.ecowitt.net/api/v3/device/real_time?application_key='
|| application_key
|| Chr(38)
||'api_key='
|| api_key
|| Chr(38)
||'mac='
|| mac
|| Chr(38)
||'call_back=all" -o c:\temp\'
||filename
||'.txt';
    /* Execute system commands */
    Host_command(cmd);

    Host_command('type c:\temp\'
                 ||filename
                 ||'.txt');

    Host_command('del c:\temp\'
                 ||filename
                 ||'.txt');

    /* Get output lines */
    dbms_output.Get_lines(l_output, l_lines);

    /* Build response string */
    r := '';

    FOR i IN 1 .. l_lines LOOP
        r := r
             || L_output(i);
    END LOOP;

    /* Extract weather data from JSON response */
    SELECT Fahrenheit_to_celsius(
           Json_value(r, '$.data.outdoor.temperature.value'))
    INTO   externaltemperature
    FROM   dual;

    SELECT Fahrenheit_to_celsius(Json_value(r, '$.data.indoor.temperature.value'
                                 ))
    INTO   internaltemperature
    FROM   dual;

    SELECT Fahrenheit_to_celsius(Json_value(r, '$.data.outdoor.feels_like.value'
                                 ))
    INTO   feelslike
    FROM   dual;

    SELECT Fahrenheit_to_celsius(Json_value(r, '$.data.outdoor.app_temp.value'))
    INTO   apparenttemperature
    FROM   dual;

    SELECT Fahrenheit_to_celsius(Json_value(r, '$.data.outdoor.dew_point.value')
           )
    INTO   dewpoint
    FROM   dual;

    SELECT Json_value(r, '$.data.outdoor.humidity.value')
    INTO   externalhumidity
    FROM   dual;

    SELECT Json_value(r, '$.data.indoor.humidity.value')
    INTO   internalhumidity
    FROM   dual;

    SELECT Inchesofmercurytohectopascal(
           Json_value(r, '$.data.pressure.absolute.value'))
    INTO   internalpressureabs
    FROM   dual;

    SELECT Inchesofmercurytohectopascal(
           Json_value(r, '$.data.pressure.relative.value'))
    INTO   internalpressurerel
    FROM   dual;

    SELECT Mphtokmh(Json_value(r, '$.data.wind.wind_speed.value'))
    INTO   windspeed
    FROM   dual;

    SELECT Mphtokmh(Json_value(r, '$.data.wind.wind_gust.value'))
    INTO   windgust
    FROM   dual;

    SELECT Json_value(r, '$.data.wind.wind_direction.value')
    INTO   winddirection
    FROM   dual;

    SELECT Json_value(r, '$.data.solar_and_uvi.solar.value')
    INTO   solarradiation
    FROM   dual;

    SELECT Json_value(r, '$.data.solar_and_uvi.uvi.value')
    INTO   uv
    FROM   dual;

    SELECT Inchestomillimeters(Json_value(r, '$.data.rainfall.rain_rate.value'))
    INTO   rain
    FROM   dual;

    SELECT Inchestomillimeters(Json_value(r, '$.data.rainfall.event.value'))
    INTO   eventrain
    FROM   dual;

    SELECT Inchestomillimeters(Json_value(r, '$.data.rainfall.daily.value'))
    INTO   dailyrain
    FROM   dual;

    SELECT Inchestomillimeters(Json_value(r, '$.data.rainfall.weekly.value'))
    INTO   weeklyrain
    FROM   dual;

    SELECT Inchestomillimeters(Json_value(r, '$.data.rainfall.monthly.value'))
    INTO   monthlyrain
    FROM   dual;

    SELECT Inchestomillimeters(Json_value(r, '$.data.rainfall.yearly.value'))
    INTO   yearlyrain
    FROM   dual;

    SELECT Json_value(r, '$.data.battery.sensor_array.value')
    INTO   batterystatus
    FROM   dual;

    SELECT getdatefromunixtimestamp(Json_value(r, '$.data.outdoor.temperature.time')) INTO local_date FROM DUAL;

    SELECT Count(*)
    INTO   existrecord
    FROM   station st
    WHERE  st.localtimestamp = local_date;

    IF existrecord < 1 THEN
      INSERT INTO station
                  (id,
                   localtimestamp,
                   externaltemperature,
                   internaltemperature,
                   feelslike,
                   apparenttemperature,
                   dewpoint,
                   externalhumidity,
                   internalhumidity,
                   internalpressureabs,
                   internalpressurerel,
                   windspeed,
                   windgust,
                   winddirection,
                   solarradiation,
                   uv,
                   rain,
                   eventrain,
                   dailyrain,
                   weeklyrain,
                   monthlyrain,
                   yearlyrain,
                   batterystatus, 
                   origem)
      VALUES      ( Sys_guid(),
                   local_date,
                   externaltemperature,
                   internaltemperature,
                   feelslike,
                   apparenttemperature,
                   dewpoint,
                   externalhumidity,
                   internalhumidity,
                   internalpressureabs,
                   internalpressurerel,
                   windspeed,
                   windgust,
                   winddirection,
                   solarradiation,
                   uv,
                   rain,
                   eventrain,
                   dailyrain,
                   weeklyrain,
                   monthlyrain,
                   yearlyrain,
                   batterystatus,
                   0);
    END IF;
    delete FROM STATION S where S.LOCALTIMESTAMP is null;
    commit;
END getrealtimedata;