@echo off
echo ========================================
echo  JURIS HONORIS - Setup inicial
echo ========================================
echo.

:: Verificar Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter no esta instalado.
    echo Descargalo en: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

echo [1/3] Instalando dependencias...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: flutter pub get fallo.
    pause
    exit /b 1
)

echo.
echo [2/3] Creando archivos de plataforma (Android/iOS)...
flutter create . --project-name juris_honoris --org com.jurish --platforms android,ios
if %errorlevel% neq 0 (
    echo ADVERTENCIA: No se pudieron crear archivos de plataforma.
    echo Esto es normal si ya existen.
)

echo.
echo [3/3] Verificando el proyecto...
flutter analyze --no-fatal-infos
echo.
echo ========================================
echo  Setup completado!
echo  Para ejecutar: flutter run
echo ========================================
pause
