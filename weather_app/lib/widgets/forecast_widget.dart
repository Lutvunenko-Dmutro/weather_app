import 'package:flutter/material.dart';
import '../models/forecast_model.dart';

class ForecastWidget extends StatelessWidget {
  final List<ForecastItem> forecast;
  final bool isCelsius;
  final Color accent;

  const ForecastWidget({
    super.key,
    required this.forecast,
    required this.isCelsius,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ПРОГНОЗ',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 11,
            letterSpacing: 4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        // Scrollbar для підтримки мишки на Windows
        Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: SizedBox(
            height: 120,
            child: ListView.separated(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: forecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = forecast[index];
                return Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.date,
                        style: const TextStyle(color: Colors.white24, fontSize: 10),
                      ),
                      Text(
                        item.time,
                        style: const TextStyle(color: Colors.white30, fontSize: 11),
                      ),
                      Image.network(
                        item.iconUrl,
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.cloud, color: accent.withValues(alpha: 0.5), size: 28),
                      ),
                      Text(
                        item.displayTemp(isCelsius),
                        style: TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
