#!/usr/bin/env python
"""
Script para actualizar negocios existentes con categorías principales
"""
import os
import sys
import django

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'delivery_backend.settings')
django.setup()

from apps.businesses.models import Business, Category

def update_business_categories():
    """Actualizar negocios existentes con categorías principales"""
    
    # Mapeo de subcategorías a categorías principales
    category_mapping = {
        # Comida
        'Restaurante': 'food',
        'Cafetería': 'food',
        'Pizzería': 'food',
        'Comida Rápida': 'food',
        'Postres': 'food',
        'Bebidas': 'food',
        'Carnicería': 'food',
        'Panadería': 'food',
        
        # Supermercados
        'Supermercado': 'groceries',
        'Abarrotes': 'groceries',
        'Frutas y Verduras': 'groceries',
        
        # Farmacias
        'Farmacia': 'pharmacy',
        'Óptica': 'pharmacy',
        'Laboratorio': 'pharmacy',
        
        # Electrónicos
        'Electrónicos': 'electronics',
        'Computadoras': 'electronics',
        'Teléfonos': 'electronics',
        'Reparaciones': 'electronics',
        
        # Moda
        'Ropa': 'fashion',
        'Calzado': 'fashion',
        'Joyería': 'fashion',
        'Relojes': 'fashion',
        
        # Hogar
        'Hogar': 'home',
        'Decoración': 'home',
        'Muebles': 'home',
        'Jardín': 'home',
        
        # Ferretería
        'Ferretería': 'hardware',
        'Construcción': 'hardware',
        'Plomería': 'hardware',
        'Electricidad': 'hardware',
        
        # Belleza
        'Belleza': 'beauty',
        'Salón': 'beauty',
        'Spa': 'beauty',
        'Gimnasio': 'beauty',
        
        # Automotriz
        'Automotriz': 'automotive',
        'Taller': 'automotive',
        'Gasolinera': 'automotive',
        
        # Servicios
        'Abogados': 'services',
        'Contadores': 'services',
        'Seguros': 'services',
        'Inmobiliaria': 'services',
        'Educación': 'services',
        'Librería': 'services',
        'Fotografía': 'services',
        'Impresiones': 'services',
        'Lavandería': 'services',
    }
    
    print("Actualizando negocios con categorías principales...")
    
    businesses = Business.objects.all()
    updated_count = 0
    
    for business in businesses:
        # Obtener la categoría actual del negocio
        current_category_name = business.category.name
        
        # Determinar la categoría principal
        main_category_id = category_mapping.get(current_category_name, 'services')
        
        # Buscar o crear la categoría principal
        main_category, created = Category.objects.get_or_create(
            name=main_category_id,
            defaults={
                'icon': main_category_id,
                'description': f'Categoría principal: {main_category_id}'
            }
        )
        
        if created:
            print(f"  - Categoría principal creada: {main_category.name}")
        
        # Actualizar el negocio con la categoría principal
        business.category = main_category
        business.save()
        
        print(f"  - Negocio '{business.name}' actualizado: {current_category_name} -> {main_category.name}")
        updated_count += 1
    
    print(f"\nTotal de negocios actualizados: {updated_count}")
    print(f"Total de categorías principales: {Category.objects.filter(name__in=category_mapping.values()).count()}")

if __name__ == '__main__':
    update_business_categories()
