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
for /F %%i IN ('hostname' ); DO set LOCALHOST=%%i
cd %~dp0

echo.
cd
REM echo %0 running on  ... Args: %* 

echo.
if @%1 == @ (     echo "Syntax: %0% URL USER PASSWORD Timetest [default:60]"
    exit /b )
if %1 == /? (      echo Syntax: %0% Timetest [default:60] 
    exit /b  )

SET URL=%1
SET USER=%2 
SET PASSWD=%3
SET NBLOOPS=60
IF NOT @%4 == @ SET NBLOOPS=%4
echo.

REM Syntax iF  oracle
REM   autoshutdown.cmdd oracle:thin:@mancswgtb0012:1521:fbti    TIZONE14   TIZONE14 
REM             [DB_TYPE oracle]  SEPAR [SERVER mancswgtb0012]  [DBNAME fbti]       [USER TIZONE14]     [PASSWD TIZONE14]
REM java...    %DB_TYPE%:%SERPAR%:@%SERVER%:1521:%DBNAME% %USER%   %PASSWD%
if %URL:~0,6% == oracle for /F "tokens=1,2,3,4,5 delims=:@" %%a in ("%URL%") ; do ( 
    SET DB_TYPE=%%a
    SET SEPAR=%%b
    SET SERVER=%%c
    SET PORT=%%d
    SET DBNAME=%%e 
)
REM  Syntax For DB2 
REM       autoshutdown.cmd db2://C1WC1WC1229:50000/TIPLUS2        TIZONE28   T!Z0N3123
REM                     %DB_TYPE%://%SERVER%:50000/%DBNAME%          %USER%    %PASSWD%
REM split:            [DB_TYPE=db2]      [SERVER=C1WC1WC1229]      [DBNAME=TIPLUS2]    [USER=TIZONE28]     [PASSWD=T!Z0N3123]
REM   java -jar dist\autoshutdown.jar    db2://C1WC1WC1229:50000/TIPLUS2         TIZONE28   T!Z0N3123
if %URL:~0,3% == db2    for /F "tokens=1,2,3,4 delims=:/" %%a in ("%URL%"); do (
    SET DB_TYPE=%%a 
    SET SERVER=%%b 
    SET PORT=%%c
    SET DBNAME=%%d 
)


REM ******************************************
REM  

set CHOICE=1
IF %SERVER% == %LOCALHOST% set SERVER_TO_KILL=%LOCALHOST%
	
IF @%SERVER_TO_KILL% == @    ( 
		echo Please choose which IDLE machine you want to stop, 
        echo 1: %SERVER%      [by default] %CHOICE%
        echo 2: %LOCALHOST% 
        echo Another Servername
        set /P CHOICE="Enter 1, 2, Q, Server name ?(default: 1):"
    	echo on
    	SET SERVER_TO_KILL=%SERVER%
    
    	if @%CHOICE% == @ set CHOICE=1
		if %CHOICE% == 1  ( SET SERVER_TO_KILL=%SERVER% 
    	) ELSE if %CHOICE% == 2 ( SET SERVER_TO_KILL=%LOCALHOST% 
    	) ELSE if %CHOICE% == Q ( GOTO :END
    	) ELSE SET SERVER_TO_KILL=%CHOICE%
    	)   
    )
   
echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo %DATE%, %TIME% :
echo    DB_TYPE :%DB_TYPE%  
echo    SEPAR   :%SEPAR%  
echo    SERVER  :%SERVER%  
echo    StoKILL :%SERVER_TO_KILL%  
echo    PORT    :%PORT%  
echo    DBNAME  :%DBNAME%
echo    USER    :%USER%
echo    PASSW   :%PASSWD:~0,1%...%PASSWD:~6,1%...
echo    Loc.Host:%LOCALHOST%
echo    DEBUG   :%DEBUG%
echo =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 
ping -n 1 %SERVER% | findstr "Reply from"


ping -n 1 %SERVER_TO_KILL% | findstr "Reply from"
IF NOT %ERRORLEVEL% == 0 GOTO :ENDING_PING_FAIL 
echo "1- OK %SERVER_TO_KILL% is up."

REM ******************************************
REM     Just use query.exe to alert on Users
REM ******************************************
echo.
echo  2- Searching Active Remote Desktop Users...
QUERY.exe user /server %SERVER_TO_KILL% | findstr "Active" && IF NOT @%DEBUG% == @ set /P W="WARNING: Active connections are present on %SERVER_TO_KILL%. Press return to continue..."
 
echo 3- About to run java -jar dist\autoshutdown.jar %* %NBLOOPS%
IF NOT @%DEBUG% == @ set /P xx="Press return to continue..."

echo %TIME% : Idle detection started...
java -jar dist\autoshutdown.jar %* %NBLOOPS%

goto :ENDING_%ERRORLEVEL%
goto :ENDING_1


:ENDING_PING_FAIL
	echo  %TIME% : Exit status: %ERRORLEVEL%
	set /P ERR="echo cannnot ping this host: %SERVER_TO_KILL%.  Press return to quit."  
GOTO END

:ENDING_0
	echo Good status but no stop action can be decided yet.
GOTO END

:ENDING_999
	echo %DATE%, %TIME%
	echo Exit status: %ERRORLEVEL%

	echo.
	echo OK Shutdown is valid ! 
	echo.
	REM net stop  DB2
	REM NET STOP  

	echo Shutdown will occur in 30 seconds, to abort you could try :
	echo shutdown -a -m \\%SERVER_TO_KILL% 
	timeout 30
	echo Shutdown sent to %SERVER_TO_KILL%...
	SHUTDOWN  -s -m \\%SERVER_TO_KILL% -t 60 
	echo .
	exit /b

:ENDING_992
GOTO END

:ENDING_993
	echo %DATE%, %TIME%
	echo ERROR 993: SQLException, no way to decide a shutdown.  
	echo Hit this if you are sure: 

	echo SHUTDOWN  -s -m -i \\%SERVER_TO_KILL% -c "Normal shutdown after SQL inactivity detected." 
	echo SHUTDOWN  /s /m \\%SERVER_TO_KILL%GOTO END
	echo Syntax to stop a running shutdown: SHUTDOWN  -a -m -i \\%SERVER_TO_KILL% 
:ENDING_994
GOTO END

:ENDING_130
	echo %DATE%, %TIME%
	echo Exit status: %ERRORLEVEL%
	echo Error status 130 . aborted due to syntax 
GOTO END

:ENDING_1
	echo %DATE%, %TIME%
	echo  Exit status: %ERRORLEVEL%
	Echo status Not managed.
GOTO END

REM  Final end
:END
echo %TIME% . exiting from  %0% ...
timeout 10
exit /B