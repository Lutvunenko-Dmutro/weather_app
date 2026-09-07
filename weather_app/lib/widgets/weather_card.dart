import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'forecast_widget.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel? weather;
  final List<ForecastItem> forecast;
  final bool isCelsius;

  const WeatherCard({
    super.key,
    required this.weather,
    this.forecast = const [],
    this.isCelsius = true,
  });

  Color _bgColor() {
    if (weather == null || weather!.isError) return const Color(0xFF0F0F1A);
    final id = int.tryParse(weather!.conditionId) ?? 0;
    if (id >= 200 && id < 300) return const Color(0xFF1A0A2E);
    if (id >= 300 && id < 600) return const Color(0xFF0A1628);
    if (id >= 600 && id < 700) return const Color(0xFF1A2030);
    if (id == 800) return const Color(0xFF0A1A2E);
    return const Color(0xFF111820);
  }

  Color _accentColor() {
    if (weather == null || weather!.isError) return Colors.white24;
    final id = int.tryParse(weather!.conditionId) ?? 0;
    if (id >= 200 && id < 300) return const Color(0xFF7B2FBE);
    if (id >= 300 && id < 600) return const Color(0xFF4A8FE7);
    if (id >= 600 && id < 700) return const Color(0xFF90CAF9);
    if (id == 800) return const Color(0xFF4FC3F7);
    return const Color(0xFF78909C);
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor();
    final accent = _accentColor();

    if (weather == null) {
      return Container(
        color: bg,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 1),
        ),
      );
    }

    if (weather!.isError) {
      return Container(
        color: bg,
        child: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.white12),
            SizedBox(height: 16),
            Text('Немає даних',
                style: TextStyle(color: Colors.white24, fontSize: 16, letterSpacing: 1)),
          ]),
        ),
      );
    }

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок: місто + іконка
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ліва частина — Flexible, щоб не переповнювалась
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather!.city.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 11,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          weather!.displayTemp(isCelsius),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 96,
                            fontWeight: FontWeight.w100,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weather!.condition,
                        style: TextStyle(color: accent, fontSize: 14, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Іконка погоди
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.1),
                  ),
                  child: Image.network(
                    weather!.iconUrl,
                    width: 70,
                    height: 70,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.wb_sunny_rounded, size: 50, color: accent.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 36),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 24),

            // Деталі — перший рядок
            Row(
              children: [
                _StatBlock(
                  label: 'Відчувається',
                  value: weather!.displayFeelsLike(isCelsius),
                  accent: accent,
                ),
                const SizedBox(width: 12),
                _StatBlock(
                  label: 'Вологість',
                  value: '${weather!.humidity}%',
                  accent: accent,
                ),
                const SizedBox(width: 12),
                _StatBlock(
                  label: 'Вітер',
                  value: '${weather!.windSpeed.toStringAsFixed(1)} м/с',
                  accent: accent,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Деталі — другий рядок
            Row(
              children: [
                _StatBlock(label: 'Мінімум', value: weather!.tempMin, accent: accent),
                const SizedBox(width: 12),
                _StatBlock(label: 'Максимум', value: weather!.tempMax, accent: accent),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()), // Пустий блок для вирівнювання
              ],
            ),

            // Прогноз
            if (forecast.isNotEmpty) ...[
              const SizedBox(height: 36),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
              const SizedBox(height: 24),
              ForecastWidget(forecast: forecast, isCelsius: isCelsius, accent: accent),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatBlock({required this.label, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300)),
          ],
        ),
      ),
    );
  }
}
