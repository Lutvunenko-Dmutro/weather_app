import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'moving_clouds_overlay.dart';
import 'weather_particles_overlay.dart';

class BackgroundGradient extends StatefulWidget {
  final Widget child;
  final WeatherType weatherType;
  final int sunVariant;
  final int rainVariant;
  final int snowVariant;
  final int cloudVariant;
  final bool isPaused;

  const BackgroundGradient({
    super.key,
    required this.child,
    this.weatherType = WeatherType.sunny,
    this.sunVariant = 0,
    this.rainVariant = 0,
    this.snowVariant = 0,
    this.cloudVariant = 0,
    this.isPaused = false,
  });

  @override
  State<BackgroundGradient> createState() => _BackgroundGradientState();
}

class _BackgroundGradientState extends State<BackgroundGradient> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Custom gradient for all weather types
        LinearGradient customGradient;
        
        bool isRain = false;
        bool isSnow = false;
        bool isThunder = false;
        bool showClouds = false;

        switch (widget.weatherType) {
          case WeatherType.sunny:
            customGradient = const LinearGradient(
              colors: [Color(0xFF3388DD), Color(0xFF55BBAA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            );
            break;
          case WeatherType.sunnyNight:
          case WeatherType.cloudyNight:
            customGradient = const LinearGradient(
              colors: [Color(0xFF0A1026), Color(0xFF1A2A44)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            );
            showClouds = widget.weatherType == WeatherType.cloudyNight;
            break;
          case WeatherType.heavyRainy:
          case WeatherType.middleRainy:
          case WeatherType.lightRainy:
            customGradient = const LinearGradient(
              colors: [Color(0xFF4A5A6A), Color(0xFF6B7B8A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            );
            showClouds = true;
            isRain = true;
            break;
          case WeatherType.heavySnow:
          case WeatherType.middleSnow:
          case WeatherType.lightSnow:
            customGradient = const LinearGradient(
              colors: [Color(0xFF7A8A9A), Color(0xFFAABBAA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            );
            showClouds = true;
            isSnow = true;
            break;
          case WeatherType.thunder:
            customGradient = const LinearGradient(
              colors: [Color(0xFF3A4A5A), Color(0xFF5B6B7A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            );
            showClouds = true;
            isRain = true;
            isThunder = true;
            break;
          default: // cloudy, overcast
            customGradient = const LinearGradient(
              colors: [Color(0xFF5A728A), Color(0xFF8B9FB0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            );
            showClouds = true;
            break;
        }

        return Stack(
          children: [
            // Base Background Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(gradient: customGradient),
              ),
            ),

            // Custom overlay for moving clouds
            if (showClouds)
              Positioned.fill(
                child: MovingCloudsOverlay(
                  weatherType: widget.weatherType,
                  variant: widget.cloudVariant,
                  sunVariant: widget.sunVariant,
                  isPaused: widget.isPaused,
                ),
              ),

            // Custom particles for Rain, Snow and Thunder
            Positioned.fill(
              child: WeatherParticlesOverlay(
                isRain: isRain,
                isSnow: isSnow,
                isThunder: isThunder,
                rainVariant: widget.rainVariant,
                snowVariant: widget.snowVariant,
                isPaused: widget.isPaused,
              ),
            ),

            // Subtle dark overlay for text readability
            Container(
              width: width,
              height: height,
              color: Colors.black.withValues(alpha: 0.15),
            ),
            // Content on top
            widget.child,
          ],
        );
      },
    );
  }
}
