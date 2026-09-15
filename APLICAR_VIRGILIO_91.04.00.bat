@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0APLICAR_VIRGILIO_91.04.00.ps1"
set ERR=%ERRORLEVEL%
echo.
if not "%ERR%"=="0" (
  echo ERROR AL INTEGRAR VIRGILIO. NO ABRAS GODOT TODAVIA.
) else (
  echo PASS 1B COMPLETADO. YA PODES ABRIR GODOT.
)
echo.
pause
exit /b %ERR%
