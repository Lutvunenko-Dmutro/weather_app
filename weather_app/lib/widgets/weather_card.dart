import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'weather_details.dart';
import 'temperature_chart.dart';
import 'daily_forecast.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel? weather;
  final List<ForecastItem> forecast;
  final bool isCelsius;
  final String lang;
  final DateTime? lastUpdated;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onDelete;

  const WeatherCard({
    super.key,
    required this.weather,
    this.forecast = const [],
    this.isCelsius = true,
    this.lang = 'uk',
    this.lastUpdated,
    this.onRefresh,
    this.onDelete,
  });

  String _formatLastUpdated() {
    if (lastUpdated == null) return lang == 'uk' ? 'Оновлюється...' : 'Updating...';
    final h = lastUpdated!.hour.toString().padLeft(2, '0');
    final m = lastUpdated!.minute.toString().padLeft(2, '0');
    return lang == 'uk' ? 'Оновлено о $h:$m' : 'Updated at $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 1),
      );
    }

    if (weather!.isError) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.white12),
          const SizedBox(height: 16),
          Text(lang == 'uk' ? 'Немає даних' : 'No data',
              style: const TextStyle(color: Colors.white24, fontSize: 16, letterSpacing: 1)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      color: Colors.blueAccent,
      backgroundColor: const Color(0xFF1A1A2E),
      child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // City
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weather!.translatedCity ?? weather!.city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (weather!.isCurrentLocation) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.near_me, color: Colors.blueAccent, size: 20),
                  ],
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 24),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatLastUpdated(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Big Temp & Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  weather!.displayTemp(isCelsius),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.w200,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 16),
                Image.network(
                  weather!.iconUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.wb_sunny_rounded, size: 80, color: Colors.orangeAccent),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              weather!.condition,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${lang == 'uk' ? 'ВІДЧУВАЄТЬСЯ ЯК' : 'FEELS LIKE'} ${weather!.displayFeelsLike(isCelsius)}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Details Glass Card
            WeatherDetails(weather: weather!, lang: lang),
            
            const SizedBox(height: 40),
            
            // Hourly chart
            TemperatureChart(forecast: forecast, isCelsius: isCelsius, lang: lang),
            
            const SizedBox(height: 40),
            
            // 5-Day forecast
            DailyForecastWidget(forecast: forecast, isCelsius: isCelsius, lang: lang),
          ],
        ),
      ),
    );
  }
}
