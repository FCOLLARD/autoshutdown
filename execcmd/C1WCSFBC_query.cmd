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
set DB2LIST=C1WCSFBC1237 C1WCSFBC1238 C1WCSFBC1239 C1WCSFBC1242
echo.

cd %~dp0
SET C1W_LIST1=C1WCSFBC1235 C1WCSFBC1236 C1WCSFBC1237 C1WCSFBC1238 C1WCSFBC1239 C1WCSFBC1242 C1WCSFBC1246 
SET C1W_LIST2=C1WC1WCS1222 C1WC1WC1229  C1WCSFBC1281  C1WCSFBC1282 C1WCSFBC1283 C1WCSFBC1284  C1WCSFBC1284 
SET CLONE_LIST=52.220.237.237 13.250.75.171 13.250.138.24 13.251.54.161 
       
for %%I  IN (%C1W_LIST1% %C1W_LIST2% %CLONE_LIST%) do (
    echo %%I...
	echo =-=-=-=-=-=-=-=-=-
	 ping -n 1 %%I  | findstr Reply  > \null && CALL :QUERY %%I || echo %%I: no pong to ping !
	
 	echo.
	echo =-=-=-=-=-=-=-=-=-=-=-=-=-=
)
echo %0 done

color	
goto :END

REM -=-=-=- Manage each machine: RDP connections, TIzone connection, Dataserver started
:QUERY
	color 1E
	TITLE query user / server %1...
    
	echo query user /server %1  | findstr "disc Active" 
	echo.
	TITLE tasklist /s  %1...
    tasklist /S %1  | findstr /i "db2 ora"  || echo No dataserver in %1
	echo.
	color
GOTO :EOF
 
:END
exit /b
