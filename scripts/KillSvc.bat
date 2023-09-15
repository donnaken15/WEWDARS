@echo off
for /f "usebackq delims=" %%S in ("UnnecessaryServices.txt") do (
    sc stop "%%~S" | "%WINDIR%\system32\find" /i "SERVICE_NAME: %%~S" >nul && echo - Stopping %%~S
)
setlocal EnableDelayedExpansion
for /f "usebackq delims=" %%S in ("ShadowServices.txt") do (
    for /f "usebackq delims=" %%T in (
        `sc query ^| "%WINDIR%\system32\find" /i "SERVICE_NAME: %%~S"`
    ) do (
        set A=%%T
        rem reg add HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService_14aa0 /v Start /d 4 /t REG_DWORD /f
        rem WPN REFUSES TO DIE EVEN WHEN "DISABLED"
        echo - Stopping !A:~14!
        sc stop "!A:~14!"
    )
)
endlocal