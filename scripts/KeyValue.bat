@echo off
:: batch ruined this script for me
:: with all this stupid local stuff
set got=0
if [%1]==[] exit /b 1
if exist "%~dp0WEWDARS.INI" (
	for /f "usebackq delims=" %%L in ("%~dp0WEWDARS.INI") do (
		for /f "tokens=1,2 delims==" %%A in ("%%~L") do (
			call :kv "%~1" "%%~A" "%%~B"
		)
	)
)
if "%got%"=="0" ( if not [%2]==[] ( call :default "%~2" ) else ( echo. ) )
exit /b 0

:default
	set "x=%~1"
	call :rtm x
	echo %x%
	exit /b
:kv
	set "x=%~1"
	set "y=%~2"
	set "z=%~3"
	call :rtm x
	call :rtm y
	call :rtm z
	if /I "%X%"=="%Y%" (
		set got=1
		echo.%Z%
		exit /b
	)
	exit /b
:rtm
	:: i used this totally wrong
	:: https://ss64.org/viewtopic.php?t=22
	set "inVar=%~1"
	set "stripChar=%~2"
	if not defined stripChar set "stripChar= "
	call set "workVar=%%%inVar%%%"
	:loop
		if "%workVar:~-1%" EQU "%stripChar%" (
			set "workVar=%workVar:~0,-1%"
			goto :loop
		)
	:: also trim leading
	:loop2
		if "%workVar:~0,1%" NEQ "%stripChar%" (
			set "%inVar%=%workVar%"
			exit /b
		) else (
			set "workVar=%workVar:~1%"
			goto :loop2
		)

