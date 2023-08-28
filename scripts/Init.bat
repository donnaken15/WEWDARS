@echo off
pushd "%~dp0"
set WITH=for /f "usebackq tokens=*" %%v in
:: literal gamemaker jargon
:: TODO: combine all these variables of commands together
:: into a singular macros file to run for scripts that need them
%WITH% (`call KeyValue ClassicTheme 1`) do ( if "%%v"=="1" ( echo Enabling classic theme&& "%~dp0tools\miniSCT" 1 ) )
%WITH% (`call KeyValue AutokillDWM 1`) do ( if "%%v"=="1" ( echo Killing DWM&&call "%~dp0DWMKill" ) )
taskkill /f /im keepalive.exe
taskkill /f /im pe.exe
echo Killing shell
taskkill /f /im explorer.exe
echo.Suspending Shell Infrastructure Host
"%~dp0tools\pssuspend" sihost
echo Starting Process Explorer...
cmd /c start "" /D "%~dp0" "%~dp0tools\keepalive" "%~dp0tools\pe"
echo Running idle script...
"%~dp0IdleEvent"
popd
