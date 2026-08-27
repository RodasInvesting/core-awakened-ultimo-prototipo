@echo off
setlocal
cd /d "%~dp0"

if not exist "project.godot" (
  echo.
  echo ERROR: Este archivo debe estar en la RAIZ de CORE AWAKENED,
  echo en la misma carpeta donde esta project.godot.
  echo.
  pause
  exit /b 1
)

echo ==========================================================
echo  CORE AWAKENED - RECUPERACION LIMPIA
echo ==========================================================
echo.

if not exist "scripts" mkdir "scripts"

if exist "scripts\fighter.gd" copy /Y "scripts\fighter.gd" "scripts\fighter.ANTES_DEL_RESCATE.gd.bak" >nul
if exist "scripts\xenoid.gd" copy /Y "scripts\xenoid.gd" "scripts\xenoid.ANTES_DEL_RESCATE.gd.bak" >nul

echo [1/3] Restaurando Fighter OFICIAL desde tu GitHub...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$u='https://raw.githubusercontent.com/RodasInvesting/core-awakened-ultimo-prototipo/refs/heads/main/scripts/fighter.gd'; Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile 'scripts\fighter.gd'; $t=[IO.File]::ReadAllText('scripts\fighter.gd'); if(-not $t.Contains('class_name Fighter') -or -not $t.Contains('ALTURA_VISIBLE_NORMAL_GLOBAL') -or -not $t.Contains('var textura_carrera: Texture2D = null')){ throw 'La descarga del Fighter no es valida.' }"

if errorlevel 1 (
  echo.
  echo ERROR: No pude descargar/validar el Fighter oficial.
  echo Se conserva el backup scripts\fighter.ANTES_DEL_RESCATE.gd.bak
  echo.
  pause
  exit /b 1
)

echo [2/3] Instalando Xenoid compatible...
copy /Y "%~dp0scripts\xenoid.gd" "scripts\xenoid.gd" >nul

echo [3/3] Limpiando cache de scripts de Godot...
if exist ".godot" (
  rmdir /S /Q ".godot"
)

echo.
echo ==========================================================
echo  RECUPERACION TERMINADA
echo ==========================================================
echo.
echo NO se tocaron:
echo - assets
echo - Kai
echo - Jester
echo - GameState
echo - main.gd
echo - selector
echo - CORE
echo.
echo Ahora abre project.godot y espera la reimportacion.
echo Prueba: PARADO - CAMINAR - PUNO - PATADA - SALTO.
echo.
pause
endlocal
