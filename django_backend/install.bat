@echo off
REM Script de instalación para Windows
echo 🚀 Instalando backend Django para Delivery App...

REM Verificar si Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python no está instalado. Por favor instala Python 3.9 o superior.
    pause
    exit /b 1
)

REM Crear entorno virtual
echo 📦 Creando entorno virtual...
python -m venv venv

REM Activar entorno virtual
echo 🔧 Activando entorno virtual...
call venv\Scripts\activate.bat

REM Actualizar pip
echo ⬆️ Actualizando pip...
python -m pip install --upgrade pip

REM Instalar dependencias
echo 📚 Instalando dependencias...
pip install -r requirements.txt

REM Crear directorios necesarios
echo 📁 Creando directorios...
if not exist media mkdir media
if not exist staticfiles mkdir staticfiles
if not exist logs mkdir logs

REM Configurar variables de entorno
echo ⚙️ Configurando variables de entorno...
if not exist .env (
    copy env_example.txt .env
    echo ✅ Archivo .env creado. Por favor edita las variables según tu configuración.
)

REM Ejecutar migraciones
echo 🗄️ Ejecutando migraciones...
python manage.py makemigrations
python manage.py migrate

REM Crear superusuario
echo 👤 Creando superusuario...
python manage.py createsuperuser

echo ✅ Instalación completada!
echo.
echo Para ejecutar el servidor:
echo 1. Activa el entorno virtual: venv\Scripts\activate.bat
echo 2. Ejecuta el servidor: python manage.py runserver
echo.
echo Para crear datos de ejemplo:
echo python manage.py shell ^< scripts\create_sample_data.py
pause
