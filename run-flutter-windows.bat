@echo off
echo 🚀 Ejecutando aplicación Flutter POS...
echo 📍 Cambiando al directorio del proyecto...

cd /d "C:\Users\carlo\proyectos_flutter\posmobil"

echo 📂 Directorio actual: %CD%

if not exist "pubspec.yaml" (
    echo ❌ Error: No se encuentra pubspec.yaml en el directorio actual
    pause
    exit /b 1
)

echo ✅ Archivo pubspec.yaml encontrado
echo 🔍 Verificando dispositivos disponibles...

flutter devices

echo.
echo 🚀 Iniciando aplicación en Windows...
flutter run -d windows

echo.
echo 👋 Aplicación cerrada
pause