@echo off
setlocal EnableDelayedExpansion
set got=0
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
        rem also why does :: not work here, because you're stupid
        if "%%~B"==" N/A" (
            taskkill /f /pid !e!
            set got=1
            exit /b
        )
    )
)
if "!got!"=="0" (
    echo Shell is already dead
    :: todo?: if launched from command line and not opening it, don't do timeout
    "%WINDIR%\system32\timeout" /t 5
)
endlocal

