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


autoShutdownMain %1 %2 %3 %4 %5 >> autoShutdown.log