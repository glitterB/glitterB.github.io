@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"
echo -----------------------------------------
echo Working directory: %cd%
echo -----------------------------------------

:: Step 1: Render Quarto site
if not exist "_site" (
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

:: Step 3: Switch to gh-pages branch safely
git fetch origin
git checkout gh-pages

:: Step 4: Remove all tracked files in gh-pages (keeps .git)
echo Cleaning old gh-pages content...
git rm -rf . >nul 2>&1

:: Step 5: Copy _site contents to gh-pages
echo Copying _site contents...
xcopy "_site\*" ".\" /E /H /K /Y

:: Step 6: Commit gh-pages (only if changes exist)
git add .
git diff-index --quiet HEAD || git commit -m "Deploy site on %DATE% %TIME%"
git push origin gh-pages --force

:: Step 7: Switch back to main branch
git checkout main

echo.
echo Deployment complete! Your gh-pages branch is updated.
pause
