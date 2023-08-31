@echo off
setlocal EnableDelayedExpansion
(set \n=^
%=.=%
)
set file=
set got=0
if [%1]==[] exit /b 1
if [%2]==[] exit /b 1
if [%3]==[] (set "f=WEWDARS.INI") else (set "f=%~3")
set "x=%~1"
if not exist "!f!" (
    echo.%1 = %2> "!f!"
) else (
    for /f "usebackq delims=" %%L in ("!f!") do (
        for /f "tokens=1,2 delims==" %%A in ("%%~L") do (
            set "y=%%~A"
            set "z=%%~B"
            call "%~dp0trim" x
            call "%~dp0trim" y
            if /I "!X!"=="!Y!" (
                set got=1
                set "z=%~2"
            )
            call "%~dp0trim" z
            set "file=!file!!\n!!Y! = !Z!"
        )
    )
)
if "%got%"=="0" (
    set "file=!file!!\n!%~1 = %~2"
)
echo.!file:~1!> "!f!"
endlocal
exit /b 0



