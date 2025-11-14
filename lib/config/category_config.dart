import 'package:flutter/material.dart';

/// Configuración de categorías para el sistema de delivery
class CategoryConfig {
  /// Mapeo de categorías principales (para la pantalla de negocios) a subcategorías específicas (para registro)
  static const Map<String, List<String>> categoryMapping = {
    'food': [
      'Restaurante',
      'Cafetería',
      'Pizzería',
      'Comida Rápida',
      'Postres',
      'Bebidas',
      'Carnicería',
      'Panadería',
      'Comida',
    ],
    'groceries': [
      'Supermercado',
      'Abarrotes',
      'Frutas y Verduras',
      'Carnicería',
      'Panadería',
      'Supermercados',
    ],
    'pharmacy': [
      'Farmacia',
      'Óptica',
      'Laboratorio',
      'Farmacias',
    ],
    'electronics': [
      'Electrónicos',
      'Computadoras',
      'Teléfonos',
      'Reparaciones',
      'Electrónicos',
    ],
    'fashion': [
      'Ropa',
      'Calzado',
      'Joyería',
      'Relojes',
      'Moda',
    ],
    'home': [
      'Hogar',
      'Decoración',
      'Muebles',
      'Jardín',
    ],
    'hardware': [
      'Ferretería',
      'Construcción',
      'Plomería',
      'Electricidad',
    ],
    'beauty': [
      'Belleza',
      'Salón',
      'Spa',
      'Gimnasio',
    ],
    'automotive': [
      'Automotriz',
      'Taller',
      'Gasolinera',
    ],
    'services': [
      'Abogados',
      'Contadores',
      'Seguros',
      'Inmobiliaria',
      'Educación',
      'Librería',
      'Fotografía',
      'Impresiones',
      'Lavandería',
      'Servicios',
    ],
  };

  /// Obtener subcategorías para una categoría principal
  static List<String> getSubcategories(String mainCategory) {
    return categoryMapping[mainCategory] ?? ['Otro'];
  }

  /// Obtener todas las subcategorías disponibles
  static List<String> getAllSubcategories() {
    const businessSectionCategories = [
      'Comida',
      'Supermercados',
      'Farmacias',
      'Electrónicos',
      'Moda',
      'Hogar',
      'Ferretería',
      'Belleza',
      'Automotriz',
      'Servicios',
    ];

    return [...businessSectionCategories, 'Otro'];
  }

  static const Map<String, IconData> businessCategoryIcons = {
    'Comida': Icons.restaurant_menu,
    'Supermercados': Icons.local_grocery_store,
    'Farmacias': Icons.local_pharmacy,
    'Electrónicos': Icons.devices_other,
    'Moda': Icons.checkroom,
    'Hogar': Icons.chair_alt,
    'Ferretería': Icons.home_repair_service,
    'Belleza': Icons.brush,
    'Automotriz': Icons.directions_car_filled,
    'Servicios': Icons.handshake,
    'Otro': Icons.storefront,
  };

  static IconData getIconForBusinessCategory(String category) {
    return businessCategoryIcons[category] ?? Icons.store;
  }

  /// Determinar la categoría principal basada en una subcategoría
  static String getMainCategory(String subcategory) {
    for (String mainCategory in categoryMapping.keys) {
      if (categoryMapping[mainCategory]!.contains(subcategory)) {
        return mainCategory;
      }
    }
    return 'services'; // Default para categorías no mapeadas
  }

  /// Obtener iconos para las categorías principales
  static Map<String, IconData> getMainCategoryIcons() {
    return {
      'all': Icons.store,
      'food': Icons.restaurant,
      'groceries': Icons.shopping_cart,
      'pharmacy': Icons.local_pharmacy,
      'electronics': Icons.devices,
      'fashion': Icons.checkroom,
      'home': Icons.home,
      'hardware': Icons.handyman,
      'beauty': Icons.face,
      'automotive': Icons.directions_car,
      'services': Icons.business,
    };
  }

  /// Obtener colores para las categorías principales
  static Map<String, Color> getMainCategoryColors() {
    return {
      'all': Colors.grey,
      'food': Colors.orange,
      'groceries': Colors.green,
      'pharmacy': Colors.red,
      'electronics': Colors.blue,
      'fashion': Colors.pink,
      'home': Colors.brown,
      'hardware': Colors.amber,
      'beauty': Colors.purple,
      'automotive': Colors.indigo,
      'services': Colors.teal,
    };
  }
}

