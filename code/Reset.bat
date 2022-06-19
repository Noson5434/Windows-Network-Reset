@Echo off

:: Created By Noson Rabinovich
:: noson5434@gmail.com
:: Date - 2022

:Start
title Windows Network Reset
MODE con:cols=75 lines=200

:: 12Hr Format Time
for /f %%i in ('WMIC OS Get LocalDateTime /value') do for /f %%j in ("%%i") do set "%%j"
set "H=%LocalDateTime:~8,2%"
set "M=%LocalDateTime:~10,2%"
set "S=%LocalDateTime:~12,2%"

IF "%H%" gtr "11" (set "period=PM") ELSE set "period=AM"
set /a "H=6%H% %% 12"
IF %H% EQU 0 set "H=12"
IF %H% LSS 10 set "H=0%H%"

echo  [97mCreated by: [90m( Noson Rabinovich )[0m
echo.
echo  [97mUser: [90m%USERNAME%
echo  [97mDate: [90m%date%
echo  [97mTime: [90m%H%:%M%:%S% %period%
echo.
echo      [91m ************************************************************ [0m
echo       [97m                  Window's Netowork Reset[0m
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
set /P c=Are you sure you want to continue[Y/N]?
if /I "%c%" EQU "Y" goto continue
if /I "%c%" EQU "N" goto stop
goto choice

:continue
echo.
echo  [97mReleasing and Renewing the IP Address ...[0m
ipconfig /release >nul
timeout 3 /nobreak >nul
ipconfig /renew >nul
echo  [32mDone.[0m
timeout 2 /nobreak >nul
echo.

echo  [97mResetting the Arp Cache ...[0m
netsh int ip delete arpcache >nul
arp -d * >nul
nbtstat -R >nul
nbtstat -RR >nul
echo  [32mDone.[0m
timeout 2 /nobreak >nul
echo.

echo  [97mFlushing and Registering the DNS ...[0m
ipconfig /flushdns >nul
ipconfig /registerdns >nul
echo  [32mDone.[0m
timeout 2 /nobreak >nul
echo.

echo  [97mResetting the Local IP ...[0m
netsh int ip reset >nul
echo  [32mDone.[0m
timeout 2 /nobreak >nul
echo.

echo  [97mResetting the Winsock ...[0m
netsh winsock reset >nul
netsh winsock reset proxy >nul
netsh int IPv4 reset >nul
netsh int ipv6 reset >nul
echo  [32mDone.[0m
timeout 2 /nobreak >nul
echo.

echo  [97mResetting the Network Adapter ...[0m
for /F "skip=3 tokens=1,2,3* delims= " %%G in ('netsh interface show interface') DO (
    IF "%%H"=="Connected" netsh interface set interface "%%J" disabled
)>nul

for /F "skip=3 tokens=1,2,3* delims= " %%G in ('netsh interface show interface') DO (
    IF "%%H"=="Disconnected" netsh interface set interface "%%J" enabled
)>nul
echo  [32mDone.[0m
timeout 2 /nobreak >nul
echo.
goto done

:done
echo  [32mComplete! [97mYour connection should continue as normal.[0m[0m
timeout 3 /nobreak >nul
goto stop

:stop
exit