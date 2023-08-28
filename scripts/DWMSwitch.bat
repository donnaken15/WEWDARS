@echo off
cd "%~dp0"
if [%1]==[] ( echo Usage: %~n0 [restore/kill/toggle] && exit /b )
set dwmfind=tasklist /fi "imagename eq dwm.exe" /fi "username eq Window Manager\DWM-1" /fo csv /nh 2^>nul ^| "%WINDIR%\system32\find" /i "dwm.exe"^>nul
if not "%~1"=="waitdwm" goto %1

:toggle
	%dwmfind% && goto kill || goto restore

:restore
	%dwmfind% && echo DWM is already active && exit /b
	title DWM (Unfortunate) restorer...
	echo Getting Classic Theme state
	miniSCT 5
	set CTT=%ERRORLEVEL%
	if "%ERRORLEVEL%"=="1" ( miniSCT 0 )
	echo Unsuspending winlogon
	pssuspend -r winlogon -nobanner
	:waitdwm
	%dwmfind%
	if "%ERRORLEVEL%"=="1" ( ping 127.0.0.0 -n -w 50>nul && goto :waitdwm )
	ping 127.0.0.0 -n -w 200>nul
	miniSCT %CTT%
	exit /b

:kill
	%dwmfind% || echo DWM is ALREADY DEAD. HAHAHAHA!!! ..... && exit /b
	title DWM DESTROYER!!
	echo Killing common UWP apps
	::taskkill /f /im explorer.exe
	for /f "usebackq delims=" %%S in ("%~dp0UWP.txt") do ( taskkill /f /im "%%~S" 2>nul )
	echo Suspending winlogon
	pssuspend winlogon -nobanner
	taskkill /f /im dwm.exe
	exit /b

