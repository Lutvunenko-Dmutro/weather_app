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

  // Зберігаємо список міст між сесіями
  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('cities');
    if (saved != null && saved.isNotEmpty) {
      setState(() => cities = saved);
    }
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cities', cities);
  }

  Future<void> _loadAll() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      // Паралельно завантажуємо поточну погоду та прогноз
      final weatherResults = await _service.fetchWeatherForCities(cities);
      final forecastResults = await Future.wait(
        cities.map((city) => _service.fetchForecast(city)),
      );
      setState(() {
        for (var i = 0; i < cities.length; i++) {
          citiesWeather[cities[i]] = weatherResults[i];
          citiesForecast[cities[i]] = forecastResults[i];
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Помилка завантаження: $e';
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
    setState(() => isLoading = false);
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
    return DefaultTabController(
      length: cities.length,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Погода в Україні',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: cities.map((city) => Tab(text: city)).toList(),
          ),
          actions: [
            // Перемикач °C / °F
            GestureDetector(
              onTap: () => setState(() => isCelsius = !isCelsius),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCelsius ? '°C' : '°F',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            // Оновити дані
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _loadAll,
              tooltip: 'Оновити',
            ),
            // Додати місто
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white70),
              onPressed: _showAddCityDialog,
              tooltip: 'Додати місто',
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAll,
                    child: TabBarView(
                      children: cities.map((city) => WeatherCard(
                        weather: citiesWeather[city],
                        forecast: citiesForecast[city] ?? [],
                        isCelsius: isCelsius,
                      )).toList(),
                    ),
                  ),
      ),
    );
  }
}
