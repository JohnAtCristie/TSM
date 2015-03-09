@ECHO off
:: BAClientSchedConfig.cmd
:: Version: 1.0
:: Author: John Skjönsberg <johns at cristie dot se>
:: Description: CMD script to add TSM related services for Backup/Archive client
:: How-To: Need to run as Administrator. To run the script almost silently - enter the value for PASSWORD variable

:: Variable definiton
set DSM_DIR=%PROGRAMFILES%\Tivoli\TSM\baclient
set DSM_OPT="%DSM_DIR%\dsm.opt"
set NODENAME=
set DSMNODE=
set INPUT=
set PASSWORD=
:: Flow
echo Changing working directory to %DSM_DIR%
cd %DSM_DIR%
echo Checking configuration...
if exist %DSM_OPT% (
	call :optfileexists
) else (
	echo Please configure TSM client dsm.opt file
	exit
)
echo Setting nodename...
if [%INPUT%] == [] ( 
	set NODENAME=%DSMNODE% 
) else ( 
	set NODENAME=%INPUT% 
) 
if [%PASSWORD%] == [] (
	echo Need password...
	call :setpassword
	echo Installing client scheduler service...
	call :installscheduler
	echo installing client acceptor service...
	call :installclientacceptor
) else (
	echo Installing client scheduler service...
	call :installscheduler
	echo installing client acceptor service...
	call :installclientacceptor
)
:: Function declaration 
:DUMMY
echo Script ends here, go in to Services and start TSM Client Acceptor
pause
goto :EOF

:optfileexists
echo Options file exist, use same nodename as specified in dsm.opt, should be correct in brackets below, just hit enter...
for /f "Tokens=2" %%i in ('findstr /I /B nod %DSM_OPT%') do set DSMNODE=%%i
set /p INPUT= NODename [%DSMNODE%]: 
goto :eof

:setpassword
set /p PASSWORD= Enter TSM node password, no confirmation - do it right: 
goto :eof

:installscheduler
dsmcutil install scheduler /name:"TSM Client Scheduler" /node:%NODENAME% /password:%PASSWORD% /autostart:no /startnow:no
set SCHEDRC=%ERRORLEVEL%
echo Return code: %SCHEDRC%
goto :eof

:installclientacceptor
dsmcutil install cad /name:"TSM Client Acceptor" /cadschedname:"TSM Client Scheduler" /node:%NODENAME% /password:%PASSWORD% /autostart:yes /startnow:no
set CADRC=%ERRORLEVEL%
echo Return code: %CADRC%
goto :eof

:END