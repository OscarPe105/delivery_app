#!/bin/bash

# Script de instalación para el backend Django
echo "🚀 Instalando backend Django para Delivery App..."

# Verificar si Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 no está instalado. Por favor instala Python 3.9 o superior."
    exit 1
fi

# Verificar si pip está instalado
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 no está instalado. Por favor instala pip3."
    exit 1
fi

# Crear entorno virtual
echo "📦 Creando entorno virtual..."
python3 -m venv venv

# Activar entorno virtual
echo "🔧 Activando entorno virtual..."
source venv/bin/activate

# Actualizar pip
echo "⬆️ Actualizando pip..."
pip install --upgrade pip

# Instalar dependencias
echo "📚 Instalando dependencias..."
pip install -r requirements.txt

# Crear directorios necesarios
echo "📁 Creando directorios..."
mkdir -p media staticfiles logs

# Configurar variables de entorno
echo "⚙️ Configurando variables de entorno..."
if [ ! -f .env ]; then
    cp env_example.txt .env
    echo "✅ Archivo .env creado. Por favor edita las variables según tu configuración."
fi

# Ejecutar migraciones
echo "🗄️ Ejecutando migraciones..."
python manage.py makemigrations
python manage.py migrate

# Crear superusuario
echo "👤 Creando superusuario..."
python manage.py createsuperuser

echo "✅ Instalación completada!"
echo ""
echo "Para ejecutar el servidor:"
echo "1. Activa el entorno virtual: source venv/bin/activate"
echo "2. Ejecuta el servidor: python manage.py runserver"
echo ""
echo "Para crear datos de ejemplo:"
echo "python manage.py shell < scripts/create_sample_data.py"
