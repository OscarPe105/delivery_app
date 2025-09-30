/**
 * ✨ EFECTOS VISUALES AVANZADOS
 * 
 * Widgets con efectos visuales sofisticados para mejorar la experiencia del usuario
 * 
 * @author Sistema de Delivery Comunitario
 * @version 1.0.0
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

/**
 * 🌊 EFECTO DE ONDAS
 * 
 * Crea un efecto de ondas animadas
 */
class WaveEffect extends StatefulWidget {
  final Widget child;
  final Color waveColor;
  final double waveHeight;
  final Duration duration;

  const WaveEffect({
    Key? key,
    required this.child,
    this.waveColor = Colors.blue,
    this.waveHeight = 20.0,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<WaveEffect> createState() => _WaveEffectState();
}

class _WaveEffectState extends State<WaveEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            animation: _animation.value,
            waveColor: widget.waveColor,
            waveHeight: widget.waveHeight,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color waveColor;
  final double waveHeight;

  WavePainter({
    required this.animation,
    required this.waveColor,
    required this.waveHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveLength = size.width / 2;
    final waveAmplitude = waveHeight;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height - 
          waveAmplitude * 
          math.sin((x / waveLength + animation * 2 * math.pi) * 2 * math.pi);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/**
 * 💫 EFECTO DE BRILLO
 * 
 * Crea un efecto de brillo que se mueve por el widget
 */
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerEffect({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/**
 * 🎆 EFECTO DE CONFETTI
 * 
 * Crea un efecto de confetti animado
 */
class ConfettiEffect extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Duration duration;
  final List<Color> colors;

  const ConfettiEffect({
    Key? key,
    required this.child,
    this.particleCount = 50,
    this.duration = const Duration(seconds: 3),
    this.colors = const [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ],
  }) : super(key: key);

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
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
        curve: Curves.easeOut,
      ));
    }).toList();

    // Start animations with random delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          _controllers[i].forward();
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
              final progress = _animations[index].value;
              final color = widget.colors[index % widget.colors.length];
              
              return Positioned(
                left: (index * 20.0) % MediaQuery.of(context).size.width,
                top: 50 + (progress * 300),
                child: Transform.rotate(
                  angle: progress * 4 * math.pi,
                  child: Opacity(
                    opacity: 1.0 - progress,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
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

/**
 * 🌈 EFECTO DE ARCOÍRIS
 * 
 * Crea un efecto de arcoíris animado
 */
class RainbowEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const RainbowEffect({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<RainbowEffect> createState() => _RainbowEffectState();
}

class _RainbowEffectState extends State<RainbowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
                Colors.red,
              ],
              stops: [
                0.0,
                0.14,
                0.28,
                0.42,
                0.56,
                0.70,
                0.84,
                1.0,
              ].map((stop) => (stop + _animation.value) % 1.0).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/**
 * 💎 EFECTO DE CRISTAL
 * 
 * Crea un efecto de cristal con blur y transparencia
 */
class GlassEffect extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color tintColor;

  const GlassEffect({
    Key? key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.tintColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tintColor.withOpacity(opacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tintColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blur,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: child,
        ),
      ),
    );
  }
}

/**
 * 🔥 EFECTO DE FUEGO
 * 
 * Crea un efecto de fuego animado
 */
class FireEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FireEffect({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<FireEffect> createState() => _FireEffectState();
}

class _FireEffectState extends State<FireEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return RadialGradient(
              center: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.orange.withOpacity(0.3),
                Colors.red.withOpacity(0.5),
                Colors.yellow.withOpacity(0.7),
              ],
              stops: [
                0.0,
                0.3 + (_animation.value * 0.2),
                0.6 + (_animation.value * 0.2),
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

