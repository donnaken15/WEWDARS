@echo off
set ctf="%WINDIR%\system32\ctfmon.exe"
:: should make own task kill that checks the path
:: of the EXE from where the process is running
if not exist "%CTF%" (
    pushd "%WINDIR%\WinSxS"
    for /d %%x in ("amd64_microsoft-windows-t..cesframework-ctfmon_31bf3856ad364e35_*_none_*") do (
        "%~dp0tools\pskill" ctfmon.exe -nobanner
        del %CTF% /Q
        copy "%WINDIR%\WinSxS\%%x\ctfmon.exe" %CTF% /y
        popd
        exit /b 0
    )
    popd
    echo Can't find ctfmon.exe in SxS
) else (echo ctfmon.exe is already in System32)
exit /b 1
