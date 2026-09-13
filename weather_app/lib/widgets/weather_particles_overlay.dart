import 'dart:math';
import 'package:flutter/material.dart';

class WeatherParticlesOverlay extends StatefulWidget {
  final bool isRain;
  final bool isSnow;
  final bool isThunder;
  final int rainVariant;
  final int snowVariant;
  final bool isPaused;
  /// Number of particles. Reduce to ~15 for small previews, default 100 for full-screen.
  final int particleCount;

  const WeatherParticlesOverlay({
    super.key,
    required this.isRain,
    required this.isSnow,
    required this.isThunder,
    this.rainVariant = 0,
    this.snowVariant = 0,
    this.isPaused = false,
    this.particleCount = 100,
  });

  @override
  State<WeatherParticlesOverlay> createState() => _WeatherParticlesOverlayState();
}

class _WeatherParticlesOverlayState extends State<WeatherParticlesOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  double _thunderOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    if (!widget.isPaused) {
      _controller.repeat();
    } else {
      _controller.value = 0.5; // Show static particles mid-animation
    }
    
    // Generate particles — fewer for paused preview buttons
    final count = widget.isPaused ? min(widget.particleCount, 15) : widget.particleCount;
    for (int i = 0; i < count; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: _random.nextDouble() * 0.8 + 0.2,
        size: _random.nextDouble() * 2 + 2,
      ));
    }

    _controller.addListener(_updateThunder);
  }

  void _updateThunder() {
    if (!widget.isThunder) {
      if (_thunderOpacity != 0.0) {
        _thunderOpacity = 0.0;
      }
      return;
    }

    // Randomly flash for thunder
    if (_random.nextDouble() < 0.02) {
      _thunderOpacity = 0.6; // Flash
    } else {
      _thunderOpacity = max(0.0, _thunderOpacity - 0.1); // Fade out
    }
  }

  @override
  void didUpdateWidget(covariant WeatherParticlesOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _controller.stop();
        _controller.value = 0.5;
      } else {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRain && !widget.isSnow && !widget.isThunder) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            if (widget.isThunder)
              Container(
                color: Colors.white.withValues(alpha: _thunderOpacity),
              ),
            if (widget.isRain || widget.isSnow)
              CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  isRain: widget.isRain,
                  progress: _controller.value,
                  rainVariant: widget.rainVariant,
                  snowVariant: widget.snowVariant,
                ),
                size: Size.infinite,
              ),
          ],
        );
      },
    );
  }
}

class Particle {
  double x, y, speed, size;
  Particle({required this.x, required this.y, required this.speed, required this.size});
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final bool isRain;
  final double progress;
  final int rainVariant;
  final int snowVariant;

  ParticlePainter({
    required this.particles, 
    required this.isRain, 
    required this.progress,
    required this.rainVariant,
    required this.snowVariant,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint;
    
    if (isRain && rainVariant == 1) {
      // Matrix rain variant
      paint = Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
    } else {
      // Default rain/snow
      paint = Paint()
        ..color = Colors.white.withValues(alpha: isRain ? 0.5 : 0.8)
        ..style = PaintingStyle.fill;
    }

    for (var p in particles) {
      double speedMultiplier = isRain ? 10.0 : 3.0;
      
      // Blizzard mode for snow variant 1
      if (!isRain && snowVariant == 1) {
        speedMultiplier = 8.0;
      }

      double dy = (p.y + progress * p.speed * speedMultiplier) % 1.0;
      double dx = p.x;
      
      if (!isRain) {
        // Horizontal drift for snow
        double drift = snowVariant == 1 ? 0.15 : 0.05; 
        dx = (p.x + sin((dy + progress) * pi * 4) * drift) % 1.0;
      }

      double px = dx * size.width;
      double py = dy * size.height;

      if (isRain) {
        if (rainVariant == 1) {
          // Matrix lines
          canvas.drawRect(Rect.fromLTWH(px, py, p.size * 0.8, p.size * 8), paint);
        } else {
          // Normal rain
          canvas.drawRect(Rect.fromLTWH(px, py, p.size * 0.5, p.size * 4), paint);
        }
      } else {
        // Draw snow circle
        canvas.drawCircle(Offset(px, py), p.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
