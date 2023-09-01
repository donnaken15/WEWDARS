@echo off
:: batch ruined this script for me
:: with all this stupid local stuff
setlocal EnableDelayedExpansion
set got=0
if [%1]==[] exit /b 1
if [%3]==[] (set "f=%~dp0WEWDARS.INI") else (set "f=%~3")
if exist "!f!" (
    for /f "usebackq delims=" %%L in ("!f!") do (
        for /f "tokens=1,2 delims==" %%A in ("%%~L") do (
            set "x=%~1"
            set "y=%%~A"
            set "z=%%~B"
            call "%~dp0trim" x
            call "%~dp0trim" y
            call "%~dp0trim" z
            if /I "!X!"=="!Y!" (
                set got=1
                echo.!Z!
                exit /b
            )
        )
    )
)
if "%got%"=="0" (
    if not [%2]==[] (
        set "x=%~2"
        call "%~dp0trim" x
        rem should have output var argument if possible
        echo.!x!
    ) else (echo.)
)
endlocal
exit /b 0



