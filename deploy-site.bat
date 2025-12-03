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

echo.
echo Committing source files to main branch...
git add .
git commit -m "Update source files on %DATE% %TIME%"
git push origin main
IF %ERRORLEVEL% NEQ 0 (
    echo ❌ Git push to main branch failed.
    pause
    exit /b 1
)

echo.
echo Switching to gh-pages branch...
git checkout gh-pages

echo Cleaning old site files...
for /f %%f in ('dir /b') do (
    del /q "%%f" 2>nul
    rd /s /q "%%f" 2>nul
)

echo Copying new site files...
xcopy ".\_site\*" ".\" /E /H /C /Y >nul

echo Committing built site to gh-pages...
git add .
git commit -m "Deploy site on %DATE% %TIME%"
git push origin gh-pages --force
IF %ERRORLEVEL% NEQ 0 (
    echo ❌ Git push to gh-pages failed.
    git checkout main
    pause
    exit /b 1
)

echo.
echo Switching back to main branch...
git checkout main

echo.
echo 🎉 Deployment complete!
pause
