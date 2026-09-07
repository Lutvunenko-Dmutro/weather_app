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
    if (weather == null || weather!.isError) return const Color(0xFF1A1A2E);
    final id = int.tryParse(weather!.conditionId) ?? 0;
    if (id >= 200 && id < 300) return const Color(0xFF1A0A2E); // Гроза
    if (id >= 300 && id < 600) return const Color(0xFF0A1628); // Дощ
    if (id >= 600 && id < 700) return const Color(0xFF1A2030); // Сніг
    if (id == 800) return const Color(0xFF0A1A2E);             // Ясно
    return const Color(0xFF111820);                             // Хмарно
  }

  Color _accentColor() {
    if (weather == null || weather!.isError) return Colors.white24;
    final id = int.tryParse(weather!.conditionId) ?? 0;
    if (id >= 200 && id < 300) return const Color(0xFF7B2FBE); // Гроза
    if (id >= 300 && id < 600) return const Color(0xFF4A8FE7); // Дощ
    if (id >= 600 && id < 700) return const Color(0xFF90CAF9); // Сніг
    if (id == 800) return const Color(0xFF4FC3F7);             // Ясно
    return const Color(0xFF546E7A);                             // Хмарно
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor();
    final accent = _accentColor();

    if (weather == null) {
      return Container(color: bg,
        child: const Center(child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 1)));
    }

    if (weather!.isError) {
      return Container(color: bg,
        child: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.white12),
            SizedBox(height: 16),
            Text('Немає даних', style: TextStyle(color: Colors.white24, fontSize: 16, letterSpacing: 1)),
          ]),
        ));
    }

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Назва міста та іконка
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather!.city.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather!.displayTemp(isCelsius),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 96,
                        fontWeight: FontWeight.w100,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather!.condition,
                      style: TextStyle(
                        color: accent,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                // Іконка погоди
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.1),
                  ),
                  child: Image.network(
                    weather!.iconUrl,
                    width: 80,
                    height: 80,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.wb_sunny_rounded, size: 60, color: accent.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Роздільник
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),

            const SizedBox(height: 32),

            // Деталі — сітка 3x2
            Row(
              children: [
                _StatBlock(label: 'Відчувається', value: weather!.displayFeelsLike(isCelsius), accent: accent),
                const SizedBox(width: 16),
                _StatBlock(label: 'Вологість', value: '${weather!.humidity}%', accent: accent),
                const SizedBox(width: 16),
                _StatBlock(label: 'Вітер', value: '${weather!.windSpeed.toStringAsFixed(1)} м/с', accent: accent),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatBlock(label: 'Мінімум', value: weather!.tempMin, accent: accent),
                const SizedBox(width: 16),
                _StatBlock(label: 'Максимум', value: weather!.tempMax, accent: accent),
                const Spacer(),
              ],
            ),

            // Прогноз
            if (forecast.isNotEmpty) ...[
              const SizedBox(height: 40),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
              const SizedBox(height: 28),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white30, fontSize: 11, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300)),
          ],
        ),
      ),
    );
  }
}
