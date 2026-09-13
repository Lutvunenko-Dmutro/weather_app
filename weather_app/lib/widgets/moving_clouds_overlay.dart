import 'package:flutter/material.dart';

import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';

class MovingCloudsOverlay extends StatefulWidget {
  final WeatherType weatherType;
  final int variant; // cloud variant
  final int sunVariant;
  final bool isPaused;
  
  const MovingCloudsOverlay({
    super.key, 
    required this.weatherType,
    this.variant = 0,
    this.sunVariant = 0,
    this.isPaused = false,
  });

  @override
  State<MovingCloudsOverlay> createState() => _MovingCloudsOverlayState();
}

class _MovingCloudsOverlayState extends State<MovingCloudsOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    int duration1 = widget.variant == 1 ? 40 : 80;
    int duration2 = widget.variant == 1 ? 25 : 50;

    // Background cloud (slower)
    _controller1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: duration1),
    );
    
    // Foreground cloud (faster)
    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: duration2),
    );

    if (!widget.isPaused) {
      _controller1.repeat();
      _controller2.repeat();
    } else {
      _controller1.value = 0.5;
      _controller2.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant MovingCloudsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant != widget.variant) {
      _controller1.dispose();
      _controller2.dispose();
      _initControllers();
    } else if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _controller1.stop();
        _controller2.stop();
        _controller1.value = 0.5;
        _controller2.value = 0.5;
      } else {
        _controller1.repeat();
        _controller2.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Cloud sizes
    const cloud1Width = 500.0;
    const cloud2Width = 650.0;
    
    // Total distance so clouds start fully off-screen right and end fully off-screen left
    final totalDistance1 = screenWidth + cloud1Width;
    final totalDistance2 = screenWidth + cloud2Width;

    return Stack(
      children: [
        // Static Sun/Moon (if sunny)
        if (widget.weatherType == WeatherType.sunny)
          Positioned(
            right: 40,
            top: 80,
            child: widget.sunVariant == 1
              ? Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withValues(alpha: 0.8),
                        blurRadius: 100,
                        spreadRadius: 30,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.9),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                )
              : Opacity(
                  opacity: 0.8,
                  child: Image(
                    image: const AssetImage('images/sun.webp', package: 'flutter_weather_bg_null_safety'),
                    width: 150,
                  ),
                ),
          ),
        
        // Background cloud (slower)
        AnimatedBuilder(
          animation: _controller1,
          builder: (context, child) {
            final dx1 = screenWidth - (_controller1.value * totalDistance1);
            return Positioned(
              left: dx1,
              top: -80,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  'images/cloud.webp',
                  package: 'flutter_weather_bg_null_safety',
                  width: cloud1Width,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
        
        // Foreground cloud (faster)
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, child) {
            final dx2 = screenWidth - (_controller2.value * totalDistance2);
            return Positioned(
              left: dx2,
              top: 20,
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  'images/cloud.webp',
                  package: 'flutter_weather_bg_null_safety',
                  width: cloud2Width,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

