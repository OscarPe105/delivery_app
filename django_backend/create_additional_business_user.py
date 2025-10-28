#!/usr/bin/env python
"""
Script para crear usuario adicional de negocio para pruebas
"""
import os
import sys
import django

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'delivery_backend.settings')
django.setup()

from apps.users.models import User
from apps.businesses.models import Business, Category

def create_additional_business_user():
    """Crear usuario adicional de negocio"""
    
    # Crear usuario comerciante adicional
    business_owner, created = User.objects.get_or_create(
        username='negocio_test2',
        defaults={
            'email': 'negocio2@delivery.com',
            'first_name': 'Carlos',
            'last_name': 'Restaurante',
            'user_type': 'business',
            'phone': '+1234567892',
            'is_verified': True
        }
    )
    if created:
        business_owner.set_password('test123')
        business_owner.save()
        print(f"Comerciante creado: {business_owner.username} ({business_owner.email}) - Tipo: {business_owner.user_type}")
    else:
        print(f"Comerciante ya existe: {business_owner.username} ({business_owner.email}) - Tipo: {business_owner.user_type}")
    
    # Crear categoría si no existe
    category, _ = Category.objects.get_or_create(
        name='Pizzería',
        defaults={
            'icon': 'local_pizza',
            'description': 'Pizzerías y comida italiana'
        }
    )
    
    # Crear negocio para el usuario
    business, created = Business.objects.get_or_create(
        owner=business_owner,
        defaults={
            'name': 'Pizzería Carlos',
            'description': 'Las mejores pizzas de la ciudad',
            'address': 'Av. Principal 456, Centro',
            'phone': '+1234567892',
            'category': category,
            'is_active': True,
            'is_open': True,
            'rating': 4.5
        }
    )
    if created:
        print(f"Negocio creado: {business.name}")
    else:
        print(f"Negocio ya existe: {business.name}")
    
    print("\nCredenciales del nuevo usuario de negocio:")
    print("Email: negocio2@delivery.com")
    print("Contraseña: test123")
    print(f"Negocio: {business.name}")

if __name__ == '__main__':
    create_additional_business_user()

