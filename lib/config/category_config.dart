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
    ],
    'groceries': [
      'Supermercado',
      'Abarrotes',
      'Frutas y Verduras',
      'Carnicería',
      'Panadería',
    ],
    'pharmacy': [
      'Farmacia',
      'Óptica',
      'Laboratorio',
    ],
    'electronics': [
      'Electrónicos',
      'Computadoras',
      'Teléfonos',
      'Reparaciones',
    ],
    'fashion': [
      'Ropa',
      'Calzado',
      'Joyería',
      'Relojes',
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
    ],
  };

  /// Obtener subcategorías para una categoría principal
  static List<String> getSubcategories(String mainCategory) {
    return categoryMapping[mainCategory] ?? ['Otro'];
  }

  /// Obtener todas las subcategorías disponibles
  static List<String> getAllSubcategories() {
    List<String> allSubcategories = [];
    for (List<String> subcategories in categoryMapping.values) {
      allSubcategories.addAll(subcategories);
    }
    // Eliminar duplicados y agregar "Otro"
    allSubcategories = allSubcategories.toSet().toList();
    allSubcategories.add('Otro');
    return allSubcategories;
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

