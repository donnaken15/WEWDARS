@:: bypass terminate batch job message but also look like an ugly script
@for /f "usebackq tokens=*" %%v in (`call %~dp0KeyValue AutoStartPeriod 60`) do (set wait=%%v)
@start "WEWDARS Start" /d "%~dp0" cmd /c mode CON COLS=55 LINES=10 ^&^& color 0a ^&^& echo.^&^&^
    echo.     Welcome back, %username%! In %wait% seconds,^&^&^
    echo.     WEWDARS will run this autostart routine.^&^&^
    echo.     If you wish to cancel this and use the normal^&^&^
    echo.     shell, press Ctrl+C or close this window.^&^&^
    "%WINDIR%\system32\timeout" /T %wait% /NOBREAK ^&^&^
    start "" cmd /c "%~dp0Init"
