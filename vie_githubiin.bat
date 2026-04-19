@echo off
setlocal

REM Aseta taman projektin GitHub-repo URL tahan
set "REPO_URL=https://github.com/Mikkogeokalevi/laakkeet.git"
set "LAST_STEP=aloitus"

cd /d "c:\Users\Tompe\Documents\laakkeet"

echo.
echo =========================================
echo Git-paivitysskripti GitHubiin
echo =========================================
echo.

if "%REPO_URL%"=="https://github.com/REPLACE_ME/laakkeet.git" (
    echo Aseta ensin oikea REPO_URL tiedostoon vie_githubiin.bat
    echo Nykyinen arvo: %REPO_URL%
    echo.
    pause
    goto :eof
)

echo HUOM: Tama skripti ylikirjoittaa GitHub-repon sisallon.
echo (Force push) Tama korvaa GitHubin nykyisen historian.
echo.
set /p confirm_force="Haluatko ylikirjoittaa GitHubin? (K/E): "
if /I not "%confirm_force%"=="K" goto :eof

REM Varmista etta repo on alustettu
set "LAST_STEP=git-repo tarkistus"
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo Git-repoa ei loydy. Alustetaan nyt...
    set "LAST_STEP=git init"
    git init
    if errorlevel 1 goto :error

    set "LAST_STEP=aseta oletushaara"
    git branch -M main
    if errorlevel 1 goto :error
)

REM Varmista, etta origin on asetettu
set "LAST_STEP=origin tarkistus"
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo Origin-remotea ei loydy. Asetetaan se nyt...
    set "LAST_STEP=origin add"
    git remote add origin %REPO_URL%
    if errorlevel 1 goto :error
) else (
    echo Origin-remote on jo asetettu.
    echo Nykyinen URL:
    git remote get-url origin
)

REM Varmista, etta ollaan main-haarassa (tai luodaan se)
set "LAST_STEP=haaran tarkistus"
for /f "delims=" %%b in ('git branch --show-current 2^>nul') do set "CURRENT_BRANCH=%%b"
if "%CURRENT_BRANCH%"=="" (
    echo Luodaan haara main...
    set "LAST_STEP=checkout main"
    git checkout -B main
    if errorlevel 1 (
        git checkout --orphan main
        if errorlevel 1 goto :error
    )
) else if /I not "%CURRENT_BRANCH%"=="main" (
    echo Vaihdetaan haaraan main...
    set "LAST_STEP=checkout main"
    git checkout -B main
    if errorlevel 1 goto :error
)

REM Kysy commit-viesti kayttajalta
set /p commit_message="Syota lyhyt kuvaus tekemillesi muutoksille (commit-viesti): "

echo.
echo Lisataan kaikki muuttuneet tiedostot Gitin seurantaan...
set "LAST_STEP=git add"
git add .
if errorlevel 1 goto :error

echo.
echo Tallennetaan muutokset viestilla: "%commit_message%"
set "LAST_STEP=git commit"
git commit -m "%commit_message%"
if errorlevel 1 (
    echo Ei uusia muutoksia committavaksi.
)

REM Varmista, etta committeja on olemassa ennen pushia
set "LAST_STEP=commit tarkistus"
git rev-parse --verify HEAD >nul 2>&1
if errorlevel 1 (
    echo Ei yhtaan committia loydy. Tee ensin ainakin yksi commit.
    goto :eof
)

echo.
echo Lahetetaan muutokset GitHubiin (force)...
set "LAST_STEP=git push"
git push -u origin main --force
if errorlevel 1 goto :error

echo.
echo =========================================
echo GitHub-paivitys valmis onnistuneesti!
echo =========================================
echo.
pause
goto :eof

:error
echo.
echo =========================================
echo VIRHE: GitHub-paivitys epaonnistui!
echo Tarkista ylla olevat virheilmoitukset.
echo Viimeinen vaihe: %LAST_STEP%
echo =========================================
echo.
pause
