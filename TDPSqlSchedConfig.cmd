@ECHO off
:: BAClientSchedConfig.cmd
:: Version: 0.8
:: Author: John Skjönsberg <johns at cristie dot se>
:: Description: CMD script to add TSM related services for DP for MSSQL
:: How-To: Need to run as Administrator. To run the script almost silently - enter the value for PASSWORD variable

:: Variable definiton
set DSM_DIR=%PROGRAMFILES%\Tivoli\TSM\baclient
set TDP_DIR=%PROGRAMFILES%\Tivoli\TSM\TDPSql
set TDP_SCHED="%TDP_DIR%\tdpsched.log"
set TDP_ERROR="%TDP_DIR%\tdperror.log"
set DSM_OPT="%DSM_DIR%\dsm.opt"
set TDP_OPT="%TDP_DIR%\dsm.opt"
set NODENAME=
set TDP_NODENAME=
set DSMNODE=
set TDPNODE=
set INPUT=
set TDPINPUT=
set PASSWORD=
set TDPPASSWORD=

echo
echo ### Please verify that you do NOT currently have any TDP services installed or partly installed ###
echo 
pause

:: Flow
echo Changing working directory to %DSM_DIR%
cd %DSM_DIR%
echo Checking configuration...
if exist %TDP_OPT% (
	call :optfileexists
) else (
	echo Please configure TDPSql dsm.opt file
	exit
)
echo Setting nodename...
if [%INPUT%] == [] ( 
	set NODENAME=%TDPNODE% 
) else ( 
	set NODENAME=%TDPINPUT% 
) 
if [%TDPPASSWORD%] == [] (
	echo Need password...
	call :setpassword
	echo Installing TSM SQL Scheduler service...
	call :installscheduler
	echo installing TSM SQL Acceptor service...
	call :installclientacceptor
	echo Installing TSM SQL Remote Agent...
	call :installremoteagent
) else (
	echo Installing TSM SQL Scheduler service...
	call :installscheduler
	echo installing TSM SQL Acceptor service...
	call :installclientacceptor
	echo Installing TSM SQL Remote Agent...
)

:: Function declaration 
:DUMMY
echo
echo #########################################################################
echo # Script ends here, go in to Services and start TSM SQL Client Acceptor #
echo #########################################################################
echo 
pause
goto :EOF

:optfileexists
echo Options file exist, use same nodename as specified in dsm.opt, should be correct in brackets below, just hit enter...
for /f "Tokens=2" %%i in ('findstr /I /B nod %TDP_OPT%') do set TDPNODE=%%i
set /p TDPINPUT= NODename [%TDPNODE%]: 
goto :eof

:setpassword
set /p TDPPASSWORD= Enter TSM node password, no confirmation - do it right: 
goto :eof

:installscheduler
dsmcutil install scheduler /name:"TSM SQL Client Scheduler" /node:%NODENAME% /password:%TDPPASSWORD% /optfile:%TDP_OPT% /schedlog:%TDP_SCHED% /errorlog:%TDP_ERROR% /autostart:no /startnow:no
set TDPSCHEDRC=%ERRORLEVEL%
echo Return code: %TDPSCHEDRC%
goto :eof

:installclientacceptor
dsmcutil install cad /name:"TSM SQL Client Acceptor" /cadschedname:"TSM SQL Client Acceptor" /node:%NODENAME% /password:%TDPPASSWORD% /optfile:%TDP_OPT% /autostart:yes /startnow:no
set TDPCADRC=%ERRORLEVEL%
echo Return code: %TDPCADRC%
goto :eof

:installremoteagent
dsmcutil install remoteagent /name:"TSM SQL Remote Agent" /node:%TDPNODE% /password:%TDPPASSWORD% /optfile:%TDP_OPT% /partnername:"TSM SQL Client Acceptor" /startnow:no
set TDPREMAGENTRC=%ERRORLEVEL%
echo Return code: %TDPREMAGENTRC%
goto :eof

:END