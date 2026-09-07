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
  String currentLang = 'uk';
  String errorMessage = '';
  int _bottomNavIndex = 0;

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      setState(() => _bottomNavIndex = 0);
    } else if (index == 1) {
      // Search
      _showAddCityDialog();
    } else if (index == 2) {
      // Alerts
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentLang == 'uk' 
            ? 'Немає активних штормових попереджень ☀️' 
            : 'No active storm warnings ☀️'),
          backgroundColor: Colors.blueAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (index == 3) {
      // Settings
      _showSettingsDialog();
    }
  }

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
      final weatherResults = await _service.fetchWeatherForCities(cities, lang: currentLang);
      final forecastResults = await _service.fetchForecastForCities(cities, lang: currentLang);
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
    final weather = await _service.fetchWeather(city, lang: currentLang);
    final forecast = await _service.fetchForecast(city, lang: currentLang);
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          currentLang == 'uk' ? 'Налаштування' : 'Settings',
          style: const TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    currentLang == 'uk' ? 'Мова' : 'Language',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: DropdownButton<String>(
                    dropdownColor: const Color(0xFF2A2A40),
                    value: currentLang,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'uk', child: Text('Українська')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => currentLang = val);
                        setState(() => currentLang = val);
                        _loadAll(); // reload data in new language
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    currentLang == 'uk' ? 'Одиниці виміру' : 'Temperature Unit',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: DropdownButton<bool>(
                    dropdownColor: const Color(0xFF2A2A40),
                    value: isCelsius,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: true, child: Text('°C')),
                      DropdownMenuItem(value: false, child: Text('°F')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => isCelsius = val);
                        setState(() => isCelsius = val);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              currentLang == 'uk' ? 'Закрити' : 'Close',
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ValueKey гарантує повний rebuild DefaultTabController при зміні міст
    return DefaultTabController(
      key: ValueKey(cities.join(',')),
      length: cities.length,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D0B2E), // Deep dark blue
              Color(0xFF2A1549), // Deep purple
              Color(0xFF0F0F1A), // Dark bottom
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
                    children: cities
                        .map((city) => WeatherCard(
                              weather: citiesWeather[city],
                              forecast: citiesForecast[city] ?? [],
                              isCelsius: isCelsius,
                              lang: currentLang,
                            ))
                        .toList(),
                  ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _bottomNavIndex,
            onTap: _onBottomNavTapped,
            backgroundColor: Colors.black.withValues(alpha: 0.3),
            elevation: 0,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.white54,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today_rounded, size: 22),
                label: currentLang == 'uk' ? 'Сьогодні' : 'Today',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search_rounded, size: 24),
                label: currentLang == 'uk' ? 'Пошук' : 'Search',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.notifications_none_rounded, size: 24),
                label: currentLang == 'uk' ? 'Сповіщення' : 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined, size: 24),
                label: currentLang == 'uk' ? 'Налаштування' : 'Settings',
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

