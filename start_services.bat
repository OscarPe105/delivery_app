@echo off
echo ========================================
echo    LEVANTANDO DELIVERY APP (Flutter)
echo ========================================
echo.

echo Iniciando Frontend Flutter...
start "Flutter Frontend" cmd /k "flutter run -d chrome --web-port=8080"

echo.
echo ========================================
echo    SERVICIO INICIADO
echo ========================================
echo.
echo Frontend Flutter: http://localhost:8080
echo.
echo Presiona cualquier tecla para continuar...
pause > nul
