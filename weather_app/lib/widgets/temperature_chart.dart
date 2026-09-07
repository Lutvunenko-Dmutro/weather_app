import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/forecast_model.dart';

class TemperatureChart extends StatelessWidget {
  final List<ForecastItem> forecast;
  final bool isCelsius;
  final String lang;

  const TemperatureChart({
    super.key,
    required this.forecast,
    required this.isCelsius,
    this.lang = 'uk',
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox();

    // Беремо перші 8 записів (24 години)
    final items = forecast.take(8).toList();
    if (items.length < 2) return const SizedBox();

    double minTemp = items.first.rawTemp.toDouble();
    double maxTemp = items.first.rawTemp.toDouble();
    for (var item in items) {
      if (item.rawTemp < minTemp) minTemp = item.rawTemp.toDouble();
      if (item.rawTemp > maxTemp) maxTemp = item.rawTemp.toDouble();
    }

    final spots = items.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.rawTemp.toDouble());
    }).toList();

    return SizedBox(
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang == 'uk' ? 'ПОГОДИННИЙ ПРОГНОЗ' : 'HOURLY FORECAST',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (items.length - 1).toDouble(),
                minY: minTemp - 2,
                maxY: maxTemp + 2,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < items.length) {
                          final item = items[value.toInt()];
                          return Column(
                            children: [
                              Text(
                                item.time,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Image.network(
                                item.iconUrl,
                                width: 24,
                                height: 24,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.cloud,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < items.length) {
                          final item = items[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              item.displayTemp(isCelsius),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.cyanAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.cyanAccent,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    }),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyanAccent.withValues(alpha: 0.3),
                          Colors.cyanAccent.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
