@echo off
:: *****
:: * Register nodes with TSM server
:: * Version: 0.4
:: * Cristie Nordic AB <support(at)cristie(dot)se
:: *****
:: * Change log
:: * 2014-10-24 Script created /JS
:: * 2014-10-24 Function :FIRST verified /JS
:: * 2014-10-24 Function :VERIFY successfully queries all nodes from domain: %DOMAIN%
:: *****************************
:: * Usage: Run script with a txt file of nodes as first argument. 
:: ******************************
IF [%1] == [] GOTO ARGERROR
:: Variables
set ARCH=%PROCESSOR_ARCHITECTURE%
set ARG1=%1
set NODELIST=%ARG1%
set BAC_DIR=%ProgramFiles%\Tivoli\TSM\baclient
set DSMADMC="%BAC_DIR%"\dsmadmc.exe
set DSMOPT="%BAC_DIR%"\dsm.opt
set VERIFYLOG=C:\temp\regnode_log.txt



:: User defined variables
set ID=admin
set PASS=supersecretpassword
set DOMAIN=
set PREFIX=

:: Funtions calls
call :FIRST
call :REG_NODE
call :VERIFY

:: Functions
:DUMMY
echo . 
GOTO :EOF

:FIRST
:: Function for flow control and argument check
:: Pommes frites
for /f "Tokens=3" %%i in ('find /c /v "*" %ARG1%') do set NUM_NODES=%%i
echo.
echo ******************************************
echo * Regisster multiple nodes Cristie style *
echo ******************************************
echo.
echo Will now reigister the %NUM_NODES% nodes in %ARG1% with the TSM server
echo Make sure the node file, %ARG1%, is only a list of nodes and one (1) node per line
echo.
echo Ctrl+c to abort or...
pause
GOTO :EOF

:REG_NODE
set TASK=Register_node
echo.
for /f %%i in (%ARG1%) do %DSMADMC% -dataonly=yes -optfile=%DSMOPT% -id=%ID% -pass=%PASS% register node %PREFIX%-%%i %%i domain=%DOMAIN%
if %ERRORLEVEL% GTR 0 ( echo Error: %TASK% & GOTO ERROR )
GOTO :EOF

:VERIFY
set TASK=Verify_register_node
echo.
%DSMADMC% -dataonly=yes -optfile=%DSMOPT% -id=%ID% -pass=%PASS% select node_name,domain_name,reg_time,reg_admin from nodes where domain_name in ('%DOMAIN%') order by reg_time desc
if %ERRORLEVEL% GTR 0 ( echo Error: %TASK% & GOTO ERROR )
GOTO :EOF

:ARGERROR
set TASK=Arg_error
echo.
echo.
echo Usage: regnode.cmd nodelist.txt
echo  - Where regnode.cmd is this script
echo  - And nodelist.txt is a required argument containing hostnames of new client nodes, one node per line.
echo.
echo *****************************
echo * support(at)cristie(dot)se *
echo *****************************
GOTO :EOF

:ERROR
echo error :o
pause
GOTO :EOF


:END
exit /B
