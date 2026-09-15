@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0APLICAR_VIRGILIO_91.04.00_PASS1C.ps1"
if errorlevel 1 (
  echo.
  echo ERROR PASS 1C. NO ABRAS GODOT. MANDA CAPTURA.
  pause
  exit /b 1
)
echo.
echo PASS 1C COMPLETADO. YA PODES ABRIR GODOT.
pause
