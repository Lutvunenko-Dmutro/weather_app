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

  const WeatherCard({
    super.key,
    required this.weather,
    this.forecast = const [],
    this.isCelsius = true,
    this.lang = 'uk',
  });

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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D0B2E), // Deep dark blue
            Color(0xFF2A1549), // Deep purple
            Color(0xFF0F0F1A), // Dark bottom
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // City
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weather!.city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.near_me, color: Colors.blueAccent, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lang == 'uk' ? 'Оновлено щойно' : 'Updated just now',
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
