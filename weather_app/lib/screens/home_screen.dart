import 'package:flutter/material.dart';
import '../models/weather_model.dart';
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
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      allUkrainianCities = await _service.loadUkrainianCities();
      await _loadWeatherForAll();
    } catch (e) {
      setState(() {
        errorMessage = 'Помилка при завантаженні: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadWeatherForAll() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    final results = await _service.fetchWeatherForCities(cities);
    setState(() {
      for (final w in results) {
        citiesWeather[w.city] = w;
      }
      isLoading = false;
    });
  }

  Future<void> _addCity(String city) async {
    if (cities.contains(city)) {
      setState(() => errorMessage = 'Місто "$city" вже додано.');
      return;
    }
    setState(() => isLoading = true);
    final weather = await _service.fetchWeather(city);
    if (weather.temperature != 'N/A') {
      setState(() {
        cities.add(city);
        citiesWeather[city] = weather;
      });
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
        appBar: AppBar(
          title: const Text('Погода в містах України'),
          bottom: TabBar(
            isScrollable: true,
            tabs: cities.map((city) => Tab(text: city)).toList(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showAddCityDialog,
              tooltip: 'Додати місто',
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        errorMessage,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : TabBarView(
                    children: cities
                        .map((city) =>
                            WeatherCard(weather: citiesWeather[city]))
                        .toList(),
                  ),
      ),
    );
  }
}
