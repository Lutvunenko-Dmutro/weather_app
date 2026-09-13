import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/preferences_service.dart';
import '../services/weather_sound_service.dart';
import '../widgets/add_city_dialog.dart';
import 'home_screen.dart';

mixin HomeScreenLogic on State<HomeScreen>, TickerProviderStateMixin<HomeScreen> {
  final WeatherService service = WeatherService();
  final LocationService locationService = LocationService();
  
  int sunVariant = 0;
  int rainVariant = 0;
  int snowVariant = 0;
  int cloudVariant = 0;
  List<String> cities = ['Київ', 'Львів', 'Одеса', 'Харків'];
  Map<String, WeatherModel> citiesWeather = {};
  Map<String, List<ForecastItem>> citiesForecast = {};
  
  bool isLoading = true;
  bool isCelsius = true;
  String currentLang = 'uk';
  String errorMessage = '';
  DateTime? lastUpdated;
  int bottomNavIndex = 0;
  
  WeatherType? settingsPreviewWeatherType;
  
  TabController? tabController;
  int currentTabIndex = 0;

  void onBottomNavTapped(int index) {
    if (index == 0 || index == 2) {
      setState(() {
        bottomNavIndex = index;
        if (index != 2) {
          settingsPreviewWeatherType = null; // Clear preview when leaving settings
        }
      });
    } else if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentLang == 'uk' ? 'Немає активних штормових попереджень ☀️' : 'No active storm warnings ☀️'),
          backgroundColor: Colors.blueAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void initTabController() {
    final oldIndex = tabController?.index ?? 0;
    tabController?.dispose();
    tabController = TabController(
      length: cities.length,
      vsync: this,
      initialIndex: oldIndex < cities.length ? oldIndex : 0,
    );
    currentTabIndex = tabController!.index;
    tabController!.addListener(onTabChanged);
  }

  void onTabChanged() {
    if (tabController!.index != currentTabIndex) {
      setState(() {
        currentTabIndex = tabController!.index;
      });
      updateSound();
    }
  }

  void updateSound() {
    if (cities.isNotEmpty && currentTabIndex < cities.length) {
      final city = cities[currentTabIndex];
      final weather = citiesWeather[city];
      if (weather != null) {
        WeatherSoundService.playSoundForWeather(weather.getWeatherBgType());
      }
    }
  }

  Future<void> initLogic() async {
    sunVariant = await PreferencesService.loadVariant('sun');
    rainVariant = await PreferencesService.loadVariant('rain');
    snowVariant = await PreferencesService.loadVariant('snow');
    cloudVariant = await PreferencesService.loadVariant('cloud');
    await loadSavedCities();
    initTabController();
    await loadAll();
  }

  void updateVariant(String type, int variant) {
    setState(() {
      if (type == 'sun') {
        sunVariant = variant;
        settingsPreviewWeatherType = WeatherType.sunny;
      }
      if (type == 'rain') {
        rainVariant = variant;
        settingsPreviewWeatherType = WeatherType.heavyRainy;
      }
      if (type == 'snow') {
        snowVariant = variant;
        settingsPreviewWeatherType = WeatherType.heavySnow;
      }
      if (type == 'cloud') {
        cloudVariant = variant;
        settingsPreviewWeatherType = WeatherType.cloudy;
      }
    });
    PreferencesService.saveVariant(type, variant);
  }

  Future<void> loadSavedCities() async {
    final saved = await PreferencesService.loadCities();
    if (saved != null && saved.isNotEmpty) {
      if (mounted) setState(() {
        cities = saved;
        initTabController();
      });
    }
  }

  Future<void> saveCities() async {
    await PreferencesService.saveCities(cities);
  }

  Future<void> loadAll() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final weatherResults = await service.fetchWeatherForCities(cities, lang: currentLang);
      final forecastResults = await service.fetchForecastForCities(cities, lang: currentLang);
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < cities.length; i++) {
          citiesWeather[cities[i]] = weatherResults[i];
        }
        citiesForecast.addAll(forecastResults);
        lastUpdated = DateTime.now();
        isLoading = false;
      });
      updateSound();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Помилка: $e';
        isLoading = false;
      });
    }
  }

  Future<void> addCity(String city) async {
    if (cities.contains(city)) {
      setState(() => errorMessage = 'Місто "$city" вже додано.');
      return;
    }
    setState(() => isLoading = true);
    final weather = await service.fetchWeather(city, lang: currentLang);
    final forecast = await service.fetchForecast(city, lang: currentLang);
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
      updateSound();
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
    updateSound();
  }

  Future<void> addCurrentLocationCity() async {
    setState(() => isLoading = true);
    try {
      final position = await locationService.determinePosition();
      final weather = await locationService.fetchWeatherByLocation(position.latitude, position.longitude, lang: currentLang);
      
      if (weather.isError) {
        setState(() {
          errorMessage = currentLang == 'uk' ? 'Не вдалося знайти місто за координатами.' : 'Failed to find city by location.';
          isLoading = false;
        });
        return;
      }
      
      final forecast = await locationService.fetchForecastByLocation(position.latitude, position.longitude, lang: currentLang);
      
      if (!mounted) return;
      
      setState(() {
        if (!cities.contains(weather.city)) {
           cities.insert(0, weather.city);
        }
        citiesWeather[weather.city] = weather;
        citiesForecast[weather.city] = forecast;
        lastUpdated = DateTime.now();
        initTabController();
      });
      await saveCities();
      updateSound();
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



  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}
