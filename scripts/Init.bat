@echo off
cd "%~dp0tools"
echo Killing shell
taskkill /f /im explorer.exe
echo Starting Process Explorer...
start "" /D "%~dp0" keepalive pe
echo Running idle script...
"%~dp0IdleEvent"
