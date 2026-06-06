@echo off
REM ============================================
REM ⚡ Quick Launch: Frontend Update
REM ============================================
REM Double-click this file for quick update!

echo.
echo ============================================
echo   NEXO QUICK UPDATE
echo ============================================
echo.

cd /d "%~dp0"

powershell.exe -ExecutionPolicy Bypass -File ".\quick-update.ps1"

pause
