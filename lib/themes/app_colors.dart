import 'package:flutter/material.dart';

/// Sistema de colores centralizado para la aplicación Delivery App
class AppColors {
  // Color principal dorado/ámbar
  static const Color primary = Color(0xFFE8B86D);
  static const Color primaryDark = Color(0xFFD4A574);
  static const Color primaryLight = Color(0xFFF2D4A3);
  
  // Colores secundarios
  static const Color secondary = Color(0xFF2C3E50);
  static const Color secondaryLight = Color(0xFF34495E);
  
  // Colores de estado
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  
  // Colores neutros
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  
  // Colores de borde
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocus = primary;
  
  // Colores de sombra
  static const Color shadow = Color(0x1A000000);
  static const Color shadowPrimary = Color(0x4DE8B86D);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surfaceVariant],
  );
  
  // Colores para diferentes tipos de usuario
  static const Color customerColor = primary;
  static const Color businessColor = Color(0xFFFF8C00); // Naranja
  static const Color adminColor = Color(0xFF8E44AD); // Púrpura
  
  // Colores para estados de pedidos
  static const Color orderPending = warning;
  static const Color orderInProgress = info;
  static const Color orderDelivered = success;
  static const Color orderCancelled = error;
  
  // Colores para categorías de negocios
  static const Map<String, Color> categoryColors = {
    'Comida': AppColors.primary,
    'Supermercados': Color(0xFF27AE60),
    'Farmacias': Color(0xFF3498DB),
    'Electrónicos': Color(0xFF9B59B6),
    'Moda': Color(0xFFE91E63),
    'Hogar': Color(0xFFFF9800),
    'Ferretería': Color(0xFF795548),
    'Belleza': Color(0xFFE91E63),
    'Automotriz': Color(0xFF607D8B),
    'Servicios': Color(0xFF009688),
    'Otro': Color(0xFF9E9E9E),
  };
  
  /// Obtiene el color para una categoría específica
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? categoryColors['Otro']!;
  }
  
  /// Obtiene el color para un tipo de usuario
  static Color getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'customer':
        return customerColor;
      case 'business':
        return businessColor;
      case 'admin':
        return adminColor;
      default:
        return primary;
    }
  }
  
  /// Obtiene el color para un estado de pedido
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return orderPending;
      case 'in_progress':
        return orderInProgress;
      case 'delivered':
        return orderDelivered;
      case 'cancelled':
        return orderCancelled;
      default:
        return textSecondary;
    }
  }
}

/// Extensiones para facilitar el uso de colores
extension AppColorExtensions on Color {
  /// Crea una versión con opacidad del color
  Color withAppOpacity(double opacity) {
    return withOpacity(opacity);
  }
  
  /// Crea una versión más clara del color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  /// Crea una versión más oscura del color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
