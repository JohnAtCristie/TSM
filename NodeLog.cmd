@echo off
::
:: Backup client logs 
:: John Skjönsberg johns@cristie.se
::
set DOOM="C:\Program Files\Tivoli\TSM\baclient"
set SYSINFOFILE=dsminfo.txt
c:
cd %DOOM%
dsmc query systeminfo
dsmc sel %SYSINFOFILE%