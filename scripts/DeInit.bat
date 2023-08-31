@echo off
pushd "%~dp0"
set WITH=for /f "usebackq tokens=*" %%v in
:: should I keep it like this when a user can change config
:: in between init and deinit
%WITH% (`call KeyValue ClassicTheme 1`) do ( if "%%v"=="1" ( echo Disabling classic theme&& "%~dp0tools\miniSCT" 0 ) )
%WITH% (`call KeyValue AutokillDWM 1`) do ( if "%%v"=="1" ( echo Restoring DWM&&call "%~dp0DWMRestore" ) )
echo.Unsuspending Shell Infrastructure Host
"%~dp0tools\pssuspend" -r sihost
echo Restoring explorer.exe...
start "" explorer
popd
