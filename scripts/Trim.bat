:: https://ss64.org/viewtopic.php?t=22
if [%1]==[] exit /b 1
set "inVar=%~1"
set "stripChar=%~2"
if not defined stripChar set "stripChar= "
call set "workVar=%%%inVar%%%"
:loop
    if "%workVar:~-1%" EQU "%stripChar%" (
        set "workVar=%workVar:~0,-1%"
        goto :loop
    )
:: also trim leading
:loop2
    if "%workVar:~0,1%" EQU "%stripChar%" (
        set "workVar=%workVar:~1%"
        goto :loop2
    )
    set "%inVar%=%workVar%"
    exit /b 0
