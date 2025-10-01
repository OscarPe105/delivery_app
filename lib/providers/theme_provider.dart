// 🎨 PROVEEDOR DE TEMAS Y COLORES
// Este archivo controla todos los colores, estilos y temas de la aplicación
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }
  
  // 🎨 COLORES PRINCIPALES
  static Color get primaryColor => const Color(0xFF34656D);      // Verde azulado oscuro
  static Color get secondaryColor => const Color(0xFF334443);    // Verde muy oscuro
  static Color get accentColor => const Color(0xFFFAEAB1);       // Beige dorado
  
  // 🎨 COLORES DE TEXTO
  static Color get primaryTextColor => const Color(0xFF334443);    // Verde muy oscuro
  static Color get secondaryTextColor => const Color(0xFF34656D);  // Verde azulado oscuro
  static Color get lightTextColor => const Color(0xFFFAF8F1);      // Beige muy claro
  
  // 🎨 COLORES DE FONDO
  static Color get backgroundColor => const Color(0xFFFAF8F1);      // Beige muy claro
  static Color get cardColor => const Color(0xFFFAEAB1);           // Beige dorado
  static Color get surfaceColor => const Color(0xFFFAF8F1);        // Beige muy claro
  
  // 🎨 COLORES DE ESTADO
  static Color get successColor => const Color(0xFF27AE60);
  static Color get errorColor => const Color(0xFFE74C3C);
  static Color get warningColor => const Color(0xFFF39C12);
  static Color get infoColor => const Color(0xFF3498DB);
  
  // 🎨 GRADIENTES
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34656D), Color(0xFF334443)],
  );
  
  static LinearGradient get secondaryGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAEAB1), Color(0xFFFAF8F1)],
  );
  
  // 🎨 RADIOS DE BORDE
  static double get radiusSmall => 8.0;
  static double get radiusMedium => 12.0;
  static double get radiusLarge => 16.0;
  static double get radiusXLarge => 24.0;
  
  // 🎨 TEMAS COMPLETOS
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
  );
  
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    cardColor: const Color(0xFF2D2D2D),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF2D2D2D),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
  
  // 💾 MÉTODOS DE PERSISTENCIA
  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
  
  // 🎨 COLORES ADICIONALES
  static Color get primaryColorDark => const Color(0xFF334443);   // Verde muy oscuro
  static Color get primaryColorLight => const Color(0xFFFAEAB1);  // Beige dorado
  static Color get mutedTextColor => const Color(0xFF34656D);     // Verde azulado oscuro
}