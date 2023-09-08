@echo off
:: in case you need to access tray or something
pushd "%~dp0"
set WITH=for /f "usebackq tokens=*" %%v in

setlocal EnableDelayedExpansion
for /f "usebackq delims=" %%T in (
    `tasklist /fi "imagename eq explorer.exe" /v /fo list`
) do (
    for /f "tokens=1,2 delims=:" %%A in ("%%T") do (
        :: find desktop process
        if "%%~A"=="PID" (
            set "e=%%~B"
            call "%~dp0trim" e
            set lastpid=!e!
        )
        rem have to do this stupid stuff
        rem because i can't just filter "N/A" window title
        rem also why does :: fail here, because you're stupid
        if "%%~B"==" N/A" (
            echo Explorer shell is already active
            "%WINDIR%\system32\timeout" /t 5
            exit /b
        )
    )
)
endlocal

:: should I keep it like this when a user can change config
:: in between init and deinit
"%~dp0tools\miniSCT" 5
set CTT=%ERRORLEVEL%
if "%ERRORLEVEL%"=="1" (
    for /f "usebackq delims=" %%S in ("AeroProne.txt") do ( pssuspend -nobanner "%%~S" 2>nul )
    "%~dp0tools\miniSCT" 0
)
echo.Unsuspending Shell Infrastructure Host
"%~dp0tools\pssuspend" -nobanner -r sihost
echo Restoring explorer.exe...
start "" explorer
echo Waiting for explorer to load
ping 127.0.0.0 -n 4 > nul
if "%CTT%"=="1" (
    for /f "usebackq delims=" %%S in ("AeroProne.txt") do ( pssuspend -nobanner -r "%%~S" 2>nul )
    "%~dp0tools\miniSCT" %CTT%
)
popd
