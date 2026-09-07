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

  // Градієнт залежно від умовного коду погоди
  LinearGradient _getGradient() {
    if (weather == null || weather!.isError) {
      return const LinearGradient(
        colors: [Color(0xFF2C3E50), Color(0xFF3D4C5E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    final id = int.tryParse(weather!.conditionId) ?? 0;

    if (id >= 200 && id < 300) {
      // Гроза
      return const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF4A0080)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (id >= 300 && id < 600) {
      // Дощ / мряка
      return const LinearGradient(colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (id >= 600 && id < 700) {
      // Сніг
      return const LinearGradient(colors: [Color(0xFF5D6D7E), Color(0xFFABB7B7)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (id >= 700 && id < 800) {
      // Туман
      return const LinearGradient(colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else if (id == 800) {
      // Ясно
      return const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter);
    } else {
      // Хмарно
      return const LinearGradient(colors: [Color(0xFF37474F), Color(0xFF78909C)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return Container(
        decoration: BoxDecoration(gradient: _getGradient()),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (weather!.isError) {
      return Container(
        decoration: BoxDecoration(gradient: _getGradient()),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 80, color: Colors.white54),
              SizedBox(height: 16),
              Text('Не вдалося отримати дані',
                  style: TextStyle(color: Colors.white54, fontSize: 18)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(gradient: _getGradient()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Іконка та температура
              Image.network(
                weather!.iconUrl,
                width: 120,
                height: 120,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.wb_sunny, size: 120, color: Colors.white70),
              ),
              Text(
                weather!.displayTemp(isCelsius),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                weather!.condition.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Деталі погоди
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DetailItem(
                      icon: Icons.thermostat,
                      label: 'Відчувається',
                      value: weather!.displayFeelsLike(isCelsius),
                    ),
                    _DetailItem(
                      icon: Icons.water_drop,
                      label: 'Вологість',
                      value: '${weather!.humidity}%',
                    ),
                    _DetailItem(
                      icon: Icons.air,
                      label: 'Вітер',
                      value: '${weather!.windSpeed.toStringAsFixed(1)} м/с',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Мін/макс
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DetailItem(
                      icon: Icons.arrow_downward,
                      label: 'Мін',
                      value: weather!.tempMin,
                    ),
                    _DetailItem(
                      icon: Icons.arrow_upward,
                      label: 'Макс',
                      value: weather!.tempMax,
                    ),
                  ],
                ),
              ),

              // Прогноз на 5 днів
              if (forecast.isNotEmpty) ...[
                const SizedBox(height: 24),
                ForecastWidget(forecast: forecast, isCelsius: isCelsius),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
