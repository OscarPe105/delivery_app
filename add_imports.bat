@echo off
echo ========================================
echo    AGREGANDO IMPORTS DE APPCOLORS
echo ========================================
echo.

echo Agregando import de AppColors a archivos que lo necesiten...
echo.

REM Buscar archivos que usan AppColors.primary pero no tienen el import
powershell -Command "Get-ChildItem -Path 'lib' -Recurse -Filter '*.dart' | Where-Object { (Get-Content $_.FullName) -match 'AppColors\.' -and (Get-Content $_.FullName) -notmatch 'import.*app_colors\.dart' } | ForEach-Object { $content = Get-Content $_.FullName; $importLine = 'import ''../../themes/app_colors.dart'';'; $firstImportIndex = -1; for ($i = 0; $i -lt $content.Length; $i++) { if ($content[$i] -match '^import ') { $firstImportIndex = $i; break } }; if ($firstImportIndex -ge 0) { $content = $content[0..$firstImportIndex] + $importLine + $content[($firstImportIndex+1)..($content.Length-1)]; Set-Content $_.FullName $content; Write-Host \"Agregado import a: $($_.Name)\" } }"

echo.
echo ========================================
echo    IMPORTS AGREGADOS
echo ========================================
echo.
echo Se han agregado los imports necesarios de AppColors.
echo.
echo Presiona cualquier tecla para continuar...
pause > nul
