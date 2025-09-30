/**
 * 🎨 COMPONENTES ANIMADOS REUTILIZABLES
 * 
 * Widgets personalizados con animaciones para mejorar la experiencia del usuario
 * 
 * @author Sistema de Delivery Comunitario
 * @version 1.0.0
 */

import 'package:flutter/material.dart';

/**
 * 🔘 BOTÓN ANIMADO PERSONALIZADO
 * 
 * Botón con animaciones de hover, press y loading states
 */
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AnimatedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.padding,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.primaryColor;
    final textColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding ?? const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(textColor),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: textColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/**
 * 🃏 TARJETA ANIMADA
 * 
 * Tarjeta con animaciones de entrada y hover
 */
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Duration animationDuration;
  final int delayMilliseconds;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.delayMilliseconds = 0,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Delay animation start
    Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Card(
              margin: widget.margin,
              elevation: widget.elevation ?? 4,
              shape: RoundedRectangleBorder(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              ),
              color: widget.backgroundColor,
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/**
 * 📊 INDICADOR DE PROGRESO ANIMADO
 * 
 * Indicador de carga con animación personalizada
 */
class AnimatedProgressIndicator extends StatefulWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final Duration animationDuration;

  const AnimatedProgressIndicator({
    Key? key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height = 8,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.primaryColor.withOpacity(0.2);
    final progressColor = widget.progressColor ?? theme.primaryColor;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.height / 2),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(widget.height / 2),
                boxShadow: [
                  BoxShadow(
                    color: progressColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/**
 * 🌟 EFECTO DE PARTÍCULAS
 * 
 * Efecto visual de partículas flotantes
 */
class ParticleEffect extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Duration duration;
  final Color? particleColor;

  const ParticleEffect({
    Key? key,
    required this.child,
    this.particleCount = 20,
    this.duration = const Duration(seconds: 3),
    this.particleColor,
  }) : super(key: key);

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.particleCount,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    // Start animations with random delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ...List.generate(widget.particleCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Positioned(
                left: (index * 50.0) % MediaQuery.of(context).size.width,
                top: 50 + (_animations[index].value * 100),
                child: Opacity(
                  opacity: 1.0 - _animations[index].value,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.particleColor ?? Colors.orange.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
