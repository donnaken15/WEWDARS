@echo off
cd "%~dp0"
title WEWDARS
echo.--- WEWDARS ---
echo.Stopping services
for /f "usebackq delims=" %%S in ("UnnecessaryServices.txt") do ( echo y | net stop "%%~S" >nul 2>nul && echo - Stopped %%~S )
echo.Ending processes
for /f "usebackq delims=" %%S in ("UWP.txt","UnnecessaryProcesses.txt") do ( taskkill /f /im "%%~S" 2>nul )
set PASSES=2
echo Cleaning memory (%PASSES% times)
for /L %%I in (1,1,%PASSES%) do (
	echo.--- Run %%I ---
	for %%C in (
		"t,Standby list"
		"s,System working sets"
		"0,Priority 0 standby list"
		"w,Working sets"
		"m,Modified page list"
	) do (
		for /f "tokens=1,2 delims=," %%A in ( "%%~C" ) do (
			echo.  - %%~B && rammap -E%%~A && echo.    - Done
		)
	)
)
