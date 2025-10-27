#!/usr/bin/env python
"""
Script para crear datos de prueba en la base de datos
"""
import os
import sys
import django
from decimal import Decimal
from datetime import datetime, time

# Configurar Django
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'delivery_backend.settings')
django.setup()

from apps.users.models import User, Address
from apps.businesses.models import Business, Category
from apps.products.models import Product
from apps.orders.models import Order, OrderItem


def create_test_data():
    """Crear datos de prueba para el sistema"""
    
    print("Creando datos de prueba...")
    
    # 1. Crear categorías
    print("Creando categorias...")
    categories_data = [
        {'name': 'Restaurantes', 'icon': 'restaurant', 'description': 'Comida y bebidas'},
        {'name': 'Farmacias', 'icon': 'pharmacy', 'description': 'Medicamentos y productos de salud'},
        {'name': 'Supermercados', 'icon': 'store', 'description': 'Productos de consumo diario'},
        {'name': 'Librerias', 'icon': 'book', 'description': 'Libros y material educativo'},
        {'name': 'Electronicos', 'icon': 'phone', 'description': 'Dispositivos y accesorios'},
    ]
    
    categories = []
    for cat_data in categories_data:
        category, created = Category.objects.get_or_create(
            name=cat_data['name'],
            defaults=cat_data
        )
        categories.append(category)
        if created:
            print(f"  Categoria creada: {category.name}")
    
    # 2. Crear usuarios
    print("Creando usuarios...")
    
    # Usuario cliente
    customer, created = User.objects.get_or_create(
        username='cliente_test',
        defaults={
            'email': 'cliente@test.com',
            'first_name': 'Juan',
            'last_name': 'Perez',
            'user_type': 'customer',
            'phone': '+1234567890',
            'is_verified': True
        }
    )
    if created:
        customer.set_password('test123')
        customer.save()
        print(f"  Cliente creado: {customer.username}")
    
    # Usuario comerciante
    business_owner, created = User.objects.get_or_create(
        username='comerciante_test',
        defaults={
            'email': 'comerciante@test.com',
            'first_name': 'Maria',
            'last_name': 'Garcia',
            'user_type': 'business',
            'phone': '+1234567891',
            'is_verified': True
        }
    )
    if created:
        business_owner.set_password('test123')
        business_owner.save()
        print(f"  Comerciante creado: {business_owner.username}")
    
    # 3. Crear direcciones
    print("Creando direcciones...")
    
    customer_address, created = Address.objects.get_or_create(
        user=customer,
        title='Casa',
        defaults={
            'full_address': 'Calle Principal 123, Ciudad',
            'latitude': Decimal('19.4326'),
            'longitude': Decimal('-99.1332'),
            'instructions': 'Tocar timbre',
            'is_default': True
        }
    )
    if created:
        print(f"  Direccion creada para {customer.username}")
    
    # 4. Crear negocios
    print("Creando negocios...")
    
    business, created = Business.objects.get_or_create(
        name='Restaurante El Buen Sabor',
        defaults={
            'owner': business_owner,
            'category': categories[0],  # Restaurantes
            'description': 'Deliciosa comida casera y tradicional',
            'address': 'Av. Comercial 456, Ciudad',
            'phone': '+1234567892',
            'latitude': Decimal('19.4300'),
            'longitude': Decimal('-99.1300'),
            'rating': Decimal('4.5'),
            'is_active': True,
            'is_open': True,
            'opening_time': time(8, 0),
            'closing_time': time(22, 0),
            'tags': ['comida', 'casera', 'tradicional']
        }
    )
    if created:
        print(f"  Negocio creado: {business.name}")
    
    # 5. Crear productos
    print("Creando productos...")
    
    products_data = [
        {
            'name': 'Hamburguesa Clasica',
            'description': 'Hamburguesa con carne, lechuga, tomate y queso',
            'price': Decimal('15.99'),
            'available': True,
            'is_popular': True,
            'stock_quantity': 50
        },
        {
            'name': 'Pizza Margherita',
            'description': 'Pizza con tomate, mozzarella y albahaca',
            'price': Decimal('18.99'),
            'available': True,
            'is_popular': True,
            'stock_quantity': 30
        },
        {
            'name': 'Ensalada Cesar',
            'description': 'Ensalada fresca con pollo y aderezo cesar',
            'price': Decimal('12.99'),
            'available': True,
            'is_popular': False,
            'stock_quantity': 25
        },
        {
            'name': 'Refresco de Cola',
            'description': 'Bebida refrescante de cola 500ml',
            'price': Decimal('3.99'),
            'available': True,
            'is_popular': False,
            'stock_quantity': 100
        }
    ]
    
    products = []
    for prod_data in products_data:
        product, created = Product.objects.get_or_create(
            business=business,
            name=prod_data['name'],
            defaults=prod_data
        )
        products.append(product)
        if created:
            print(f"  Producto creado: {product.name}")
    
    # 6. Crear pedido de ejemplo
    print("Creando pedido de ejemplo...")
    
    order, created = Order.objects.get_or_create(
        customer=customer,
        business=business,
        delivery_address=customer_address,
        defaults={
            'status': 'pending',
            'subtotal': Decimal('34.98'),
            'delivery_fee': Decimal('5.00'),
            'tax': Decimal('4.20'),
            'total': Decimal('44.18'),
            'notes': 'Por favor entregar en la puerta principal'
        }
    )
    
    if created:
        print(f"  Pedido creado: #{order.id}")
        
        # Crear items del pedido
        order_items_data = [
            {
                'product': products[0],  # Hamburguesa
                'quantity': 1,
                'price': products[0].price,
                'notes': 'Sin cebolla'
            },
            {
                'product': products[1],  # Pizza
                'quantity': 1,
                'price': products[1].price,
                'notes': 'Extra queso'
            }
        ]
        
        for item_data in order_items_data:
            OrderItem.objects.create(
                order=order,
                **item_data
            )
            print(f"    Item agregado: {item_data['product'].name}")
    
    print("\nDatos de prueba creados exitosamente!")
    print("\nResumen:")
    print(f"  Usuarios: {User.objects.count()}")
    print(f"  Categorias: {Category.objects.count()}")
    print(f"  Negocios: {Business.objects.count()}")
    print(f"  Productos: {Product.objects.count()}")
    print(f"  Pedidos: {Order.objects.count()}")
    print(f"  Direcciones: {Address.objects.count()}")
    
    print("\nCredenciales de prueba:")
    print("  Cliente: cliente_test / test123")
    print("  Comerciante: comerciante_test / test123")
    print("  Admin: admin / admin123")


if __name__ == '__main__':
    create_test_data()