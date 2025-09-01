@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM === Publish project to GitHub (account: feckom) ===
set REPO_NAME=cybertarot
set GITHUB_USER=feckom
set REMOTE_HTTPS=https://github.com/%GITHUB_USER%/%REPO_NAME%.git

echo:
echo === Checking prerequisites ===
where git >nul 2>nul || (echo [ERROR] Git not found. Install from https://git-scm.com/download/win & exit /b 1)

echo:
echo === Trusting this working directory (safe.directory) ===
REM Add current path
git config --global --add safe.directory "%CD%"

REM Try to resolve UNC path via PowerShell; ignore errors
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command ^
  "try { (Resolve-Path .).ProviderPath } catch { '' }"`) do set UNC_PATH=%%I
if defined UNC_PATH (
  git config --global --add safe.directory "%UNC_PATH%"
  echo [OK] Added safe.directory: %UNC_PATH%
) else (
  echo [INFO] UNC path not resolved; continuing with %CD%.
)

echo:
echo === Initializing local repository ===
if not exist ".git" (
  echo [INFO] Initializing new repo...
  git init || (echo [ERROR] git init failed & exit /b 1)
) else (
  echo [OK] Git repo already initialized.
)

REM Ensure main branch
git rev-parse --abbrev-ref HEAD >nul 2>nul
if errorlevel 1 (
  echo [INFO] Creating main branch...
  git checkout -b main || (echo [ERROR] Cannot create main branch & exit /b 1)
) else (
  git branch -M main || (echo [ERROR] Cannot rename branch to main & exit /b 1)
)

echo:
echo === Staging and committing ===
git add -A
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "Initial commit"
) else (
  git commit --allow-empty -m "Bootstrap commit"
)

echo:
echo === Configuring remote 'origin' ===
git remote get-url origin >nul 2>nul
if errorlevel 1 (
  git remote add origin %REMOTE_HTTPS% || (echo [ERROR] Cannot add origin & exit /b 1)
  echo [OK] origin -> %REMOTE_HTTPS%
) else (
  git remote set-url origin %REMOTE_HTTPS% || (echo [ERROR] Cannot set origin URL & exit /b 1)
  echo [OK] origin updated -> %REMOTE_HTTPS%
)

echo:
echo === Pushing to GitHub ===
git push -u origin main || (
  echo.
  echo [ERROR] Push failed.
  echo   - Over HTTPS + 2FA použi Personal Access Token ako heslo (scope: repo).
  echo   - Alebo prihlas GitHub CLI: ^gh auth login^ a pouzi SSH/HTTPS credential manager.
  exit /b 1
)

echo:
echo =====================================================
echo Pushed to: https://github.com/%GITHUB_USER%/%REPO_NAME%
echo =====================================================
endlocal
