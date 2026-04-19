@echo off
set "sourcedir=c:\Users\Tompe\Documents\laakkeet"

REM Haetaan nykyinen paivamaara ja kellonaika YYYY-MM-DD_HH-MM-SS muotoon
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do set CDATE=%%c-%%a-%%b
for /f "tokens=1-3 delims=:." %%a in ('time /t') do set CTIME=%%a-%%b-%%c
set "backupdir_name=laakkeet_backup_%CDATE%_%CTIME%"
set "destinationdir=c:\Users\Tompe\Documents\backupit\laakkeet\%backupdir_name%"

REM Tarkistetaan, onko kohdekansio olemassa ja luodaan se, jos ei ole
if not exist "%destinationdir%" (
    mkdir "%destinationdir%"
    echo Luotiin uusi varmuuskansiopolku: %destinationdir%
) else (
    echo Kohdekansio %destinationdir% on jo olemassa.
    echo Tama ei pitaisi tapahtua, jos aikaleima toimii oikein.
    echo Voit jatkaa tai painaa Ctrl+C peruuttaaksesi.
    pause
)

echo Luodaan varmuuskopio kohteesta %sourcedir% kohteeseen %destinationdir%...
xcopy "%sourcedir%" "%destinationdir%\" /E /I /H /K /Y

if %errorlevel% equ 0 (
    echo Varmuuskopiointi valmis onnistuneesti!
) else (
    echo Varmuuskopiointi epaonnistui virhekoodilla %errorlevel%.
)
echo.
pause
