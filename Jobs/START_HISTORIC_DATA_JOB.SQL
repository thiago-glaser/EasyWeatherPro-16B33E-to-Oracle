BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"WEATHERSTATION"."START_HISTORIC_DATA_JOB"',
            job_type => 'PLSQL_BLOCK',
            job_action => 'BEGIN STARTHISTORICDATA; END;',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2024-10-31 02:05:40.000000000 -05:00','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=HOURLY;INTERVAL=1',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => TRUE,
            comments => 'Starts historic data process every hour');

         
     
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"WEATHERSTATION"."START_HISTORIC_DATA_JOB"', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"WEATHERSTATION"."START_HISTORIC_DATA_JOB"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
      
   
  
    
    DBMS_SCHEDULER.enable(
             name => '"WEATHERSTATION"."START_HISTORIC_DATA_JOB"');
END;
