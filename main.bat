@echo off
rem spawn in new instance because of stupid call hierarchy
rem effecting `exit /b` which normally ends a script but also
rem applies to subroutines for some reason, literally
rem like batch scripts embedded into others, wtf
if "%~n0"=="cmd" ( set THIS="%~1" ) else ( set THIS="%~0" )
if not "%~1"=="+" ( set WTMP=%tmp%\WZKRICE_%random%\&&set "OLDPATH=%PATH%"&& cmd /c "%THIS%" + && goto :quit && exit /b )

rem *-+-+-+-+-+-+-+-+-+-*
rem |      WEWDARS      |
rem +    aka WZKRice    +
rem  >=-=-=-=-=-=-=-=-=< 
rem +   by donnaken15   +
rem |  <wesley@gmx.it>  |
rem *-+-+-+-+-+-+-+-+-+-*

mode CON COLS=80 LINES=40 && cls
set DDIR=%WTMP%deps\
set PATH=%PATH%;%DDIR%
set WLOG=%~dp0WEWDARS.LOG
set ROOT=https://github.com/donnaken15/WEWDARS/raw/main/
set LOG=^>^>%WLOG%
set Q=^>nul
set VER=25.08.24
rem there has to be something like plain file execution calls for this
set sub=call :substitute
set dep=call :dependency
set subdep=call :substitutedependency
(set \n=^
%=.=%
)
set seterr=exit /b %~1
set to=%WINDIR%\System32\timeout /T
rem which is faster than where, so check if it's available
set where=where
where which>nul 2>nul&&set where=which
set title=call :wtitle
set ret=goto :eof
rem how do i use doskey to replace env vars calling stuff
rem just realized it only applies to the prompt, lame

echo ####### WEWDARS STARTED %DATE% %TIME% ########>%WLOG%

for /d %%d in ("%tmp%\WZKRICE_*") do rmdir "%%~d"

REM setlocal EnableDelayedExpansion
REM %sub% testvar curl https://donnaken15.cf/404
REM echo !testvar!
REM endlocal
REM pause

mkdir "%WTMP%"
mkdir "%DDIR%"

:home
	cls
	call :splash
	%TITLE%
	echo        Improve your Windows experience by giving yourself more freedom,
	echo        customization, and performance boosts.
	echo.
	echo        Requires Windows 10 or Atlas OS
	echo.
	echo.         Options: (press a key)
	echo.          I - Setup (WIP!!)
	echo.          C - Credits
	echo.          Q - Quit
	echo.
	echo        version %VER%
	choice/C ICQ%Q%
	goto :MENU[0][%ERRORLEVEL%]
	:MENU[0][1]
		goto :home
	:MENU[0][2]
		call :readpage credits.txt "Credits"
		goto :MENU[0][END]
	:MENU[0][3]
		%ret%
	:MENU[0][END]
		goto :home
:readpage
	%TITLE% - %~2
	echo loading page %~1
	call :getexe curl
	call :getexe less && call :getbase pcre3.dll
	curl -Ls "%ROOT%%~1" | less
	pause
	%ret%
	rem 9999999 iq: curl groff page
	rem and have to pull all EXEs/DLLs
	rem for that
rem %sub% [var] [command]+
rem stupid hack to emulate unix command substitution
rem where output of command is assigned to a variable
:substitute
	set STR=
	rem requires EnableDelayedExpansion
	for /f "tokens=1,* delims= " %%a in ("%*") do (
		for /f "usebackq tokens=*" %%i in (`%%b`) do ( set STR=!STR!!\n!%%i ) )
	set %1=!STR!
	set STR=
	%ret%
rem dep [exe name] [arguments]+
rem find an executable in %PATH%,
rem otherwise download it from me
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
	if exist "%~dp0%~1.exe" ( call :seterr 0 )
	if exist "%DDIR%%~1.exe" ( call :seterr 0 )
	if "%ERRORLEVEL%"=="1" (
		echo Dependency %~1 not on disk, downloading...%LOG% ^
			&& call :getbase "%~1.exe" )
	%ret%
:getbase
	curl -Lf "%ROOT%deps/%~1" -o "%DDIR%%~1" 2%LOG% ^
		|| echo Failed to get dependency %~1. Exiting... ^
		&& %to% 5 && exit
	%ret%
:splash
	echo.
	echo       ,         `   +        /// Welcome  to \\\       ,         *   `
	echo   -         .           --+-=-*-({ WEWDARS })-*-=-+--      '   -       +      .
	echo         *      '     -   /     (  [[[===]]]  )     \     .         -       '
	echo.
	echo        Wesley's Extreme Windows Denormifying and Anticorpo Ricing System
	echo.
	%ret%
:wtitle
	title WEWDARS %*
	%ret%
:quit
	del /s /q /f "%WTMP%" %q% 2>nul
	rmdir "%WTMP%deps" %q% 2>nul
	rmdir "%WTMP%" %q% 2>nul
	set PATH=%OLDPATH%
	exit /b
:seterr
	exit /b %1
	%ret%

rem
rem pre main / admin check {
rem
	set SYSDIR=system32
	IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" ( set SYSDIR=SysWOW64 )
	set LZ1=%SYSTEMROOT%\%SYSDIR%
	rem				cackles
	%q% 2>&1 "%LZ1%\cacls.exe" "%LZ1%\config\system"
	if '%errorlevel%' NEQ '0' (
		echo Requesting administrative privileges...
		goto uacp
	) else ( goto main )

	:uacp
		echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
		set params= %*
		echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
		"%temp%\getadmin.vbs"
		del "%temp%\getadmin.vbs"
		exit /B
rem
rem }
rem

:main
	pushd "%CD%"
	CD /D "%~dp0"

echo TEST

pause

exit

rem set PATH=%~dp0;%PATH%
rem sh
