import 'package:flutter/material.dart';
import '../models/forecast_model.dart';

class ForecastWidget extends StatelessWidget {
  final List<ForecastItem> forecast;
  final bool isCelsius;

  const ForecastWidget({
    super.key,
    required this.forecast,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ПРОГНОЗ',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = forecast[index];
              return Container(
                width: 72,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Image.network(
                      item.iconUrl,
                      width: 36,
                      height: 36,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.cloud, color: Colors.white54, size: 36),
                    ),
                    Text(
                      item.displayTemp(isCelsius),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
