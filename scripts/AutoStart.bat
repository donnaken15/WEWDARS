@:: bypass terminate batch job message
@start "WEWDARS Start" /d "%~dp0" cmd /c mode CON COLS=100 LINES=10 ^&^& color 0a ^&^& echo.^&^&^
	echo.     Welcome back, %USERNAME%! In one minute, WEWDARS will run this autostart routine.^&^&^
	echo.     If you wish to cancel this and use the normal shell, press Ctrl+C or close this window.^&^&^
	%WINDIR%\system32\timeout /T 60 /NOBREAK ^&^&^
	start "" "%~dp0Init"
