@echo off

cd /d "%~dp0"
echo Le script s'exécute dans : %cd% 

call env.bat

taskkill /F /IM postgrest-v12.0.3.exe

call pg-stop.bat
