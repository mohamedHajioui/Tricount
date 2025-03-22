@echo off

cd /d "%~dp0"
echo Le script s'exécute dans : %cd% 

call env.bat

if not exist "..\..\data" (
    call pg-init.bat
) else (
    call pg-start.bat
)

REM pause for 3 seconds
ping 127.0.0.1 -n 3 > nul

REM Lancement de PostgREST
taskkill /F /IM postgrest-v12.0.3.exe
start "" /min postgrest-v12.0.3.exe ..\..\postgrest.conf
