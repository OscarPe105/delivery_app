/// 🚀 TRANSICIONES DE NAVEGACIÓN SUAVES
/// 
/// Utilidades para crear transiciones personalizadas entre pantallas
/// 
/// @author Sistema de Delivery Comunitario
/// @version 1.0.0

import 'package:flutter/material.dart';

/// 🎬 TRANSICIÓN DESLIZANTE DESDE ABAJO
/// 
/// Transición suave que desliza la pantalla desde abajo
class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  SlideUpRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

/// 🎬 TRANSICIÓN DESLIZANTE DESDE LA DERECHA
/// 
/// Transición suave que desliza la pantalla desde la derecha
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  SlideRightRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

/// 🎬 TRANSICIÓN CON ESCALA Y FADE
/// 
/// Transición que combina escala y desvanecimiento
class ScaleFadeRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  ScaleFadeRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween(begin: 0.0, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: ScaleTransition(
                scale: animation.drive(
                  Tween(begin: 0.8, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeOutBack)),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

/// 🎬 TRANSICIÓN CON ROTACIÓN
/// 
/// Transición que rota la pantalla mientras aparece
class RotationRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  RotationRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: RotationTransition(
                turns: animation.drive(
                  Tween(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

/// 🎬 TRANSICIÓN PERSONALIZADA PARA MODALES
/// 
/// Transición especial para pantallas modales con blur de fondo
class ModalRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  ModalRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black54,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween(begin: 0.0, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0.0, 0.3), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutBack)),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

/// 🎬 TRANSICIÓN CON ELASTICIDAD
/// 
/// Transición con efecto elástico
class ElasticRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  ElasticRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.elasticOut)),
              ),
              child: child,
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );
}

/// 🎬 UTILIDADES DE NAVEGACIÓN
/// 
/// Métodos helper para usar las transiciones fácilmente
class NavigationUtils {
  /// Navegar con transición deslizante desde abajo
  static Future<T?> slideUp<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
  }) {
    return Navigator.of(context).push<T>(
      SlideUpRoute(page: page, duration: duration ?? const Duration(milliseconds: 300)) as Route<T>,
    );
  }

  /// Navegar con transición deslizante desde la derecha
  static Future<T?> slideRight<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
  }) {
    return Navigator.of(context).push<T>(
      SlideRightRoute(page: page, duration: duration ?? const Duration(milliseconds: 300)) as Route<T>,
    );
  }

  /// Navegar con transición de escala y fade
  static Future<T?> scaleFade<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
  }) {
    return Navigator.of(context).push<T>(
      ScaleFadeRoute(page: page, duration: duration ?? const Duration(milliseconds: 300)) as Route<T>,
    );
  }

  /// Navegar con transición modal
  static Future<T?> modal<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
  }) {
    return Navigator.of(context).push<T>(
      ModalRoute(page: page, duration: duration ?? const Duration(milliseconds: 300)) as Route<T>,
    );
  }

  /// Navegar con transición elástica
  static Future<T?> elastic<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
  }) {
    return Navigator.of(context).push<T>(
      ElasticRoute(page: page, duration: duration ?? const Duration(milliseconds: 500)) as Route<T>,
    );
  }

  /// Navegar con transición de rotación
  static Future<T?> rotation<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
  }) {
    return Navigator.of(context).push<T>(
      RotationRoute(page: page, duration: duration ?? const Duration(milliseconds: 400)) as Route<T>,
    );
  }
}
