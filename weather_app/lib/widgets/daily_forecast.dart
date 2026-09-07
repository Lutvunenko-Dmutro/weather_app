import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';
import 'glass_card.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<ForecastItem> forecast;
  final bool isCelsius;
  final String lang;

  const DailyForecastWidget({
    super.key,
    required this.forecast,
    required this.isCelsius,
    this.lang = 'uk',
  });

  String _getLocalizedDay(DateTime date, String lang) {
    if (lang == 'en') {
      return DateFormat('EEE').format(date).toUpperCase();
    }
    const days = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'НД'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox();

    final dailyItems = DailyForecast.fromHourly(forecast);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang == 'uk' ? '5-ДЕННИЙ ПРОГНОЗ' : '5-DAY FORECAST',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dailyItems.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  borderRadius: 12,
                  child: Column(
                    children: [
                      Text(
                        _getLocalizedDay(item.date, lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.displayMaxTemp(isCelsius)}/${item.displayMinTemp(isCelsius)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        item.iconUrl,
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.cloud,
                          color: Colors.white54,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.condition.split(' ').first,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
