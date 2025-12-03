@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"
echo -----------------------------------------
echo Working directory: %cd%
echo -----------------------------------------

:: Step 1: Render Quarto site
if not exist "docs" (
    echo ❌ _site folder does not exist. Please run Quarto render.
    pause
    exit /b 1
)
echo Rendering site...
quarto render
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Quarto render failed.
    pause
    exit /b 1
)

:: Step 2: Commit changes to main branch (if any)
echo Committing main branch changes...
git add .
git diff-index --quiet HEAD || git commit -m "Update source files on %DATE% %TIME%"
git push origin main

echo.
echo Deployment complete! Your gh-pages branch is updated.
pause
