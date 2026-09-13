import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'weather_card.dart';

class HomeTabView extends StatelessWidget {
  final TabController? tabController;
  final List<String> cities;
  final Map<String, WeatherModel> citiesWeather;
  final Map<String, List<ForecastItem>> citiesForecast;
  final bool isCelsius;
  final String currentLang;
  final DateTime? lastUpdated;
  final Future<void> Function() onRefresh;
  final Function(String) onDeleteCity;

  const HomeTabView({
    super.key,
    required this.tabController,
    required this.cities,
    required this.citiesWeather,
    required this.citiesForecast,
    required this.isCelsius,
    required this.currentLang,
    required this.lastUpdated,
    required this.onRefresh,
    required this.onDeleteCity,
  });

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) {
      return const Center(
        child: Text(
          'Немає доданих міст',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    return TabBarView(
      controller: tabController,
      children: cities
          .map((city) => RepaintBoundary(
                child: WeatherCard(
                  weather: citiesWeather[city],
                  forecast: citiesForecast[city] ?? [],
                  isCelsius: isCelsius,
                  lang: currentLang,
                  lastUpdated: lastUpdated,
                  onRefresh: onRefresh,
                  onDelete: () => onDeleteCity(city),
                ),
              ))
          .toList(),
    );
  }
}
