@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0APLICAR_VIRGILIO_91.04.00_PASS1F.ps1"
if errorlevel 1 (
  echo.
  echo ERROR PASS 1F. NO ABRAS GODOT. MANDA CAPTURA.
  pause
  exit /b 1
)
echo.
echo PASS 1F COMPLETADO. YA PODES ABRIR GODOT.
pause
