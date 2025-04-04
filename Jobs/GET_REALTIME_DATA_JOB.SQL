BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"WEATHERSTATION"."GET_REALTIME_DATA_JOB"',
            job_type => 'PLSQL_BLOCK',
            job_action => 'BEGIN getrealtimedata; COMMIT; END;',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2024-10-25 10:36:36.000000000 -05:00','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => TRUE,
            comments => 'Gets real-time data every minute');

         
     
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"WEATHERSTATION"."GET_REALTIME_DATA_JOB"', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"WEATHERSTATION"."GET_REALTIME_DATA_JOB"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
      
   
  
    
    DBMS_SCHEDULER.enable(
             name => '"WEATHERSTATION"."GET_REALTIME_DATA_JOB"');
END;
