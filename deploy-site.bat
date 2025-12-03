@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo -----------------------------------------
echo Working directory: %cd%
echo -----------------------------------------

echo Rendering site...
quarto render
IF %ERRORLEVEL% NEQ 0 (
    echo ❌ Quarto render failed.
    pause
    exit /b 1
)

echo Committing source files to main branch...
git add .
git commit -m "Update source files on %DATE% %TIME%" 2>nul
git push origin main

echo Switching to gh-pages branch...
git checkout gh-pages

echo Cleaning old site files (excluding .git)...
for /d %%D in (*) do (
    if /I not "%%D"==".git" rd /s /q "%%D"
)
for %%F in (*) do (
    if /I not "%%F"==".git" del /q "%%F"
)

echo Copying new site files...
xcopy "_site\*" ".\" /E /H /K /Y

echo Committing built site to gh-pages...
git add .
git commit -m "Deploy site on %DATE% %TIME%" 2>nul
git push origin gh-pages --force

echo Switching back to main branch...
git checkout main

echo Deployment complete!
pause
