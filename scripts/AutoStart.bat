@:: bypass terminate batch job message
@set wait=30
@start "WEWDARS Start" /d "%~dp0" cmd /c mode CON COLS=100 LINES=10 ^&^& color 0a ^&^& echo.^&^&^
	echo.     Welcome back, %username%! In %wait% seconds, WEWDARS will run this autostart routine.^&^&^
	echo.     If you wish to cancel this and use the normal shell, press Ctrl+C or close this window.^&^&^
	%WINDIR%\system32\timeout /T %wait% /NOBREAK ^&^&^
	start "" cmd /c "%~dp0Init"
