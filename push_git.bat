@echo off
setlocal EnableExtensions

REM ==== CONFIG ====
set "REPO_NAME=cybertarot"
set "GITHUB_USER=feckom"
set "REMOTE=https://github.com/%GITHUB_USER%/%REPO_NAME%.git"

echo.
echo === Checking Git ===
where git >nul 2>nul || (echo [ERROR] Git not found & exit /b 1)

echo.
echo === Trust current directory (safe.directory) ===
git config --global --add safe.directory "%CD%" >nul 2>nul

echo.
echo === Ensure identity ===
for /f "usebackq delims=" %%A in (`git config user.email 2^>nul`) do set "CFG_EMAIL=%%A"
for /f "usebackq delims=" %%A in (`git config user.name  2^>nul`) do set "CFG_NAME=%%A"
if "%CFG_EMAIL%"=="" echo [ERROR] Missing user.email. Run: git config --global user.email "tvoj.email@example.com" & exit /b 1
if "%CFG_NAME%"==""  echo [ERROR] Missing user.name.  Run: git config --global user.name  "Michal Fecko"       & exit /b 1
echo [OK] user.name=%CFG_NAME%, user.email=%CFG_EMAIL%

echo.
echo === Init repo / main branch ===
if not exist ".git" git init
git rev-parse --abbrev-ref HEAD >nul 2>nul || git checkout -b main
git branch -M main

echo.
echo === Stage + commit ===
git add -A
git diff --cached --quiet && git commit --allow-empty -m "Bootstrap commit" || git commit -m "Initial commit"

echo.
echo === Set remote 'origin' ===
echo [INFO] origin URL: %REMOTE%
git remote remove origin 2>nul
git remote add origin "%REMOTE%"

echo.
echo === Push ===
git push -u origin main
if errorlevel 1 (
  echo.
  echo [ERROR] Push failed.
  echo   - Pri HTTPS + 2FA pouzi Personal Access Token ako heslo (scope: repo).
  echo   - Skontroluj opravnenia k repo: https://github.com/%GITHUB_USER%/%REPO_NAME%
  echo   - Alebo pouzi: gh auth login  (ak mas GitHub CLI)
  exit /b 1
)

echo.
echo =====================================================
echo Pushed to: https://github.com/%GITHUB_USER%/%REPO_NAME%
echo =====================================================
endlocal
