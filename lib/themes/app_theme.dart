/**
 * 🎨 TEMA PERSONALIZADO DE LA APLICACIÓN
 * 
 * Define todos los estilos, colores y temas de la aplicación
 * 
 * @author Sistema de Delivery Comunitario
 * @version 1.0.0
 */

import 'package:flutter/material.dart';

/**
 * 🎨 PALETA DE COLORES PERSONALIZADA
 */
class AppColors {
  // Colores principales
  static const Color primary = Color(0xFFBF360C);
  static const Color primaryLight = Color(0xFFD84315);
  static const Color primaryDark = Color(0xFF8D1B00);
  static const Color secondary = Color(0xFFE65100);
  
  // Colores de fondo
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFFADB5BD);
  
  // Colores de estado
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  
  // Colores de gradiente
  static const List<Color> primaryGradient = [
    Color(0xFFBF360C),
    Color(0xFFD84315),
    Color(0xFFE65100),
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFFF8F9FA),
    Color(0xFFE9ECEF),
    Color(0xFFDEE2E6),
  ];
  
  // Colores de sombra
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}

/**
 * 🎨 TIPOGRAFÍA PERSONALIZADA
 */
class AppTextStyles {
  // Títulos
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
    height: 1.2,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
    height: 1.3,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
    height: 1.3,
  );
  
  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
    height: 1.4,
  );
  
  // Subtítulos
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
    height: 1.4,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: 'Roboto',
    height: 1.4,
  );
  
  // Cuerpo de texto
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: 'Roboto',
    height: 1.5,
  );
  
  // Botones
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Roboto',
    height: 1.2,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Roboto',
    height: 1.2,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    fontFamily: 'Roboto',
    height: 1.3,
  );
  
  // Overline
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    fontFamily: 'Roboto',
    height: 1.2,
    letterSpacing: 1.5,
  );
}

/**
 * 🎨 TEMA CLARO PERSONALIZADO
 */
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colores principales
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // Tipografía
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headline1,
        headlineMedium: AppTextStyles.headline2,
        headlineSmall: AppTextStyles.headline3,
        titleLarge: AppTextStyles.headline4,
        titleMedium: AppTextStyles.subtitle1,
        titleSmall: AppTextStyles.subtitle2,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body2,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.buttonSmall,
        labelSmall: AppTextStyles.overline,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headline4,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.buttonSmall,
        ),
      ),
      
      // Botones outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.subtitle2,
      ),
      
      // Tarjetas
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 8,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceVariant,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
      
      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
  
  /**
   * 🎨 TEMA OSCURO PERSONALIZADO
   */
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Colores principales
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      
      // Tipografía (misma que el tema claro)
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headline1,
        headlineMedium: AppTextStyles.headline2,
        headlineSmall: AppTextStyles.headline3,
        titleLarge: AppTextStyles.headline4,
        titleMedium: AppTextStyles.subtitle1,
        titleSmall: AppTextStyles.subtitle2,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body2,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.buttonSmall,
        labelSmall: AppTextStyles.overline,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headline4,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Tarjetas
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 8,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

/**
 * 🎨 UTILIDADES DE ESTILO
 */
class AppStyleUtils {
  // Sombras personalizadas
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Gradientes personalizados
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: AppColors.primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get backgroundGradient => const LinearGradient(
    colors: AppColors.backgroundGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Border radius personalizados
  static BorderRadius get smallRadius => BorderRadius.circular(8);
  static BorderRadius get mediumRadius => BorderRadius.circular(16);
  static BorderRadius get largeRadius => BorderRadius.circular(24);
  static BorderRadius get extraLargeRadius => BorderRadius.circular(32);
}
