@echo off
setlocal
cd /d "%~dp0"

if exist "project.godot" (
  set "ROOT=%CD%"
) else (
  cd ..
  if exist "project.godot" (
    set "ROOT=%CD%"
  ) else (
    echo.
    echo ERROR: No encontre project.godot.
    echo Coloca este archivo BAT dentro de la carpeta raiz de CORE AWAKENED.
    echo.
    pause
    exit /b 1
  )
)

cd /d "%ROOT%"
echo.
echo CORE AWAKENED - FIX XENOID DUPLICADO
echo Proyecto: %ROOT%
echo.

if exist "patch_payload" (
  echo Eliminando carpeta temporal patch_payload...
  rmdir /s /q "patch_payload"
  echo [OK] patch_payload eliminado.
) else (
  echo [OK] No existe patch_payload. Nada que borrar.
)

echo.
echo Verificando scripts Xenoid...
if exist "scripts\xenoid.gd" (
  echo [OK] scripts\xenoid.gd sigue instalado.
) else (
  echo [AVISO] No encontre scripts\xenoid.gd.
)

echo.
echo LISTO.
echo Cierra Godot completamente y vuelve a abrir el proyecto.
echo Si Godot estaba abierto, espera a que reimporte los archivos.
echo.
pause
