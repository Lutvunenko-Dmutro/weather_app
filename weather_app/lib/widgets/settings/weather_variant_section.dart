import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import '../background_gradient.dart';
import 'settings_glass_card.dart';

/// A single weather-effect variant selection row (e.g. Rain: Realistic / Matrix).
/// Each option renders a live mini-preview of the corresponding background effect.
class WeatherVariantSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String type;
  final int currentVariant;
  final List<String> options;
  final Function(String, int) onVariantChanged;

  const WeatherVariantSection({
    super.key,
    required this.title,
    required this.icon,
    required this.type,
    required this.currentVariant,
    required this.options,
    required this.onVariantChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Option buttons
            Row(
              children: List.generate(options.length, (index) {
                final isSelected = currentVariant == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < options.length - 1 ? 12.0 : 0,
                    ),
                    child: _VariantButton(
                      type: type,
                      index: index,
                      label: options[index],
                      isSelected: isSelected,
                      onTap: () => onVariantChanged(type, index),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single animated button showing a mini weather preview as its background.
class _VariantButton extends StatelessWidget {
  final String type;
  final int index;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VariantButton({
    required this.type,
    required this.index,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bgType, sunVar, rainVar, snowVar, cloudVar) = _resolveVariants();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.3), blurRadius: 10)]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackgroundGradient(
            weatherType: bgType,
            sunVariant: sunVar,
            rainVariant: rainVar,
            snowVariant: snowVar,
            cloudVariant: cloudVar,
            isPaused: !isSelected,
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns (bgWeatherType, sunVar, rainVar, snowVar, cloudVar) based on
  /// [type] and [index].
  (WeatherType, int, int, int, int) _resolveVariants() {
    return switch (type) {
      'sun'   => (WeatherType.sunny,      index, 0,     0,     0),
      'rain'  => (WeatherType.heavyRainy, 0,     index, 0,     0),
      'snow'  => (WeatherType.heavySnow,  0,     0,     index, 0),
      'cloud' => (WeatherType.cloudy,     0,     0,     0,     index),
      _       => (WeatherType.sunny,      0,     0,     0,     0),
    };
  }
}
