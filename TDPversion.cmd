%echo off
:: Description: Checking for version of TSM TDP to install
:: Author: John Skjönsberg (johns@cristie.se)
:: Version: 0.1


::Variable declaration
set hostname=%COMPUTERNAME%
set ARCH=%PROCESSOR_ARCHITECTURE%

:: SQL 2K12
set SQL2K12=11.0.2100.60
set SQL2K12SP1=11.0.3000.0
set SQL2K12SP2=11.0.5058.0
:: SQL 2K8R2
set SQL2K8R2=10.50.1600.1
set SQL2K8R2SP1=10.50.2500.0
set SQL2K8R2SP2=10.50.4000.0
set SQL2K8R2SP3=10.50.6000.34
:: SQL 2K8
set SQL2K8=10.0.1600.22
set SQL2K8SP1=10.0.2531.0
set SQL2K8SP2=10.0.4000.0
set SQL2K8SP3=10.0.5500.0
set SQL2K8SP4=10.0.6000.29

:: Check registry for Windows version
for /f "tokens=3" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion') do set faildoze=%%i
echo %ERRORLEVEL%
:: Check registry for PowerShell version
for /f "tokens=3" %%i in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine /v PowerShellVersion') do set powerhell=%%i
echo %ERRORLEVEL%
:: Check registry for SQL version
:: reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft /f %SQL2K8R2% /s <- Recursive search, gives alotta output, will need to debug this and verify the path
for /f "tokens=3" %%i in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\CurrentVersion /v CurrentVersion') do set esquell=%%i
echo %ERRORLEVEL%

echo Windows version: %faildoze%
echo PowerShell version: %powerhell% 
echo SQL Server Version: %esquell%

rem ### Random notes###
rem reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine /v PowerShellVersion
rem reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion'
rem HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\SQLEXPRESS\MSSQLServer\CurrentVersion
rem HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\SQLEXPRESS\MSSQLServer\CurrentVersion
rem HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\CurrentVersion
:PS2
:PS3
:PS4

:WIN52
:: Win2k3
:WIN60
:: Win2k8
:: WinVista
:WIN61
:: Win2k8r2
:: Win7
:: Win Home Server 2011 DaFuq
:WIN62
:: Win2k12
:: Win8
:WIN63
:: Win2k12r2
:: Win8.1
:END