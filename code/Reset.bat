@Echo off

:: Created By Noson Rabinovich
:: noson5434@gmail.com
:: Date - 2022

:Start
title Windows Network Reset
MODE con:cols=75 lines=200

:: 12Hr Format Time
FOR /F %%i IN ('WMIC OS Get LocalDateTime /value') DO FOR /F %%j IN ("%%i") DO SET "%%j"
SET "H=%LocalDateTime:~8,2%"
SET "M=%LocalDateTime:~10,2%"
SET "S=%LocalDateTime:~12,2%"

IF "%H%" gtr "11" (set "period=PM") ELSE SET "period=AM"
SET /a "H=6%H% %% 12"
IF %H% EQU 0 SET "H=12"
IF %H% LSS 10 SET "H=0%H%"

echo  [97mCreated by: [90m( Noson Rabinovich )[0m
echo.
echo  [97mUser: [90m%USERNAME%
echo  [97mDate: [90m%date%
echo  [97mTime: [90m%H%:%M%:%S% %period%
echo.
echo      [91m ************************************************************ [0m
echo       [97m                  Windows Netowork Reset[0m
echo      [91m ************************************************************ [0m
echo.
echo.

:: *** UAC CONTROL ***
:StartUACCheck
echo  [97mChecking UAC Permissions ...[0m
timeout 1 /nobreak >nul
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' ( goto UACPrompt ) else ( goto IsAdmin ) 

:: REQUEST UAC
:UACPrompt
echo  [97mRequesting Administrative Privileges ...[0m
timeout 1 /nobreak >nul
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"  
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"  
"%temp%\getadmin.vbs"  
exit /B

:: USER IS ADMIN
:IsAdmin
echo.
echo  [32mUAC Permissions Complete. [97mWelcome Admin[0m[0m
echo.
echo      [91m ************************************************************ [0m
echo.
goto PCInfo

:: *** GET PC INFO ***
:PCInfo
echo.
echo [97m  Checking your system info, Please wait While We Finish Setting Up ....[0m
echo.
echo [97mUser Details[0m
echo Computer Name: %computername%
echo Domain Name: %userdnsdomain%
echo.
echo [97mComputer Details[0m
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /c:"System Manufacturer" /c:"System Model"
wmic bios get serialnumber
echo [97mNetwork Details[0m
ipconfig | findstr IPv4
echo.
echo  [32mSystem Info loaded successfully.[0m
echo.
echo      [91m ************************************************************ [0m
echo.
goto choice

:choice
echo Do you want to continue?
echo This will temporarily disable internet access!
set /P c=[Y/N]
if /I "%c%" EQU "Y" goto continue
if /I "%c%" EQU "N" goto stop

goto choice

:continue
echo.
echo Releasing and Renewing...
ipconfig /release >nul
ipconfig /renew >nul

echo Resetting Arp Cache...
netsh int ip delete arpcache >nul

echo Resetting Local IP...
netsh int ip reset >nul

echo Reseting Winsock...
netsh winsock reset >nul
netsh winsock reset proxy >nul

echo Resetting Network Adapter...
for /F "skip=3 tokens=1,2,3* delims= " %%G in ('netsh interface show interface') DO (
    IF "%%H"=="Connected" netsh interface set interface "%%J" disabled
)>nul

for /F "skip=3 tokens=1,2,3* delims= " %%G in ('netsh interface show interface') DO (
    IF "%%H"=="Disconnected" netsh interface set interface "%%J" enabled
)>nul
goto done

:done
echo.
echo Complete! Your connection should continue as normal.
pause
goto stop

:stop
exit