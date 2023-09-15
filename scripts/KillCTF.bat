@echo off
:: whatever this program even does
set ctf="%WINDIR%\system32\ctfmon.exe"
if not exist %CTF% (
    echo ctfmon.exe is already deleted from System32
    exit /b
)
set /A maxtries=100
set /A tries=0
:try
if %tries% geq %maxtries% (
    echo Failed to kill ctfmon.exe after 100 tries
    exit /b
)
if exist %CTF% (
    "%~dp0tools\pskill" ctfmon.exe -nobanner >nul
    del %CTF% /Q >nul
    set /A tries+=1
) else (
    echo Killed and deleted ctfmon.exe
    echo Tries: %tries% / %maxtries% 1>&2
    exit /b
)
goto :try
