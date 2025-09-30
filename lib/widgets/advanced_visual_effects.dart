/**
 * ✨ EFECTOS VISUALES AVANZADOS
 * 
 * Colección de efectos visuales modernos para mejorar la experiencia del usuario
 * 
 * @author Sistema de Delivery Comunitario
 * @version 2.0.0
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;

/**
 * 🌟 EFECTO DE PARTÍCULAS FLOTANTES
 * Crea partículas animadas que flotan en el fondo
 */
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double particleSize;
  final Duration animationDuration;
  final Widget? child;

  const FloatingParticles({
    super.key,
    this.particleCount = 20,
    this.particleColor = Colors.white,
    this.particleSize = 4.0,
    this.animationDuration = const Duration(seconds: 3),
    this.child,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _generateParticles();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: widget.particleSize + math.Random().nextDouble() * 2,
        speed: 0.5 + math.Random().nextDouble() * 0.5,
        opacity: 0.3 + math.Random().nextDouble() * 0.7,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            animationValue: _controller.value,
            color: widget.particleColor,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final animatedY = (particle.y + animationValue * particle.speed) % 1.0;
      final animatedOpacity = particle.opacity * (1 - (animatedY * 0.5));
      
      paint.color = color.withOpacity(animatedOpacity);
      
      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          animatedY * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/**
 * 🌈 EFECTO DE GRADIENTE ANIMADO
 * Gradiente que cambia de colores de forma suave
 */
class AnimatedGradient extends StatefulWidget {
  final List<Color> colors;
  final Duration duration;
  final Widget? child;

  const AnimatedGradient({
    super.key,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.child,
  });

  @override
  State<AnimatedGradient> createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<AnimatedGradient>
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
    _controller.repeat(reverse: true);
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/**
 * 💫 EFECTO DE SHIMMER
 * Efecto de brillo que se mueve a través del contenido
 */
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFFFFFFF),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
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
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
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
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                _animation.value,
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

/**
 * 🌊 EFECTO DE ONDAS
 * Ondas que se expanden desde un punto central
 */
class WaveEffect extends StatefulWidget {
  final Widget child;
  final Color waveColor;
  final double waveRadius;
  final Duration duration;

  const WaveEffect({
    super.key,
    required this.child,
    this.waveColor = Colors.white,
    this.waveRadius = 100.0,
    this.duration = const Duration(seconds: 2),
  });

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
            animationValue: _animation.value,
            waveColor: widget.waveColor,
            waveRadius: widget.waveRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;
  final double waveRadius;

  WavePainter({
    required this.animationValue,
    required this.waveColor,
    required this.waveRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = waveColor.withOpacity(1 - animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final radius = waveRadius * animationValue;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/**
 * 🎆 EFECTO DE CONFETTI
 * Confetti que cae desde la parte superior
 */
class ConfettiEffect extends StatefulWidget {
  final Widget child;
  final int confettiCount;
  final List<Color> colors;
  final Duration duration;

  const ConfettiEffect({
    super.key,
    required this.child,
    this.confettiCount = 50,
    this.colors = const [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ],
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<ConfettiPiece> _confetti = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _generateConfetti();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateConfetti() {
    _confetti = List.generate(widget.confettiCount, (index) {
      return ConfettiPiece(
        x: math.Random().nextDouble(),
        y: -0.1,
        color: widget.colors[math.Random().nextInt(widget.colors.length)],
        size: 4.0 + math.Random().nextDouble() * 4.0,
        rotation: math.Random().nextDouble() * 2 * math.pi,
        speed: 0.5 + math.Random().nextDouble() * 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            confetti: _confetti,
            animationValue: _controller.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class ConfettiPiece {
  double x;
  double y;
  Color color;
  double size;
  double rotation;
  double speed;

  ConfettiPiece({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.speed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> confetti;
  final double animationValue;

  ConfettiPainter({
    required this.confetti,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      final animatedY = piece.y + animationValue * piece.speed;
      if (animatedY > 1.1) continue;

      final paint = Paint()
        ..color = piece.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
        piece.x * size.width,
        animatedY * size.height,
      );
      canvas.rotate(piece.rotation + animationValue * 2 * math.pi);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/**
 * 🔥 EFECTO DE FUEGO
 * Efecto de llamas animadas
 */
class FireEffect extends StatefulWidget {
  final Widget child;
  final Color fireColor;
  final double intensity;

  const FireEffect({
    super.key,
    required this.child,
    this.fireColor = Colors.orange,
    this.intensity = 1.0,
  });

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
      duration: const Duration(milliseconds: 500),
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
          painter: FirePainter(
            animationValue: _animation.value,
            fireColor: widget.fireColor,
            intensity: widget.intensity,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class FirePainter extends CustomPainter {
  final double animationValue;
  final Color fireColor;
  final double intensity;

  FirePainter({
    required this.animationValue,
    required this.fireColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fireColor.withOpacity(0.3 * intensity)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0 * intensity;
    final frequency = 0.02;

    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height - 
          waveHeight * math.sin(x * frequency + animationValue * 2 * math.pi);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
