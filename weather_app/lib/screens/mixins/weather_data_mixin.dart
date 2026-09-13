import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import '../../models/forecast_model.dart';
import '../../services/weather_service.dart';
import '../../services/location_service.dart';
import '../../services/preferences_service.dart';
import '../../services/weather_sound_service.dart';
import '../../widgets/add_city_dialog.dart';
import '../home_screen.dart';

/// Manages fetching, caching and mutating weather data for all cities.
mixin WeatherDataMixin on State<HomeScreen>, TickerProviderStateMixin<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  List<String> cities = ['Київ', 'Львів', 'Одеса', 'Харків'];
  Map<String, WeatherModel> citiesWeather = {};
  Map<String, List<ForecastItem>> citiesForecast = {};

  bool isLoading = true;
  bool isCelsius = true;
  String currentLang = 'uk';
  String errorMessage = '';
  DateTime? lastUpdated;

  TabController? tabController;
  int currentTabIndex = 0;

  // ── Tab ───────────────────────────────────────────────────────────────────

  void initTabController() {
    final oldIndex = tabController?.index ?? 0;
    tabController?.dispose();
    tabController = TabController(
      length: cities.length,
      vsync: this,
      initialIndex: oldIndex < cities.length ? oldIndex : 0,
    );
    currentTabIndex = tabController!.index;
    tabController!.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (tabController!.index != currentTabIndex) {
      setState(() => currentTabIndex = tabController!.index);
      _updateSound();
    }
  }

  void _updateSound() {
    if (cities.isNotEmpty && currentTabIndex < cities.length) {
      final weather = citiesWeather[cities[currentTabIndex]];
      if (weather != null) {
        WeatherSoundService.playSoundForWeather(weather.getWeatherBgType());
      }
    }
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadSavedCities() async {
    final saved = PreferencesService.loadCities();
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        cities = saved;
        initTabController();
      });
    }
  }

  Future<void> saveCities() async {
    await PreferencesService.saveCities(cities);
  }

  Future<void> loadAll({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      // Fetch weather AND forecast for all cities in parallel
      final results = await Future.wait([
        _weatherService.fetchWeatherForCities(cities, lang: currentLang, forceRefresh: forceRefresh),
        _weatherService.fetchForecastForCities(cities, lang: currentLang, forceRefresh: forceRefresh),
      ]);
      if (!mounted) return;
      final weatherList = results[0] as List<WeatherModel>;
      final forecastMap = results[1] as Map<String, List<ForecastItem>>;
      setState(() {
        for (var i = 0; i < cities.length; i++) {
          citiesWeather[cities[i]] = weatherList[i];
        }
        citiesForecast.addAll(forecastMap);
        lastUpdated = DateTime.now();
        isLoading = false;
      });
      _updateSound();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Помилка: $e';
        isLoading = false;
      });
    }
  }

  // ── City CRUD ─────────────────────────────────────────────────────────────

  Future<void> addCity(String city) async {
    if (cities.contains(city)) {
      setState(() => errorMessage = 'Місто "$city" вже додано.');
      return;
    }
    setState(() => isLoading = true);
    final weather = await _weatherService.fetchWeather(city, lang: currentLang);
    final forecast = await _weatherService.fetchForecast(city, lang: currentLang);
    if (!mounted) return;
    if (!weather.isError) {
      setState(() {
        cities.add(city);
        citiesWeather[city] = weather;
        citiesForecast[city] = forecast;
        lastUpdated = DateTime.now();
        initTabController();
      });
      await saveCities();
      _updateSound();
    } else {
      setState(() => errorMessage = 'Не вдалося знайти місто "$city".');
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> deleteCity(String city) async {
    setState(() {
      cities.remove(city);
      citiesWeather.remove(city);
      citiesForecast.remove(city);
      initTabController();
    });
    await saveCities();
    _updateSound();
  }

  Future<void> addCurrentLocationCity() async {
    setState(() => isLoading = true);
    try {
      final position = await _locationService.determinePosition();
      final weather = await _locationService.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
        lang: currentLang,
      );
      if (weather.isError) {
        if (mounted) {
          setState(() {
            errorMessage = currentLang == 'uk'
                ? 'Не вдалося знайти місто за координатами.'
                : 'Failed to find city by location.';
            isLoading = false;
          });
        }
        return;
      }
      final forecast = await _locationService.fetchForecastByLocation(
        position.latitude,
        position.longitude,
        lang: currentLang,
      );
      if (!mounted) return;
      setState(() {
        if (!cities.contains(weather.city)) cities.insert(0, weather.city);
        citiesWeather[weather.city] = weather;
        citiesForecast[weather.city] = forecast;
        lastUpdated = DateTime.now();
        initTabController();
      });
      await saveCities();
      _updateSound();
    } catch (e) {
      if (mounted) setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showAddCityDialogMenu() {
    showDialog(
      context: context,
      builder: (_) => AddCityDialog(
        onCitySelected: addCity,
        lang: currentLang,
      ),
    );
  }
}
