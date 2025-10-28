import 'package:flutter/material.dart';

/// Sistema de animaciones para la aplicación de delivery
class AppAnimations {
  // Duración estándar de animaciones
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Curvas de animación
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  /// Animación de fade in para widgets
  static Widget fadeIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animación de slide in desde diferentes direcciones
  static Widget slideIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = easeInOut,
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animación de escala para botones y elementos interactivos
  static Widget scaleIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = elasticOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animación de rotación
  static Widget rotateIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159, // 2π radians = 360 degrees
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animación combinada de fade + slide
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = easeInOut,
    Offset slideBegin = const Offset(0, 0.3),
    Offset slideEnd = Offset.zero,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final slideOffset = Offset.lerp(slideBegin, slideEnd, value)!;
        final opacity = fadeBegin + (fadeEnd - fadeBegin) * value;
        
        return Transform.translate(
          offset: slideOffset,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animación de pulso para elementos importantes
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: minScale, end: maxScale),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      onEnd: () {
        // Reiniciar la animación
      },
      child: child,
    );
  }

  /// Animación de shimmer para loading
  static Widget shimmer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    Color baseColor = Colors.grey,
    Color highlightColor = Colors.white,
  }) {
    return TweenAnimationBuilder<Color>(
      duration: duration,
      tween: ColorTween(begin: baseColor, end: highlightColor),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            color: value,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animación de bounce para botones
  static Widget bounceButton({
    required Widget child,
    required VoidCallback onTap,
    Duration duration = shortDuration,
  }) {
    return GestureDetector(
      onTap: () {
        // Animación de bounce al tocar
        onTap();
      },
      child: TweenAnimationBuilder<double>(
        duration: duration,
        tween: Tween(begin: 1.0, end: 0.95),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  /// Animación de lista con delay escalonado
  static Widget staggeredList({
    required List<Widget> children,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = mediumDuration,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          duration: duration + (delay * index),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }

  /// Animación de página completa con fade
  static Widget pageTransition({
    required Widget child,
    Duration duration = longDuration,
    Curve curve = easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Widget animado para botones principales
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration duration;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.duration = AppAnimations.shortDuration,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null ? (_) => _controller.reverse() : null,
      onTapCancel: widget.onPressed != null ? () => _controller.reverse() : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.backgroundColor,
                foregroundColor: widget.foregroundColor,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Widget animado para tarjetas
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedCard({
    super.key,
    required this.child,
    this.duration = AppAnimations.mediumDuration,
    this.curve = AppAnimations.easeInOut,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Iniciar animación automáticamente
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

