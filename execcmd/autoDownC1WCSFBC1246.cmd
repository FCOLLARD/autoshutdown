@echo OFF
REM 
REM   Used in conjunction with:
REM                              autoshutdown.jar,
REM    It Connects to a DB2/ORacle server 
REM    Search if users are connected . 
REM    After 1 hour exits if no connections where present
REM    This scripts then will launch a shutdown command .
REM   Expected status of java to perform shutdown is 999

REM   

echo.
cd %~dp0

REM       autoshutdown.cmd db2://C1WC1WC1229:50000/TIPLUS2        TIZONE28   T!Z0N3123
autoShutdownMain  db2://C1WCSFBC1246:50000/TIPLUS2  TIZONE28   T!Z0N3123 >> autoShutdown.C1WCSFBC1246.log