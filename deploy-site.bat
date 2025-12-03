@echo off
setlocal enabledelayedexpansion

:: Move to script directory
cd /d "%~dp0"
echo Working directory: %cd%

:: Step 1: Render the site
if not exist "_site" (
    echo ❌ _site folder does not exist. Did Quarto render?
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

:: Step 2: Commit main branch changes (only if changes exist)
echo Committing source files to main branch...
git add .
git diff-index --quiet HEAD || git commit -m "Update source files on %DATE% %TIME%"
git push origin main

:: Step 3: Switch to gh-pages branch
git checkout gh-pages

:: Step 4: Delete all files except .git
echo Cleaning old site files...
for /d %%D in (*) do (
    if /I not "%%D"==".git" rd /s /q "%%D"
)
for %%F in (*) do (
    if /I not "%%F"==".git" del /q "%%F"
)

:: Step 5: Copy _site contents to gh-pages
echo Copying new site files...
xcopy "_site\*" ".\" /E /H /K /Y

:: Step 6: Commit gh-pages only if changes exist
git add .
git diff-index --quiet HEAD || git commit -m "Deploy site on %DATE% %TIME%"
git push origin gh-pages --force

:: Step 7: Switch back to main
git checkout main

echo Deployment complete!
pause
