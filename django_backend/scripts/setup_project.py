#!/usr/bin/env python
"""
Script para configurar el proyecto Django
Ejecutar con: python manage.py shell < scripts/setup_project.py
"""

import os
from django.core.management import execute_from_command_line
from django.conf import settings


def setup_project():
    """
    Configurar el proyecto Django con migraciones y datos iniciales
    """
    print("Configurando proyecto Django...")
    
    # Crear directorios necesarios
    os.makedirs('media', exist_ok=True)
    os.makedirs('staticfiles', exist_ok=True)
    os.makedirs('logs', exist_ok=True)
    
    print("Directorios creados exitosamente!")
    print("\nPara continuar con la configuración, ejecuta:")
    print("1. python manage.py makemigrations")
    print("2. python manage.py migrate")
    print("3. python manage.py createsuperuser")
    print("4. python manage.py runserver")


if __name__ == '__main__':
    setup_project()
