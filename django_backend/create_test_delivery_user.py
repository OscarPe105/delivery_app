#!/usr/bin/env python
"""
Script para crear usuario de prueba test@delivery
"""
import os
import sys
import django

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'delivery_backend.settings')
django.setup()

from apps.users.models import User

def create_test_user():
    """Crear usuario test@delivery"""
    
    # Crear usuario cliente
    customer, created = User.objects.get_or_create(
        username='test_customer',
        defaults={
            'email': 'test@delivery.com',
            'first_name': 'Test',
            'last_name': 'Customer',
            'user_type': 'customer',
            'phone': '+1234567890',
            'is_verified': True
        }
    )
    if created:
        customer.set_password('test123')
        customer.save()
        print(f"Cliente creado: {customer.username} ({customer.email}) - Tipo: {customer.user_type}")
    else:
        print(f"Cliente ya existe: {customer.username} ({customer.email}) - Tipo: {customer.user_type}")
    
    # Crear usuario comerciante
    business_owner, created = User.objects.get_or_create(
        username='test_business',
        defaults={
            'email': 'business@delivery.com',
            'first_name': 'Test',
            'last_name': 'Business',
            'user_type': 'business',
            'phone': '+1234567891',
            'is_verified': True
        }
    )
    if created:
        business_owner.set_password('test123')
        business_owner.save()
        print(f"Comerciante creado: {business_owner.username} ({business_owner.email}) - Tipo: {business_owner.user_type}")
    else:
        print(f"Comerciante ya existe: {business_owner.username} ({business_owner.email}) - Tipo: {business_owner.user_type}")
    
    print("\nCredenciales de prueba:")
    print("Cliente: test@delivery.com / test123")
    print("Comerciante: business@delivery.com / test123")

if __name__ == '__main__':
    create_test_user()
