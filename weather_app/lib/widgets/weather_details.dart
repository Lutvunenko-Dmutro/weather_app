import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'glass_card.dart';

class WeatherDetails extends StatelessWidget {
  final WeatherModel weather;
  final String lang;

  const WeatherDetails({super.key, required this.weather, this.lang = 'uk'});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          _buildDetailRow(lang == 'uk' ? 'Вологість' : 'Humidity', '${weather.humidity}%'),
          const SizedBox(height: 12),
          _buildDetailRow(lang == 'uk' ? 'Вітер' : 'Wind', '${weather.windSpeed.toStringAsFixed(1)} ${lang == 'uk' ? 'м/с' : 'm/s'}'),
          const SizedBox(height: 12),
          _buildDetailRow(lang == 'uk' ? 'Тиск' : 'Pressure', '${weather.pressure} hPa'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
