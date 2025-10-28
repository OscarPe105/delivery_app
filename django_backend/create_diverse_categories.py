#!/usr/bin/env python
"""
Script para crear categorías diversas de negocios
"""
import os
import sys
import django

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'delivery_backend.settings')
django.setup()

from apps.businesses.models import Category

def create_diverse_categories():
    """Crear categorías diversas para diferentes tipos de negocios"""
    
    categories_data = [
        # Comida y Restaurantes
        {'name': 'Restaurante', 'icon': 'restaurant', 'description': 'Restaurantes y comida tradicional'},
        {'name': 'Cafetería', 'icon': 'local_cafe', 'description': 'Cafeterías y bebidas calientes'},
        {'name': 'Pizzería', 'icon': 'local_pizza', 'description': 'Pizzerías y comida italiana'},
        {'name': 'Comida Rápida', 'icon': 'fastfood', 'description': 'Comida rápida y snacks'},
        {'name': 'Postres', 'icon': 'cake', 'description': 'Postres y dulces'},
        {'name': 'Bebidas', 'icon': 'local_bar', 'description': 'Bebidas y refrescos'},
        
        # Supermercados y Abarrotes
        {'name': 'Supermercado', 'icon': 'store', 'description': 'Supermercados y tiendas grandes'},
        {'name': 'Abarrotes', 'icon': 'shopping_cart', 'description': 'Tiendas de abarrotes y despensa'},
        {'name': 'Frutas y Verduras', 'icon': 'eco', 'description': 'Frutas, verduras y productos frescos'},
        {'name': 'Carnicería', 'icon': 'restaurant_menu', 'description': 'Carnes y productos cárnicos'},
        {'name': 'Panadería', 'icon': 'bakery_dining', 'description': 'Panes y productos de panadería'},
        
        # Salud y Farmacia
        {'name': 'Farmacia', 'icon': 'local_pharmacy', 'description': 'Farmacias y medicamentos'},
        {'name': 'Óptica', 'icon': 'visibility', 'description': 'Ópticas y lentes'},
        {'name': 'Laboratorio', 'icon': 'science', 'description': 'Laboratorios médicos'},
        
        # Tecnología y Electrónicos
        {'name': 'Electrónicos', 'icon': 'devices', 'description': 'Electrónicos y tecnología'},
        {'name': 'Computadoras', 'icon': 'computer', 'description': 'Computadoras y accesorios'},
        {'name': 'Teléfonos', 'icon': 'phone_android', 'description': 'Teléfonos y accesorios móviles'},
        {'name': 'Reparaciones', 'icon': 'build', 'description': 'Reparaciones técnicas'},
        
        # Moda y Accesorios
        {'name': 'Ropa', 'icon': 'checkroom', 'description': 'Ropa y vestimenta'},
        {'name': 'Calzado', 'icon': 'directions_walk', 'description': 'Zapatos y calzado'},
        {'name': 'Joyería', 'icon': 'diamond', 'description': 'Joyas y accesorios'},
        {'name': 'Relojes', 'icon': 'schedule', 'description': 'Relojes y accesorios de tiempo'},
        
        # Hogar y Decoración
        {'name': 'Hogar', 'icon': 'home', 'description': 'Productos para el hogar'},
        {'name': 'Decoración', 'icon': 'palette', 'description': 'Decoración y arte'},
        {'name': 'Muebles', 'icon': 'chair', 'description': 'Muebles y mobiliario'},
        {'name': 'Jardín', 'icon': 'yard', 'description': 'Jardinería y plantas'},
        
        # Ferretería y Construcción
        {'name': 'Ferretería', 'icon': 'handyman', 'description': 'Herramientas y materiales'},
        {'name': 'Construcción', 'icon': 'construction', 'description': 'Materiales de construcción'},
        {'name': 'Plomería', 'icon': 'plumbing', 'description': 'Servicios de plomería'},
        {'name': 'Electricidad', 'icon': 'electrical_services', 'description': 'Servicios eléctricos'},
        
        # Automotriz
        {'name': 'Automotriz', 'icon': 'directions_car', 'description': 'Repuestos y servicios automotrices'},
        {'name': 'Taller', 'icon': 'garage', 'description': 'Talleres mecánicos'},
        {'name': 'Gasolinera', 'icon': 'local_gas_station', 'description': 'Gasolineras y combustibles'},
        
        # Belleza y Cuidado Personal
        {'name': 'Belleza', 'icon': 'face', 'description': 'Productos de belleza'},
        {'name': 'Salón', 'icon': 'content_cut', 'description': 'Salones de belleza'},
        {'name': 'Spa', 'icon': 'spa', 'description': 'Spas y relajación'},
        {'name': 'Gimnasio', 'icon': 'fitness_center', 'description': 'Gimnasios y fitness'},
        
        # Servicios Profesionales
        {'name': 'Abogados', 'icon': 'gavel', 'description': 'Servicios legales'},
        {'name': 'Contadores', 'icon': 'calculate', 'description': 'Servicios contables'},
        {'name': 'Seguros', 'icon': 'security', 'description': 'Seguros y asesoría'},
        {'name': 'Inmobiliaria', 'icon': 'home_work', 'description': 'Inmobiliarias'},
        
        # Educación y Entretenimiento
        {'name': 'Educación', 'icon': 'school', 'description': 'Centros educativos'},
        {'name': 'Librería', 'icon': 'menu_book', 'description': 'Librerías y libros'},
        {'name': 'Juguetes', 'icon': 'toys', 'description': 'Juguetes y entretenimiento'},
        {'name': 'Deportes', 'icon': 'sports', 'description': 'Artículos deportivos'},
        
        # Otros Servicios
        {'name': 'Lavandería', 'icon': 'local_laundry_service', 'description': 'Lavanderías y tintorerías'},
        {'name': 'Fotografía', 'icon': 'camera_alt', 'description': 'Servicios fotográficos'},
        {'name': 'Impresiones', 'icon': 'print', 'description': 'Servicios de impresión'},
        {'name': 'Otro', 'icon': 'more_horiz', 'description': 'Otras categorías'},
    ]
    
    print("Creando categorías diversas...")
    
    for cat_data in categories_data:
        category, created = Category.objects.get_or_create(
            name=cat_data['name'],
            defaults=cat_data
        )
        if created:
            print(f"  - Categoría creada: {category.name}")
        else:
            print(f"  - Categoría ya existe: {category.name}")
    
    print(f"\nTotal de categorías disponibles: {Category.objects.count()}")

if __name__ == '__main__':
    create_diverse_categories()

