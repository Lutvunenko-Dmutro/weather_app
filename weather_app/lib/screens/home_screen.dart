import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';
import '../widgets/add_city_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _service = WeatherService();

  List<String> cities = ['Київ', 'Львів', 'Одеса', 'Харків'];
  List<String> allUkrainianCities = [];
  Map<String, WeatherModel> citiesWeather = {};
  Map<String, List<ForecastItem>> citiesForecast = {};
  bool isLoading = true;
  bool isCelsius = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadSavedCities();
    allUkrainianCities = await _service.loadUkrainianCities();
    await _loadAll();
  }

  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('cities');
    if (saved != null && saved.isNotEmpty) {
      if (mounted) setState(() => cities = saved);
    }
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cities', cities);
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final weatherResults = await _service.fetchWeatherForCities(cities);
      final forecastResults = await _service.fetchForecastForCities(cities);
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < cities.length; i++) {
          citiesWeather[cities[i]] = weatherResults[i];
        }
        citiesForecast.addAll(forecastResults);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Помилка: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _addCity(String city) async {
    if (cities.contains(city)) {
      setState(() => errorMessage = 'Місто "$city" вже додано.');
      return;
    }
    setState(() => isLoading = true);
    final weather = await _service.fetchWeather(city);
    final forecast = await _service.fetchForecast(city);
    if (!mounted) return;
    if (!weather.isError) {
      setState(() {
        cities.add(city);
        citiesWeather[city] = weather;
        citiesForecast[city] = forecast;
      });
      await _saveCities();
    } else {
      setState(() => errorMessage = 'Не вдалося знайти місто "$city".');
    }
    if (mounted) setState(() => isLoading = false);
  }

  void _showAddCityDialog() {
    showDialog(
      context: context,
      builder: (_) => AddCityDialog(
        onCitySelected: _addCity,
        allCities: allUkrainianCities,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ValueKey гарантує повний rebuild DefaultTabController при зміні міст
    return DefaultTabController(
      key: ValueKey(cities.join(',')),
      length: cities.length,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F0F1A),
          elevation: 0,
          title: const Text(
            'Ukraine Weather',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 20,
              letterSpacing: 1.5,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 1,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white30,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            tabs: cities.map((city) => Tab(text: city)).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => setState(() => isCelsius = !isCelsius),
              child: Text(
                isCelsius ? '°C' : '°F',
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    fontWeight: FontWeight.w300),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white38),
              onPressed: _loadAll,
            ),
            IconButton(
              icon: const Icon(Icons.add_rounded, color: Colors.white38),
              onPressed: _showAddCityDialog,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        color: Colors.white38, strokeWidth: 1),
                    SizedBox(height: 16),
                    Text('Завантаження...',
                        style: TextStyle(color: Colors.white24, fontSize: 13)),
                  ],
                ),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(errorMessage,
                        style: const TextStyle(
                            color: Colors.white30, fontSize: 14)),
                  )
                : TabBarView(
                    // Вимкнути фізику щоб на десктопі не було конфліктів
                    physics: const NeverScrollableScrollPhysics(),
                    children: cities
                        .map((city) => WeatherCard(
                              weather: citiesWeather[city],
                              forecast: citiesForecast[city] ?? [],
                              isCelsius: isCelsius,
                            ))
                        .toList(),
                  ),
      ),
    );
  }
}
