@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo Rendering site...
quarto render

echo Committing main branch...
git add .
git commit -m "Update source files on %DATE% %TIME%" 2>nul
git push origin main

echo Switching to gh-pages...
git checkout gh-pages

echo Removing old files...
rem (skip deletion temporarily to see what exists)

echo Copying new files...
xcopy "_site\*" ".\" /E /H /K /Y

echo Committing gh-pages...
git add .
git commit -m "Deploy site on %DATE% %TIME%" 2>nul
git push origin gh-pages --force

echo Switching back to main...
git checkout main

echo Deployment Complete!
pause
