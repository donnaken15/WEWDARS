@echo off
::
:: *-+-+-+-+-+-+-+-+-+-*
:: |      WEWDARS      |
:: +    aka WZKRice    +
::  >=-=-=-=-=-=-=-=-=< 
:: +   by donnaken15   +
:: |  <wesley@gmx.it>  |
:: *-+-+-+-+-+-+-+-+-+-*
::
:: spawn in new instance because of stupid call hierarchy
:: effecting `exit /b` which normally ends a script but also
:: applies to subroutines for some reason, literally
:: like batch scripts embedded into others, wtf
if "%~n0"=="cmd" ( set THIS="%~1" ) else ( set THIS="%~0" )
:: and because of terminate batch job stuff
if not "%INSTANCE%"=="1" (
	set INSTANCE=1
	start "DO NOT TOUCH THIS WINDOW!! This is required for cleanup once the batch script exits." /min cmd /c "%THIS%" %* ^<nul
	set INSTANCE=
	exit /b
)
if not "%~1"=="+" (
	mode CON cols=20 lines=1 >nul
	set "WTMP=%tmp%\WZKRICE_%random%\"
	set "OLDPATH=%PATH%"
	set "__INVOKED=%CMDCMDLINE%"
	start "WEWDARS" /wait cmd /c "%THIS%" + %*
	goto :quit
	exit /b
)
::
:: -------------------- initialization --------------------
::
set "DDIR=%WTMP%deps\"
set "PATH=%PATH%;%DDIR%"
set "WLOG=%~dp0WEWDARS.LOG"
echo [%DATE:~4% %TIME%] Loading>%WLOG%
set WIDTH=80
set HEIGHT=30
mode CON COLS=%WIDTH% LINES=%HEIGHT% && cls
set ROOT=https://github.com/donnaken15/WEWDARS/raw/main/
set LOG=^>^>"%WLOG%"
set Q=^>nul
:: don't know if i should just even deal with colors here because it's recently
:: added to windows 10 even if i use a compatibility layer like ansicon
set ESC=[
:: because can't just use CP437 symbols, stupid thing
:: (doesn't happen on Cygwin though, which I'm not using because bloat)
set LESSCHARSET=utf-8
:: reg ADD HKCU\Software\Sysinternals\PSexec /v EulaAccepted /t REG_DWORD /d 1 /f
set VER=24.01.01
:: get build number
for /f "tokens=6 delims=. " %%i in ('ver') do set BUILD=%%i
:: if %BUILD% GEQ 16257 // virtual terminal
:: if %BUILD% GEQ 17063 // winver >= 1803 // curl and tar introduced
:: if %BUILD% GEQ 17763 // winver >= 1809 // immersive key removed
:: https://www.anoopcnair.com/windows-10-build-numbers-version-numbers/
:: https://www.tenforums.com/tutorials/89738-enable-disable-wide-context-menus-windows-10-a.html
::
:: most Windows 10 installations will have cURL now
:: if not, get it here and put it in the same directory
:: as the batch file: https://github.com/donnaken15/WEWDARS/raw/main/deps/curl.exe
set sub=call :substitute
set dep=call :dependency
set subdep=call :substitutedependency
:: there has to be something like plain file execution calls for this
(set \n=^
%=.=%
)
set "seterr=call :seterr"
set to="%WINDIR%\System32\timeout" /T
:: differ from GNU timeout
set where=where
:: which is faster than where, so check if it's available
where which>nul 2>nul&&set where=which
set "title=call :wtitle"
set "ret=exit /b"
set WARNONCE=0
set ELEVATED=0
echo ####### WEWDARS STARTED %DATE% %TIME% ########%LOG%
mkdir "%WTMP%"
mkdir "%DDIR%"
pushd "%WTMP%"
::
:: --------------------------------------------------------

:: for /d %%d in ("%tmp%\WZKRICE_*") do rmdir "%%~d"

:: setlocal EnableDelayedExpansion
:: %sub% testvar curl https://donnaken15.cf/404
:: echo !testvar!
:: endlocal
:: pause

:home
	cls
	call :splash
	%TITLE%
	echo.       Improve your Windows experience by giving yourself more freedom,
	echo.       customization, utilities, and performance boosts.
	echo.
	echo.       Requires Windows 10 or Atlas OS
	echo.
	echo.         Options: (press a key)
	echo.          I - Setup (WIP!!)
	echo.          C - Credits
	echo.          Q - Quit
	echo.
	echo.       version %VER%
	if "%WARNONCE%"=="0" (
		set WARNONCE=1
		echo.
		echo.       Warning: Do not press Ctrl-C at any point in this script.
		echo.       If you want to abort operations, use the close button or Alt-F4.
	)
:homenorefresh
	%TITLE%
	choice/C ICQ%Q%
	goto :MENU[0][%ERRORLEVEL%]
	:MENU[0][1]
		goto :premain
	:MENU[0][2]
		call :readpage credits.txt "Credits"
		goto :homenorefresh
	:MENU[0][3]
		%ret%
	:MENU[0][END]
		goto :home
:readpage
	%TITLE% - %~2
	:: echo loading page %~1
	call :getexe curl
	:: kind of pointless if you already have it
	call :getexe less
	::curl -Ls "%ROOT%%~1" | less -R
	less -R "%~dp0credits.txt"
	%ret%
	:: 9999999 iq: curl+less groff page
	:: and have to pull all EXEs/DLLs
	:: for that
:: %sub% [var] [command]+
:: stupid hack to emulate unix command substitution
:: where output of command is assigned to a variable
:substitute
	:: requires EnableDelayedExpansion
	set STR=
	for /f "tokens=1,* delims= " %%a in ("%*") do (
		for /f "usebackq tokens=*" %%i in (`%%b`) do ( set STR=!STR!!\n!%%i ) )
	set %1=!STR!
	set STR=
	%ret%
:: dep [exe name] [arguments]+
:: find an executable in %PATH%,
:: otherwise download it from me
:dependency
	call :getexe %1
	%*
	%ret%
:substitutedependency
	call :getexe %2
	%sub% %*
	%ret%
:getexe
	%WHERE% "%~1" %Q% 2>nul
	if exist "%~dp0%~1.exe" ( %seterr% 0 )
	if exist "%DDIR%%~1.exe" ( %seterr% 0 )
	if "%ERRORLEVEL%"=="1" (
		echo Dependency %~1 not on disk, downloading...%LOG% ^
			&& call :getbase "%~1.exe" && %seterr% 2 )
												:: hack
	%ret%
:getbase
	curl -Lf "%ROOT%deps/%~1" -o "%DDIR%%~1" 2%LOG% ^
		|| echo Failed to get dependency %~1. Exiting... ^
		&& %to% 5 && exit
	%ret%
:splash
	echo.&
	echo       ,         `   +        /// Welcome  to \\\       ,         *   `&
	echo   -         .           --+-=-*-({ WEWDARS })-*-=-+--      '   -       +      .&
	echo         *      '     -   /     (  [[[===]]]  )     \     .         -       '&
	echo.&
	echo        Wesley's Extreme Windows Denormifying and Anticorpo Ricing System&
	echo.&
	%ret%
:wtitle
	title WEWDARS %* & %ret%
:seterr
	exit /b %1
:kv
	:: example usage:
	::	setlocal EnableDelayedExpansion
	::		call :kv ClassicTheme 1 x
	::		echo [ !x! ]
	::	endlocal
	set got=0
	if [%1]==[] exit /b 1
	if [%4]==[] (set "f=%~dp0config.ini") else (set "f=%~4")
	if exist "!f!" (
		for /f "usebackq delims=" %%L in ("!f!") do (
			for /f "tokens=1,2 delims==" %%A in ("%%~L") do (
				set "x=%~1"
				set "y=%%~A"
				set "z=%%~B"
				call :trim x
				call :trim y
				call :trim z
				if /I "!X!"=="!Y!" (
					set got=1
					if [%3]==[] (echo.!Z!) else (set "%~3=!Z!")
					exit /b 0
				)
			)
		)
	)
	if "%got%"=="0" (
		if not [%2]==[] (
			set "x=%~2"
			call :trim x
			if [%3]==[] (echo.!X!) else (set "%~3=!X!")
		) else (echo.)
	)
	exit /b 0
:trim
	:: https://ss64.org/viewtopic.php?t=22
	if [%1]==[] exit /b 1
	set "inVar=%~1"
	set "stripChar=%~2"
	if not defined stripChar set "stripChar= "
	call set "workVar=%%%inVar%%%"
	:: TODO: only count up characters here?
	:t_l1
		if "%workVar:~-1%" EQU "%stripChar%" (
			set "workVar=%workVar:~0,-1%"
			goto :t_l1
		)
	:: also trim leading
	:t_l2
		if "%workVar:~0,1%" EQU "%stripChar%" (
			set "workVar=%workVar:~1%"
			goto :t_l2
		)
	set "%inVar%=%workVar%"
	exit /b 0
:strlen
	setlocal enabledelayedexpansion
	:: https://www.tutorialspoint.com/batch_script/batch_script_string_length.htm
	:strlen_l
		if not "!%1:~%len%!"=="" set/a len+=1&goto :strlen_l
		(endlocal&exit /b %len%)
:fillstr
	setlocal enabledelayedexpansion
	set i=1
	if not [%2]==[] (set "char=%2") else (set "char= ")
	set "text=%char%"
	:fillstr_l
		if not "%i%"=="%1" (set/a i+=1&set "text=%text%%char%"&goto :fillstr_l)
		(endlocal&set "fillstr=%text%"&exit /b)
:fixwindow
	mode CON COLS=%WIDTH% LINES=%HEIGHT% & %ret%
:quit
	del /s /q /f "%WTMP%" %q% 2>nul & rmdir "%WTMP%deps" %q% 2>nul & rmdir "%WTMP%" %q% 2>nul
	set "PATH=%OLDPATH%"
	exit /b
:expr
	(setlocal&set /a tmp=%1)&
	(endlocal&exit /b %tmp%)
	:: seta hah
:premain
	:: screw batch
	if "%ELEVATED%"=="1" goto :elevated
	:: ELSE (
		set SYSDIR=system32
		IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" ( set SYSDIR=SysWOW64 )
		set "LZ1=%SYSTEMROOT%\%SYSDIR%"
		%q% 2>nul "%LZ1%\cacls.exe" "%LZ1%\config\system"
		::				cackles
		if not "%errorlevel%"=="0" (
			rem i'm such a superuser that i can't even test going from unelevated to elevated anymore
			rem the temp VBS file has this script ending up at this spot over and over now
			echo Elevated privileges are not available.
			echo This script cannot run without them.
			echo Try rerunning as administrator.
			%TO% 10
			exit
		) else set ELEVATED=1
	:: )
	:: https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file
	:elevated
		set OPT_PAGE=0
		::goto :options
:options
	set "gray=%ESC%H%ESC%47m%ESC%30m"&call :fillstr %WIDTH%
	set "header=%gray%%fillstr%%ESC%%width%D" & set /a fillwidth=%width%-2
	call :fillstr %fillwidth%
	set "footer=%ESC%46m%ESC%97m*%fillstr%*%ESC%%fillwidth%D" & set page=0
	%title% - Setup
	:opt_page
		cls&color 1f&call :fixwindow&set /a offset=%height%-2
		echo.%header% [ %page%/10] WEWDARS - Setup%ESC%44m%ESC%97m&echo.&
		call :seterr 51&
		set/a MSG_W=%width%-%ERRORLEVEL%^>^>1
		echo.%ESC%%MSG_W%CThis is an instruction where I try to add details,&
		echo.%ESC%%MSG_W%Cbut I am just dragging out a sentence where I don't&
		echo.%ESC%%MSG_W%Ceven add anything informative to it because I'm&
		echo.%ESC%%MSG_W%Cmaking an example right now to stylize and test&
		echo.%ESC%%MSG_W%Cmy glorified script that breaks Windows.&
		set CC=4&
		set "HINT=W: Up, S: Down, A: Prev, D: Next"&call :expr %width%-%CC%*2-5&
		choice/C WSAD /M "%ESC%%offset%B%footer% %HINT%%gray%%ESC%%ERRORLEVEL%C"&
		echo %ESC%0m&goto :MENU[0][%ERRORLEVEL%]
		:MENU[0][1]
			set page=1
			goto :MENU[0][END]
		:MENU[0][2]
			set page=2
			goto :MENU[0][END]
		:MENU[0][3]
			set page=3
			goto :home
			goto :MENU[BREAK]
		:MENU[0][4]
			set page=4
			goto :MENU[0][END]
		:MENU[0][END]
			goto :opt_page
		:MENU[BREAK]
	color&goto :home
	%ret%
:eulas
	%ret%
:log
	echo [%DATE:~4% %TIME%] %*%LOG%&%ret%
:main
	::pushd "%CD%"
	::CD /D "%~dp0"
	call :log TEST
	pause
	exit
