import 'dart:math';

import 'package:flutter/material.dart';

/// A short, decorative burst of falling confetti. Purely visual — ignores
/// pointer events and disposes itself when the animation completes.
/// No external package: a handful of painted rectangles are enough to sell
/// the effect for a one-off celebration moment (e.g. leveling up).
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.particleCount = 40});

  final int particleCount;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    Color(0xFFFFD700),
    Color(0xFFFF6E6C),
    Color(0xFF7B61FF),
    Color(0xFF4CAF50),
    Color(0xFF29B6F6),
  ];

  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    final rng = Random();
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        x: rng.nextDouble(),
        fallDelay: rng.nextDouble() * 0.3,
        drift: (rng.nextDouble() - 0.5) * 0.4,
        rotationSpeed: (rng.nextDouble() - 0.5) * 12,
        size: 5 + rng.nextDouble() * 5,
        color: _colors[rng.nextInt(_colors.length)],
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.fallDelay,
    required this.drift,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });

  final double x;
  final double fallDelay;
  final double drift;
  final double rotationSpeed;
  final double size;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final local =
          ((progress - particle.fallDelay) / (1 - particle.fallDelay))
              .clamp(0.0, 1.0);
      if (local <= 0) continue;

      final dx = particle.x * size.width + particle.drift * size.width * local;
      final dy = local * size.height;
      final opacity = local > 0.8 ? (1 - local) * 5 : 1.0;

      paint.color = particle.color.withValues(alpha: opacity.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(particle.rotationSpeed * local * pi);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.5,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
