import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel? weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return const Center(child: Text('Завантаження...'));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          weather!.iconUrl.isNotEmpty
              ? Image.network(
                  weather!.iconUrl,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 100, color: Colors.red),
                )
              : const Icon(Icons.error, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            weather!.temperature,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            weather!.condition,
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
