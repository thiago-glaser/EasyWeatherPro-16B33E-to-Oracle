create or replace NONEDITIONABLE PROCEDURE host_command (p_command  IN  VARCHAR2)
AS LANGUAGE JAVA
NAME 'Host.executeCommand (java.lang.String)';

