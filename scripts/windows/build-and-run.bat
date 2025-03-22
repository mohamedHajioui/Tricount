@echo off

cd /d "%~dp0"
echo Le script s'exécute dans : %cd% 

call env.bat

call postgrest-start.bat

ping 127.0.0.1 -n 3 > nul

FOR %%F IN (..\..\backend\*.sql) DO psql -U postgres -d %DB_NAME% -f "%%F"

pushd ..\..\frontend
flutter run -d windows
popd
