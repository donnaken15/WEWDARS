@echo off
:: spawn in new instance because of stupid call hierarchy
:: effecting `exit /b` which normally ends a script but also
:: applies to subroutines for some reason, literally
:: like batch scripts embedded into others, wtf
if "%~n0"=="cmd" ( set THIS="%~1" ) else ( set THIS="%~0" )
if not "%~1"=="+" ( set WTMP=%tmp%\WZKRICE_%random%\&&set "OLDPATH=%PATH%"&& cmd /c "%THIS%" + %1 %2 %3 && goto :quit && exit /b )

:: *-+-+-+-+-+-+-+-+-+-*
:: |      WEWDARS      |
:: +    aka WZKRice    +
::  >=-=-=-=-=-=-=-=-=< 
:: +   by donnaken15   +
:: |  <wesley@gmx.it>  |
:: *-+-+-+-+-+-+-+-+-+-*

:: most Windows 10 installations will have cURL now
:: if not, get it here and put it in the same directory
:: as the batch file: https://github.com/donnaken15/WEWDARS/raw/main/deps/curl.exe

mode CON COLS=80 LINES=40 && cls
set DDIR=%WTMP%deps\
set PATH=%PATH%;%DDIR%
set WLOG=%~dp0WEWDARS.LOG
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
set VER=25.08.24
:: get build number
for /f "tokens=6 delims=. " %%i in ('ver') do set BUILD=%%i
:: if %BUILD% GEQ 17763 // winver >= 1809 // immersive key removed
:: https://www.anoopcnair.com/windows-10-build-numbers-version-numbers/
:: https://www.tenforums.com/tutorials/89738-enable-disable-wide-context-menus-windows-10-a.html
set sub=call :substitute
set dep=call :dependency
set subdep=call :substitutedependency
:: there has to be something like plain file execution calls for this
(set \n=^
%=.=%
)
set seterr=call :seterr
set to="%WINDIR%\System32\timeout" /T
:: differ from GNU timeout
set where=where
:: which is faster than where, so check if it's available
where which>nul 2>nul&&set where=which
set title=call :wtitle
set ret=exit /b

echo ####### WEWDARS STARTED %DATE% %TIME% ########>%WLOG%

:: for /d %%d in ("%tmp%\WZKRICE_*") do rmdir "%%~d"

:: setlocal EnableDelayedExpansion
:: %sub% testvar curl https://donnaken15.cf/404
:: echo !testvar!
:: endlocal
:: pause

mkdir "%WTMP%"
mkdir "%DDIR%"

:home
    cls
    call :splash
    %TITLE%
    echo.       Improve your Windows experience by giving yourself more freedom,
    echo.       customization, and performance boosts.
    echo.
    echo.       Requires Windows 10 or Atlas OS
    echo.
    echo.         Options: (press a key)
    echo.          I - Setup (WIP!!)
    echo.          C - Credits
    echo.          Q - Quit
    echo.
    echo.       version %VER%
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
    if "1"=="1" (
        curl -Ls "%ROOT%%~1" | less -R
    ) else (
        less -R "%~dp0credits.txt"
    )
    %ret%
    :: 9999999 iq: curl groff page
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
    if [%1]==[] exit /b 1
    set "inVar=%~1"
    set "stripChar=%~2"
    if not defined stripChar set "stripChar= "
    call set "workVar=%%%inVar%%%"
    :: TODO: only count up characters here?
    :loop
        if "%workVar:~-1%" EQU "%stripChar%" (
            set "workVar=%workVar:~0,-1%"
            goto :loop
        )
    :: also trim leading
    :loop2
        if "%workVar:~0,1%" EQU "%stripChar%" (
            set "workVar=%workVar:~1%"
            goto :loop2
        )
    set "%inVar%=%workVar%"
    exit /b 0
:premain
    set SYSDIR=system32
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" ( set SYSDIR=SysWOW64 )
    set LZ1=%SYSTEMROOT%\%SYSDIR%
    ::				cackles
    %q% 2>&1 "%LZ1%\cacls.exe" "%LZ1%\config\system"
    if '%errorlevel%' NEQ '0' (
        :: i'm such a superuser that i can't even test going from unelevated to elevated anymore
        :: the temp VBS file has this script ending up at this spot over and over now
        echo Elevated privileges are not available.
        echo This script cannot run without them.
        echo Try rerunning as administrator.
        timeout /T 10
        exit
    )
    :: https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file
:main
    pushd "%CD%"
    CD /D "%~dp0"
    echo TEST
    pause
    exit
