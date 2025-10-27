#!/usr/bin/env python
import os
import sys
import django

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'delivery_backend.settings')
django.setup()

from django.contrib.auth import get_user_model

def setup_admin():
    User = get_user_model()
    
    try:
        admin = User.objects.get(username='admin')
        admin.set_password('admin123')
        admin.save()
        print('Contraseña del admin configurada correctamente')
        print('Usuario: admin')
        print('Contraseña: admin123')
    except User.DoesNotExist:
        print('Usuario admin no encontrado')
    except Exception as e:
        print(f'Error: {e}')

if __name__ == '__main__':
    setup_admin()
