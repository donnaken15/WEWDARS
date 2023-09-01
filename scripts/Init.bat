@echo off
pushd "%~dp0"
set WITH=for /f "usebackq tokens=*" %%v in
:: literal gamemaker jargon
:: TODO: combine all these variables of commands together
:: into a singular macros file to run for scripts that need them
%WITH% (`call KeyValue ClassicTheme 1`) do ( if "%%v"=="1" ( echo Enabling classic theme&& "%~dp0tools\miniSCT" 1 ) )
%WITH% (`call KeyValue AutokillDWM 0`) do ( if "%%v"=="1" ( echo Killing DWM&&call "%~dp0DWMKill" ) )
"%~dp0tools\pskill" keepalive.exe
"%~dp0tools\pskill" pe.exe
echo Killing shell
call KillShell
echo.Suspending Shell Infrastructure Host
"%~dp0tools\pssuspend" sihost
taskkill /f /im fontdrvhost.exe /fi "username eq Font Driver Host\UMFD-0"
echo Starting Process Explorer...
cmd /c start "" /D "%~dp0" "%~dp0tools\keepalive" "%~dp0tools\pe"
echo Running idle script...
"%~dp0IdleEvent"
popd
