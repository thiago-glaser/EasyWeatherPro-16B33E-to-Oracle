# EasyWeatherPro-16B33E-to-Oracle
Get Historic and real time data from EasyWeatherPro-16B33E using Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production

# Code neede to get UTL_HTTP running... need to run as SYS

```
 BEGIN
      DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => 'api.ecowitt.net',
        ace => SYS.XS$ACE_TYPE(
          privilege_list => SYS.XS$NAME_LIST('http'),
          principal_name => 'C##WEATHER_STATION',
          principal_type => SYS.XS_ACL.PTYPE_DB
        )
      );
    END;
```
