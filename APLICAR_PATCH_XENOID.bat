@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0APLICAR_PATCH_XENOID.ps1"
echo.
pause
