import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AiParticlesWidget extends StatefulWidget {
  const AiParticlesWidget({super.key});

  @override
  State<AiParticlesWidget> createState() => _AiParticlesWidgetState();
}

class _AiParticlesWidgetState extends State<AiParticlesWidget>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _particles = List.generate(15, (index) => Particle());
    _particleController.repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particles, _particleController.value),
          size: Size(100.w, 100.h),
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;
  late double opacity;

  Particle() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 4 + 2;
    speed = math.Random().nextDouble() * 0.02 + 0.01;
    opacity = math.Random().nextDouble() * 0.5 + 0.2;

    final colors = [
      AppTheme.primaryLight,
      AppTheme.accentLight,
      Colors.white,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * 0.6)
        ..style = PaintingStyle.fill;

      final currentY = (particle.y + animationValue * particle.speed) % 1.0;
      final currentX = particle.x +
          math.sin(animationValue * 2 * math.pi + particle.y * 10) * 0.1;

      canvas.drawCircle(
        Offset(currentX * size.width, currentY * size.height),
        particle.size,
        paint,
      );

      // Draw connecting lines between nearby particles
      for (var otherParticle in particles) {
        if (particle != otherParticle) {
          final otherY =
              (otherParticle.y + animationValue * otherParticle.speed) % 1.0;
          final otherX = otherParticle.x +
              math.sin(animationValue * 2 * math.pi + otherParticle.y * 10) *
                  0.1;

          final distance = math.sqrt(
              math.pow((currentX - otherX) * size.width, 2) +
                  math.pow((currentY - otherY) * size.height, 2));

          if (distance < 100) {
            final linePaint = Paint()
              ..color = AppTheme.accentLight
                  .withValues(alpha: (1 - distance / 100) * 0.2)
              ..strokeWidth = 1;

            canvas.drawLine(
              Offset(currentX * size.width, currentY * size.height),
              Offset(otherX * size.width, otherY * size.height),
              linePaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
