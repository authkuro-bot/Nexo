@echo off
REM ============================================
REM 🚀 Quick Launch: Full Deployment
REM ============================================
REM Double-click this file to deploy!

echo.
echo ============================================
echo   NEXO DEPLOYMENT LAUNCHER
echo ============================================
echo.

cd /d "%~dp0"

powershell.exe -ExecutionPolicy Bypass -File ".\deploy-complete.ps1"

pause
