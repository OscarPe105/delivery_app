#!/usr/bin/env python
"""
Script para crear productos de prueba para los negocios
"""
import os
import sys
import django

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'delivery_backend.settings')
django.setup()

from apps.users.models import User
from apps.businesses.models import Business
from apps.products.models import Product

def create_sample_products():
    """Crear productos de muestra para los negocios"""
    
    # Obtener los negocios
    businesses = Business.objects.all()
    
    for business in businesses:
        print(f"\nCreando productos para: {business.name}")
        
        # Productos para restaurante
        if "Restaurante" in business.name:
            products_data = [
                {
                    'name': 'Hamburguesa Clásica',
                    'description': 'Hamburguesa con carne, lechuga, tomate y queso',
                    'price': 12.99,
                    'available': True,
                    'is_popular': True
                },
                {
                    'name': 'Pollo a la Plancha',
                    'description': 'Pechuga de pollo marinada con especias',
                    'price': 15.50,
                    'available': True,
                    'is_popular': False
                },
                {
                    'name': 'Ensalada César',
                    'description': 'Lechuga romana, pollo, crutones y aderezo césar',
                    'price': 9.99,
                    'available': True,
                    'is_popular': True
                }
            ]
        
        # Productos para pizzería
        elif "Pizzería" in business.name:
            products_data = [
                {
                    'name': 'Pizza Margherita',
                    'description': 'Pizza con tomate, mozzarella y albahaca',
                    'price': 18.99,
                    'available': True,
                    'is_popular': True
                },
                {
                    'name': 'Pizza Pepperoni',
                    'description': 'Pizza con pepperoni y queso mozzarella',
                    'price': 20.99,
                    'available': True,
                    'is_popular': True
                },
                {
                    'name': 'Pizza Hawaiana',
                    'description': 'Pizza con jamón, piña y queso',
                    'price': 19.99,
                    'available': True,
                    'is_popular': False
                },
                {
                    'name': 'Lasagna',
                    'description': 'Lasagna de carne con salsa boloñesa',
                    'price': 16.50,
                    'available': True,
                    'is_popular': False
                }
            ]
        
        # Productos genéricos para otros negocios
        else:
            products_data = [
                {
                    'name': 'Producto Especial',
                    'description': 'Nuestro producto estrella',
                    'price': 14.99,
                    'available': True,
                    'is_popular': True
                },
                {
                    'name': 'Comida del Día',
                    'description': 'Plato especial preparado diariamente',
                    'price': 11.99,
                    'available': True,
                    'is_popular': False
                }
            ]
        
        # Crear los productos
        for product_data in products_data:
            product, created = Product.objects.get_or_create(
                business=business,
                name=product_data['name'],
                defaults={
                    'description': product_data['description'],
                    'price': product_data['price'],
                    'available': product_data['available'],
                    'is_popular': product_data['is_popular']
                }
            )
            if created:
                print(f"  - Producto creado: {product.name} - ${product.price}")
            else:
                print(f"  - Producto ya existe: {product.name}")

if __name__ == '__main__':
    create_sample_products()

