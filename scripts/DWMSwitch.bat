@echo off
cd "%~dp0"
if [%1]==[] ( echo Usage: %~n0 [restore/kill/toggle] && exit /b )
set dwmfind=tasklist /fi "imagename eq dwm.exe" /fi "username eq Window Manager\DWM-*" /fo csv /nh 2^>nul ^| "%WINDIR%\system32\find" /i "dwm.exe"^>nul
if not "%~1"=="waitdwm" goto %1

:toggle
    %dwmfind% && goto kill || goto restore

:restore
    %dwmfind% && echo DWM is already active && exit /b
    title DWM (Unfortunate) restorer...
    echo Temporarily suspending Aero prone processes
    echo Getting Classic Theme state
    "%~dp0tools\miniSCT" 5
    set CTT=%ERRORLEVEL%
    if "%ERRORLEVEL%"=="1" (
        :: suspend programs that are quick to try to access aero theme again,
        :: like explorer, everything, or process explorer, where menu bars
        :: and run window will not appear in classic theme
        for /f "usebackq delims=" %%S in ("AeroProne.txt") do ( pssuspend "%%~S" 2>nul )
        "%~dp0tools\miniSCT" 0
    )
    echo Unsuspending winlogon
    "%~dp0tools\pssuspend" -r winlogon -nobanner
    :waitdwm
    %dwmfind%
    if "%ERRORLEVEL%"=="1" ( ping 127.0.0.0 -n -w 50>nul && goto :waitdwm )
    ping 127.0.0.0 -n -w 500>nul
    if "%CTT%"=="1" (
        for /f "usebackq delims=" %%S in ("AeroProne.txt") do ( pssuspend -r "%%~S" 2>nul )
        "%~dp0tools\miniSCT" %CTT%
    )
    exit /b

:kill
    %dwmfind% || echo DWM is ALREADY DEAD. HAHAHAHA!!! ..... && exit /b
    title DWM DESTROYER!!
    echo Killing common UWP apps
    call KillShell
    for /f "usebackq delims=" %%S in ("%~dp0UWP.txt") do ( taskkill /f /im "%%~S" 2>nul )
    echo Suspending winlogon
    "%~dp0tools\pssuspend" winlogon -nobanner
    taskkill /f /im dwm.exe
    exit /b

