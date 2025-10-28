@echo off
echo ========================================
echo    ACTUALIZANDO COLORES DE LA APP
echo ========================================
echo.

echo Reemplazando colores hardcodeados con AppColors.primary...
echo.

REM Buscar y reemplazar en archivos Dart
powershell -Command "Get-ChildItem -Path 'lib' -Recurse -Filter '*.dart' | ForEach-Object { (Get-Content $_.FullName) -replace 'const Color\(0xFFE8B86D\)', 'AppColors.primary' | Set-Content $_.FullName }"

powershell -Command "Get-ChildItem -Path 'lib' -Recurse -Filter '*.dart' | ForEach-Object { (Get-Content $_.FullName) -replace 'Color\(0xFFE8B86D\)', 'AppColors.primary' | Set-Content $_.FullName }"

powershell -Command "Get-ChildItem -Path 'lib' -Recurse -Filter '*.dart' | ForEach-Object { (Get-Content $_.FullName) -replace 'Color\(0xFFD4A574\)', 'AppColors.primaryDark' | Set-Content $_.FullName }"

echo.
echo ========================================
echo    COLORES ACTUALIZADOS
echo ========================================
echo.
echo Se han reemplazado los colores hardcodeados con AppColors.primary
echo en todos los archivos Dart de la aplicación.
echo.
echo Presiona cualquier tecla para continuar...
pause > nul
