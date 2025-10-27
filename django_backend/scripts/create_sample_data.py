#!/usr/bin/env python
"""
Script para crear datos de ejemplo en la base de datos
Ejecutar con: python manage.py shell < scripts/create_sample_data.py
"""

from apps.users.models import User, Address
from apps.businesses.models import Category, Business
from apps.products.models import Product
from apps.orders.models import Order, OrderItem
from decimal import Decimal
from datetime import datetime, timedelta


def create_sample_data():
    """
    Crear datos de ejemplo para la aplicación
    """
    print("Creando datos de ejemplo...")
    
    # Crear categorías
    categories_data = [
        {'name': 'Restaurantes', 'icon': 'restaurant', 'description': 'Restaurantes y comida'},
        {'name': 'Supermercados', 'icon': 'store', 'description': 'Supermercados y despensas'},
        {'name': 'Farmacias', 'icon': 'local_pharmacy', 'description': 'Farmacias y medicamentos'},
        {'name': 'Electrónicos', 'icon': 'devices', 'description': 'Electrónicos y tecnología'},
        {'name': 'Ropa', 'icon': 'checkroom', 'description': 'Ropa y accesorios'},
    ]
    
    categories = []
    for cat_data in categories_data:
        category, created = Category.objects.get_or_create(
            name=cat_data['name'],
            defaults=cat_data
        )
        categories.append(category)
        if created:
            print(f"Creada categoría: {category.name}")
    
    # Crear usuarios de ejemplo
    users_data = [
        {
            'username': 'cliente1',
            'email': 'cliente1@example.com',
            'first_name': 'Juan',
            'last_name': 'Pérez',
            'phone': '+1234567890',
            'user_type': 'customer'
        },
        {
            'username': 'comerciante1',
            'email': 'comerciante1@example.com',
            'first_name': 'María',
            'last_name': 'González',
            'phone': '+1234567891',
            'user_type': 'business'
        },
        {
            'username': 'comerciante2',
            'email': 'comerciante2@example.com',
            'first_name': 'Carlos',
            'last_name': 'López',
            'phone': '+1234567892',
            'user_type': 'business'
        }
    ]
    
    users = []
    for user_data in users_data:
        user, created = User.objects.get_or_create(
            username=user_data['username'],
            defaults=user_data
        )
        if created:
            user.set_password('password123')
            user.save()
            print(f"Creado usuario: {user.username}")
        users.append(user)
    
    # Crear direcciones para el cliente
    client = users[0]
    addresses_data = [
        {
            'title': 'Casa',
            'full_address': 'Calle Principal 123, Ciudad',
            'latitude': Decimal('19.4326'),
            'longitude': Decimal('-99.1332'),
            'is_default': True
        },
        {
            'title': 'Trabajo',
            'full_address': 'Avenida Central 456, Ciudad',
            'latitude': Decimal('19.4226'),
            'longitude': Decimal('-99.1432'),
            'is_default': False
        }
    ]
    
    for addr_data in addresses_data:
        address, created = Address.objects.get_or_create(
            user=client,
            title=addr_data['title'],
            defaults=addr_data
        )
        if created:
            print(f"Creada dirección: {address.title}")
    
    # Crear negocios
    businesses_data = [
        {
            'name': 'Restaurante El Buen Sabor',
            'category': categories[0],
            'description': 'Comida mexicana tradicional',
            'address': 'Calle de la Comida 100, Ciudad',
            'phone': '+1234567893',
            'latitude': Decimal('19.4426'),
            'longitude': Decimal('-99.1532'),
            'opening_time': '08:00',
            'closing_time': '22:00'
        },
        {
            'name': 'Supermercado La Economía',
            'category': categories[1],
            'description': 'Supermercado con productos frescos',
            'address': 'Avenida Comercial 200, Ciudad',
            'phone': '+1234567894',
            'latitude': Decimal('19.4526'),
            'longitude': Decimal('-99.1632'),
            'opening_time': '06:00',
            'closing_time': '23:00'
        }
    ]
    
    businesses = []
    for business_data in businesses_data:
        business_data['owner'] = users[1] if len(businesses) == 0 else users[2]
        business, created = Business.objects.get_or_create(
            name=business_data['name'],
            defaults=business_data
        )
        businesses.append(business)
        if created:
            print(f"Creado negocio: {business.name}")
    
    # Crear productos
    products_data = [
        {
            'name': 'Tacos al Pastor',
            'description': 'Deliciosos tacos con carne al pastor',
            'price': Decimal('15.00'),
            'business': businesses[0],
            'is_popular': True
        },
        {
            'name': 'Quesadillas',
            'description': 'Quesadillas con queso Oaxaca',
            'price': Decimal('12.00'),
            'business': businesses[0],
            'is_popular': False
        },
        {
            'name': 'Leche Entera',
            'description': 'Leche fresca 1 litro',
            'price': Decimal('25.00'),
            'business': businesses[1],
            'is_popular': True
        },
        {
            'name': 'Pan Integral',
            'description': 'Pan integral artesanal',
            'price': Decimal('18.00'),
            'business': businesses[1],
            'is_popular': False
        }
    ]
    
    for product_data in products_data:
        product, created = Product.objects.get_or_create(
            name=product_data['name'],
            business=product_data['business'],
            defaults=product_data
        )
        if created:
            print(f"Creado producto: {product.name}")
    
    print("Datos de ejemplo creados exitosamente!")


if __name__ == '__main__':
    create_sample_data()
